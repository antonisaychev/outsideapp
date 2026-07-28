import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/admin_api.dart';
import '../../../core/api/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/localized_names.dart';
import '../../../core/widgets/selectable_chip.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/api/services_api.dart';
import '../../../core/api/users_api.dart';
import '../../services/providers/services_providers.dart';
import '../providers/admin_providers.dart';
import 'admin_screen.dart';

/// Экран 27 «Администрирование · Сервисы»: фильтр по статусу и действия.
class AdminServicesTab extends ConsumerWidget {
  const AdminServicesTab({super.key});

  Future<void> _run(
    BuildContext context,
    WidgetRef ref,
    Future<void> Function() action,
    String successText,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await action();
      ref.invalidate(adminServicesProvider);
      // список у пользователей тоже меняется — сбрасываем его кэш
      ref.invalidate(servicesListProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(successText)));
      }
    } on ApiException {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.genericError)));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final status = ref.watch(adminServiceStatusProvider);
    final categories = ref.watch(categoriesProvider).valueOrNull ?? [];
    final cities = ref.watch(citiesProvider).valueOrNull ?? [];

    final filters = <String?, String>{
      null: l10n.adminFilterAll,
      'pending': l10n.adminFilterPending,
      'recommended': l10n.adminFilterRecommended,
      'hidden': l10n.adminFilterHidden,
    };

    return AdminList<AdminService>(
      async: ref.watch(adminServicesProvider),
      emptyText: l10n.adminEmptyServices,
      onRefresh: () => ref.invalidate(adminServicesProvider),
      header: SizedBox(
        height: 44,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          children: [
            for (final e in filters.entries) ...[
              SelectableChip(
                selected: status == e.key,
                onTap: () =>
                    ref.read(adminServiceStatusProvider.notifier).state = e.key,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Text(e.value),
              ),
              const SizedBox(width: 8),
            ],
          ],
        ),
      ),
      itemBuilder: (context, service) {
        final cityName = cities
            .where((c) => c.id == service.cityId)
            .map((c) => localizedName(context, c.nameRu, c.nameEn))
            .firstOrNull;
        final categoryName = categories
            .where((c) => c.id == service.categoryId)
            .map((c) => localizedName(context, c.nameRu, c.nameEn))
            .firstOrNull;
        final statusText = switch (service.status) {
          'pending' => l10n.adminFilterPending,
          'hidden' => l10n.adminFilterHidden,
          _ => l10n.adminFilterRecommended,
        };

        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.small),
                    child: SizedBox(
                      width: 56,
                      height: 56,
                      child: service.photoUrl.isEmpty
                          ? Container(color: AppColors.surface)
                          : CachedNetworkImage(
                              imageUrl: absoluteFileUrl(service.photoUrl),
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  Container(color: AppColors.surface),
                              errorWidget: (context, url, error) =>
                                  Container(color: AppColors.surface),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          [
                            ?cityName,
                            ?categoryName,
                            statusText,
                            if (service.isPending)
                              '${service.confirmCount}/30'
                            else
                              '👍 ${service.likesCount}',
                          ].join(' · '),
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  if (service.isPending) ...[
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 36),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        textStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: () => _run(
                        context,
                        ref,
                        () => ref
                            .read(adminApiProvider)
                            .approveService(service.id),
                        l10n.adminServiceApproved,
                      ),
                      child: Text(l10n.adminApprove),
                    ),
                    const SizedBox(width: 8),
                  ],
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 36),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      textStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: () => context.push('/admin/services/${service.id}'),
                    child: Text(l10n.adminEdit),
                  ),
                  if (!service.isHidden) ...[
                    const SizedBox(width: 8),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 36),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        textStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: () => _run(
                        context,
                        ref,
                        () =>
                            ref.read(adminApiProvider).hideService(service.id),
                        l10n.adminServiceHidden,
                      ),
                      child: Text(l10n.adminHide),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
