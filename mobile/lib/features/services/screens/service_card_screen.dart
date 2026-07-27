import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/api/api_client.dart';
import '../../../core/utils/localized_names.dart';
import '../../../core/api/models.dart';
import '../../../core/api/services_api.dart';
import '../../../core/api/users_api.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/auth_gate_sheet.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/providers/session_controller.dart';
import '../providers/services_providers.dart';
import '../widgets/report_sheet.dart';

/// Экран 05 «Карточка сервиса»: галерея, описание, ссылки, лайк/подтверждение.
class ServiceCardScreen extends ConsumerStatefulWidget {
  const ServiceCardScreen({super.key, required this.serviceId});

  final String serviceId;

  @override
  ConsumerState<ServiceCardScreen> createState() => _ServiceCardScreenState();
}

class _ServiceCardScreenState extends ConsumerState<ServiceCardScreen> {
  int _photoIndex = 0;
  bool _liking = false;

  bool get _isGuest =>
      ref.read(sessionControllerProvider).status != SessionStatus.ready;

  Future<void> _toggleLike(ServiceDetail service) async {
    final l10n = AppLocalizations.of(context)!;
    if (_isGuest) {
      showAuthGateSheet(context, l10n.authGateActionLike);
      return;
    }
    setState(() => _liking = true);
    try {
      await ref.read(servicesApiProvider).toggleLike(service.id);
      ref.invalidate(serviceDetailProvider(service.id));
      ref.invalidate(servicesListProvider);
    } on ApiException {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.genericError)));
      }
    } finally {
      if (mounted) setState(() => _liking = false);
    }
  }

  Future<void> _toggleFavorite(ServiceDetail service) async {
    final l10n = AppLocalizations.of(context)!;
    if (_isGuest) {
      showAuthGateSheet(context, l10n.authGateActionFavorite);
      return;
    }
    final api = ref.read(servicesApiProvider);
    if (service.isFavorite) {
      await api.removeFavorite(service.id);
    } else {
      await api.addFavorite(service.id);
    }
    ref.invalidate(serviceDetailProvider(service.id));
    ref.invalidate(favoritesProvider);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          service.isFavorite
              ? l10n.removedFromFavorites
              : l10n.addedToFavorites,
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final detailAsync = ref.watch(serviceDetailProvider(widget.serviceId));
    final categories =
        ref.watch(categoriesProvider).valueOrNull ?? const <ServiceCategory>[];
    final cities = ref.watch(citiesProvider).valueOrNull ?? const <City>[];

    String categoryName(int id) {
      for (final c in categories) {
        if (c.id == id) return localizedName(context, c.nameRu, c.nameEn);
      }
      return '';
    }

    String cityName(int id) {
      for (final c in cities) {
        if (c.id == id) return localizedName(context, c.nameRu, c.nameEn);
      }
      return '';
    }

    return Scaffold(
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(
          child: TextButton(
            onPressed: () =>
                ref.invalidate(serviceDetailProvider(widget.serviceId)),
            child: Text(l10n.retry),
          ),
        ),
        data: (service) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGallery(service),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.title,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${categoryName(service.categoryId)} · ${cityName(service.cityId)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.thumb_up,
                          size: 18,
                          color: AppColors.coral,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          l10n.recommendCount(service.likesCount),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      service.description,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 20),
                    if (service.websiteUrl != null || service.mapUrl != null)
                      Row(
                        children: [
                          if (service.websiteUrl != null)
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => launchUrl(
                                  Uri.parse(service.websiteUrl!),
                                  mode: LaunchMode.externalApplication,
                                ),
                                child: Text(l10n.siteButton),
                              ),
                            ),
                          if (service.websiteUrl != null &&
                              service.mapUrl != null)
                            const SizedBox(width: 12),
                          if (service.mapUrl != null)
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => launchUrl(
                                  Uri.parse(service.mapUrl!),
                                  mode: LaunchMode.externalApplication,
                                ),
                                child: Text(l10n.mapButton),
                              ),
                            ),
                        ],
                      ),
                    const SizedBox(height: 16),
                    _buildLikeArea(service, l10n),
                    const SizedBox(height: 16),
                    Text(
                      l10n.addedBy(service.authorName),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGallery(ServiceDetail service) {
    final photos = service.photos.isEmpty
        ? [ServicePhoto(id: '', url: service.photoUrl, sort: 0)]
        : service.photos;
    return SizedBox(
      height: 300,
      child: Stack(
        children: [
          PageView.builder(
            itemCount: photos.length,
            onPageChanged: (i) => setState(() => _photoIndex = i),
            itemBuilder: (context, index) => CachedNetworkImage(
              imageUrl: absoluteFileUrl(photos[index].url),
              fit: BoxFit.cover,
              placeholder: (context, url) =>
                  Container(color: AppColors.surface),
              errorWidget: (context, url, error) => Container(
                color: AppColors.surface,
                child: const Icon(
                  Icons.image_outlined,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          // Кнопки поверх фото
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            child: _CircleButton(
              icon: Icons.chevron_left,
              onTap: () => context.pop(),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 16,
            child: Row(
              children: [
                _CircleButton(
                  icon: Icons.more_horiz,
                  onTap: () => showServiceReportSheet(
                    context,
                    ref,
                    serviceId: service.id,
                    isGuest: _isGuest,
                  ),
                ),
                const SizedBox(width: 8),
                _CircleButton(
                  icon: service.isFavorite
                      ? Icons.favorite
                      : Icons.favorite_border,
                  iconColor: service.isFavorite ? AppColors.coral : null,
                  onTap: () => _toggleFavorite(service),
                ),
              ],
            ),
          ),
          if (photos.length > 1) ...[
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < photos.length; i++)
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == _photoIndex
                            ? AppColors.coral
                            : Colors.white70,
                      ),
                    ),
                ],
              ),
            ),
            Positioned(
              bottom: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_photoIndex + 1}/${photos.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Кнопка лайка по состоянию (спецификация, экран 05):
  /// свой сервис → бейдж; pending+can_confirm → «Подтвердить (N/30)»;
  /// pending без права → подпись; иначе → «Рекомендую»/«Вы рекомендуете».
  Widget _buildLikeArea(ServiceDetail service, AppLocalizations l10n) {
    if (service.isAuthor) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.small),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(l10n.yourServiceBadge),
          ],
        ),
      );
    }

    final isPending = service.status == 'pending';
    if (isPending && !_isGuest && !service.canConfirm) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(
            value: service.confirmThreshold == 0
                ? 0
                : service.confirmCount / service.confirmThreshold,
            backgroundColor: AppColors.surface,
            color: AppColors.coral,
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
          const SizedBox(height: 8),
          Text(
            '${service.confirmCount}/${service.confirmThreshold} · ${l10n.confirmedByLocals}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      );
    }

    final String label;
    if (isPending) {
      label = l10n.confirmButton(
        service.confirmCount,
        service.confirmThreshold,
      );
    } else if (service.likedByMe) {
      label = l10n.youRecommend;
    } else {
      label = l10n.recommendButton;
    }

    if (service.likedByMe && !isPending) {
      return OutlinedButton(
        onPressed: _liking ? null : () => _toggleLike(service),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.coral,
          side: const BorderSide(color: AppColors.coral, width: 1.2),
          backgroundColor: AppColors.coralTint,
        ),
        child: Text(label),
      );
    }
    return PrimaryButton(
      label: label,
      loading: _liking,
      onPressed: () => _toggleLike(service),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.onTap,
    this.iconColor,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 22, color: iconColor ?? AppColors.textPrimary),
      ),
    );
  }
}
