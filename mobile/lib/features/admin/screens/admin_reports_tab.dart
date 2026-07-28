import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/admin_api.dart';
import '../../../core/api/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/admin_providers.dart';
import 'admin_screen.dart';

/// Экран 28 «Администрирование · Жалобы».
/// «Принять меры» — шторка: открыть объект, скрыть/заблокировать, закрыть жалобу.
class AdminReportsTab extends ConsumerWidget {
  const AdminReportsTab({super.key});

  Future<void> _openActions(
    BuildContext context,
    WidgetRef ref,
    AdminReport report,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final isService = report.kind == 'service';
    final action = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.open_in_new),
              title: Text(l10n.adminActionOpen),
              onTap: () => Navigator.of(context).pop('open'),
            ),
            ListTile(
              leading: Icon(
                isService ? Icons.visibility_off_outlined : Icons.block,
                color: AppColors.error,
              ),
              title: Text(
                isService ? l10n.adminActionHideService : l10n.adminBlock,
                style: const TextStyle(color: AppColors.error),
              ),
              onTap: () => Navigator.of(context).pop('punish'),
            ),
            ListTile(
              leading: const Icon(Icons.check_circle_outline),
              title: Text(l10n.adminActionResolve),
              onTap: () => Navigator.of(context).pop('resolve'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (action == null || !context.mounted) return;

    final api = ref.read(adminApiProvider);
    try {
      switch (action) {
        case 'open':
          context.push(
            isService
                ? '/services/${report.targetId}'
                : '/users/${report.targetId}',
          );
          return;
        case 'punish':
          if (isService) {
            await api.hideService(report.targetId);
            await api.resolveReport(report.kind, report.id);
          } else {
            // Блокировка требует причины — используем текст жалобы как основу
            if (!context.mounted) return;
            final reason = await _askReason(context, report);
            if (reason == null) return;
            await api.blockUser(report.targetId, reason);
            await api.resolveReport(report.kind, report.id);
          }
        case 'resolve':
          await api.resolveReport(report.kind, report.id);
      }
      ref.invalidate(adminReportsProvider);
      ref.invalidate(adminServicesProvider);
      ref.invalidate(adminUsersProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.adminReportResolved)));
      }
    } on ApiException {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.genericError)));
      }
    }
  }

  Future<String?> _askReason(BuildContext context, AdminReport report) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: report.comment ?? '');
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.adminBlockTitle),
        content: TextField(
          controller: controller,
          maxLines: 2,
          autofocus: true,
          decoration: InputDecoration(hintText: l10n.adminBlockReasonHint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) Navigator.of(context).pop(text);
            },
            child: Text(l10n.adminBlock),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return AdminList<AdminReport>(
      async: ref.watch(adminReportsProvider),
      emptyText: l10n.adminEmptyReports,
      onRefresh: () => ref.invalidate(adminReportsProvider),
      itemBuilder: (context, report) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                report.kind == 'service'
                    ? l10n.adminReportOnService(report.targetLabel)
                    : l10n.adminReportOnUser(report.targetLabel),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                [
                  if (report.comment?.isNotEmpty ?? false)
                    '«${report.comment}»'
                  else
                    report.reasonType,
                  l10n.adminReportFrom('@${report.reporterUsername}'),
                ].join(' '),
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.35,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 38),
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: () => _openActions(context, ref, report),
                child: Text(l10n.adminTakeAction),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
