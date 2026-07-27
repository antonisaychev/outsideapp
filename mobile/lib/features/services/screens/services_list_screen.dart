import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/models.dart';
import '../../../core/api/services_api.dart';
import '../../../core/api/users_api.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/auth_gate_sheet.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/providers/session_controller.dart';
import '../../notifications/providers/notifications_providers.dart';
import '../providers/services_providers.dart';
import '../widgets/service_grid_card.dart';

/// Экран 04 «Сервисы»: табы Рекомендовано/На проверке, чипы категорий,
/// переключатель места, плитка карточек, FAB «+».
class ServicesListScreen extends ConsumerStatefulWidget {
  const ServicesListScreen({super.key});

  @override
  ConsumerState<ServicesListScreen> createState() => _ServicesListScreenState();
}

class _ServicesListScreenState extends ConsumerState<ServicesListScreen> {
  String _tab = 'recommended';

  bool get _isGuest =>
      ref.read(sessionControllerProvider).status != SessionStatus.ready;

  Future<void> _openCityPicker() async {
    final l10n = AppLocalizations.of(context)!;
    final cities = await ref.read(citiesProvider.future);
    if (!mounted) return;
    final selected = await showModalBottomSheet<int>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Text(
                l10n.placeSheetTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            for (final city in cities)
              ListTile(
                leading: Text(city.flag, style: const TextStyle(fontSize: 24)),
                title: Text(city.nameRu),
                subtitle: Text(city.countryRu),
                onTap: () => Navigator.of(context).pop(city.id),
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
    if (selected != null) {
      ref.read(viewCityIdProvider.notifier).state = selected;
    }
  }

  Future<void> _toggleFavorite(ServiceSummary service, bool isFavorite) async {
    final l10n = AppLocalizations.of(context)!;
    if (_isGuest) {
      showAuthGateSheet(context, l10n.authGateActionFavorite);
      return;
    }
    final api = ref.read(servicesApiProvider);
    if (isFavorite) {
      await api.removeFavorite(service.id);
    } else {
      await api.addFavorite(service.id);
    }
    ref.invalidate(favoritesProvider);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isFavorite ? l10n.removedFromFavorites : l10n.addedToFavorites,
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cityId = ref.watch(viewCityIdProvider);
    final categoryId = ref.watch(selectedCategoryProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final citiesAsync = ref.watch(citiesProvider);
    final session = ref.watch(sessionControllerProvider);
    final isGuest = session.status != SessionStatus.ready;
    final unreadNotifications = isGuest
        ? 0
        : (ref.watch(unreadNotificationsProvider).valueOrNull ?? 0);
    final listAsync = ref.watch(
      servicesListProvider(
        ServicesListKey(tab: _tab, cityId: cityId, categoryId: categoryId),
      ),
    );
    final favoriteIds = isGuest
        ? const <String>{}
        : (ref.watch(favoritesProvider).valueOrNull ?? [])
              .map((s) => s.id)
              .toSet();

    final cities = citiesAsync.valueOrNull ?? const <City>[];
    String cityName(int id) {
      for (final c in cities) {
        if (c.id == id) return c.nameRu;
      }
      return '';
    }

    final categories = categoriesAsync.valueOrNull ?? const <ServiceCategory>[];
    String categoryName(int id) {
      for (final c in categories) {
        if (c.id == id) return c.nameRu;
      }
      return '';
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.coral,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        onPressed: () {
          if (isGuest) {
            showAuthGateSheet(context, l10n.authGateActionAdd);
          } else {
            context.push('/services/add');
          }
        },
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Шапка: заголовок + избранное + колокольчик + место
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.servicesTitle,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.favorite_border),
                    onPressed: () {
                      if (isGuest) {
                        showAuthGateSheet(context, l10n.authGateActionFavorite);
                      } else {
                        context.push('/favorites');
                      }
                    },
                  ),
                  IconButton(
                    icon: Badge(
                      // красная точка при непрочитанных (спека, экран 04)
                      isLabelVisible: !isGuest && unreadNotifications > 0,
                      backgroundColor: AppColors.coral,
                      smallSize: 8,
                      child: const Icon(Icons.notifications_none),
                    ),
                    onPressed: () {
                      if (isGuest) {
                        showAuthGateSheet(context, l10n.authGateActionFavorite);
                      } else {
                        context.push('/notifications');
                      }
                    },
                  ),
                  TextButton(
                    onPressed: _openCityPicker,
                    child: Row(
                      children: [
                        Text(cityName(cityId)),
                        const Icon(Icons.keyboard_arrow_down, size: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Табы
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  _TabLabel(
                    text: l10n.servicesTabRecommended,
                    active: _tab == 'recommended',
                    onTap: () => setState(() => _tab = 'recommended'),
                  ),
                  const SizedBox(width: 20),
                  _TabLabel(
                    text: l10n.servicesTabPending,
                    active: _tab == 'pending',
                    onTap: () => setState(() => _tab = 'pending'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Чипы категорий
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  _CategoryChip(
                    label: l10n.categoryAll,
                    selected: categoryId == null,
                    onTap: () =>
                        ref.read(selectedCategoryProvider.notifier).state =
                            null,
                  ),
                  for (final c in categories) ...[
                    const SizedBox(width: 8),
                    _CategoryChip(
                      label: c.nameRu,
                      selected: categoryId == c.id,
                      onTap: () =>
                          ref.read(selectedCategoryProvider.notifier).state =
                              c.id,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Плитка
            Expanded(
              child: listAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, st) => Center(
                  child: TextButton(
                    onPressed: () => ref.invalidate(servicesListProvider),
                    child: Text(l10n.retry),
                  ),
                ),
                data: (services) => services.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            _tab == 'pending'
                                ? l10n.servicesEmptyPending
                                : l10n.servicesEmptyRecommended,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async =>
                            ref.invalidate(servicesListProvider),
                        child: GridView.builder(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 96),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                childAspectRatio: 0.72,
                              ),
                          itemCount: services.length,
                          itemBuilder: (context, index) {
                            final s = services[index];
                            return ServiceGridCard(
                              service: s,
                              categoryName: categoryName(s.categoryId),
                              cityName: cityName(s.cityId),
                              isFavorite: favoriteIds.contains(s.id),
                              onTap: () => context.push('/services/${s.id}'),
                              onFavoriteTap: () => _toggleFavorite(
                                s,
                                favoriteIds.contains(s.id),
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabLabel extends StatelessWidget {
  const _TabLabel({
    required this.text,
    required this.active,
    required this.onTap,
  });

  final String text;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              color: active ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 3,
            width: 48,
            decoration: BoxDecoration(
              color: active ? AppColors.coral : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.coralTint : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.coral : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: selected ? AppColors.coral : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
