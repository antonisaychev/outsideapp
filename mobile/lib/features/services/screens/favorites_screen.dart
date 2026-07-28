import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/models.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/utils/localized_names.dart';
import '../../../core/api/services_api.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/services_providers.dart';
import '../widgets/service_grid_card.dart';

/// Экран 43 «Избранное»: сетка сохранённых, ♡ на карточке = убрать.
class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final favoritesAsync = ref.watch(favoritesProvider);
    final categories =
        ref.watch(categoriesProvider).valueOrNull ?? const <ServiceCategory>[];

    String categoryName(int id) {
      for (final c in categories) {
        if (c.id == id) return localizedName(context, c.nameRu, c.nameEn);
      }
      return '';
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.favoritesTitle)),
      body: SafeArea(
        child: favoritesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, st) => Center(
            child: TextButton(
              onPressed: () => ref.invalidate(favoritesProvider),
              child: Text(l10n.retry),
            ),
          ),
          data: (services) => services.isEmpty
              ? EmptyState(
                  icon: Icons.favorite_border_rounded,
                  title: l10n.favoritesEmptyTitle,
                  description: l10n.favoritesEmptyBody,
                  actionLabel: l10n.toServices,
                  onAction: () => context.pop(),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
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
                            isFavorite: true,
                            onTap: () => context.push('/services/${s.id}'),
                            onFavoriteTap: () async {
                              await ref
                                  .read(servicesApiProvider)
                                  .removeFavorite(s.id);
                              ref.invalidate(favoritesProvider);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
