import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/tab_header.dart';
import '../../../core/api/models.dart';
import '../../../core/utils/localized_names.dart';
import '../../../core/api/services_api.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/auth_gate_sheet.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/providers/session_controller.dart';
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
  // Пока показываем только «Рекомендовано»; вкладка «На проверке» скрыта
  final String _tab = 'recommended';

  bool get _isGuest =>
      ref.read(sessionControllerProvider).status != SessionStatus.ready;

  /// Порядок карточек перемешивается, но остаётся стабильным внутри захода
  String _seed = DateTime.now().millisecondsSinceEpoch.toString();

  @override
  void initState() {
    super.initState();
    // Справочник категорий живёт всю сессию — перечитываем при каждом заходе,
    // иначе добавленная админом категория не появится до перезапуска
    Future.microtask(() => ref.invalidate(placeCategoriesProvider));
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
    final categoriesAsync = ref.watch(placeCategoriesProvider);
    final session = ref.watch(sessionControllerProvider);
    final isGuest = session.status != SessionStatus.ready;
    final listAsync = ref.watch(
      servicesListProvider(
        ServicesListKey(
          tab: _tab,
          cityId: cityId,
          categoryId: categoryId,
          seed: _seed,
        ),
      ),
    );
    final favoriteIds = isGuest
        ? const <String>{}
        : (ref.watch(favoritesProvider).valueOrNull ?? [])
              .map((s) => s.id)
              .toSet();

    final categories = categoriesAsync.valueOrNull ?? const <ServiceCategory>[];
    String categoryName(int id) {
      for (final c in categories) {
        if (c.id == id) return localizedName(context, c.nameRu, c.nameEn);
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
            TabHeader(
              title: l10n.servicesTitle,
              actions: [
                HeaderIconButton(
                  icon: const Icon(Icons.favorite_border),
                  onPressed: () {
                    if (isGuest) {
                      showAuthGateSheet(context, l10n.authGateActionFavorite);
                    } else {
                      context.push('/favorites');
                    }
                  },
                ),
                const NotificationsBellButton(),
              ],
            ),
            // Вкладка «На проверке» скрыта: такие карточки видит только админ
            // в панели администрирования. Механика 30 зачётных лайков осталась
            // в коде — чтобы вернуть раздел, достаточно вернуть эти табы.
            const SizedBox(height: 4),
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
                      label: localizedName(context, c.nameRu, c.nameEn),
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
                error: (err, st) => EmptyState(
                  icon: Icons.wifi_off_rounded,
                  tone: EmptyStateTone.error,
                  title: l10n.errorTitle,
                  description: l10n.errorNetworkBody,
                  actionLabel: l10n.retry,
                  onAction: () => ref.invalidate(servicesListProvider),
                ),
                data: (services) => services.isEmpty
                    ? EmptyState(
                        icon: Icons.grid_view_rounded,
                        title: l10n.servicesEmptyTitle,
                        description: l10n.servicesEmptyRecommended,
                        actionLabel: isGuest ? null : l10n.addServiceAction,
                        onAction: isGuest
                            ? null
                            : () => context.push('/services/add'),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          // новое зерно — новый порядок карточек
                          setState(
                            () => _seed = DateTime.now().millisecondsSinceEpoch
                                .toString(),
                          );
                          ref.invalidate(servicesListProvider);
                          ref.invalidate(placeCategoriesProvider);
                        },
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

// Используется вкладками «Рекомендовано / На проверке». Раздел «На проверке»
// временно скрыт, виджет оставлен, чтобы вернуть его одной строкой.
// ignore: unused_element
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
