import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/admin_api.dart';
import '../../../core/api/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/admin_providers.dart';
import 'admin_screen.dart';

/// Экран 26 «Администрирование · Пользователи».
class AdminUsersTab extends ConsumerStatefulWidget {
  const AdminUsersTab({super.key});

  @override
  ConsumerState<AdminUsersTab> createState() => _AdminUsersTabState();
}

class _AdminUsersTabState extends ConsumerState<AdminUsersTab> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _block(AdminUser user) async {
    final l10n = AppLocalizations.of(context)!;
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => _BlockDialog(user: user),
    );
    if (reason == null || !mounted) return;
    try {
      await ref.read(adminApiProvider).blockUser(user.id, reason);
      ref.invalidate(adminUsersProvider);
      if (mounted) _toast(l10n.adminUserBlocked);
    } on ApiException {
      if (mounted) _toast(l10n.genericError);
    }
  }

  Future<void> _unblock(AdminUser user) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await ref.read(adminApiProvider).unblockUser(user.id);
      ref.invalidate(adminUsersProvider);
      if (mounted) _toast(l10n.adminUserUnblocked);
    } on ApiException {
      if (mounted) _toast(l10n.genericError);
    }
  }

  void _toast(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AdminList<AdminUser>(
      async: ref.watch(adminUsersProvider),
      emptyText: l10n.adminEmptyUsers,
      onRefresh: () => ref.invalidate(adminUsersProvider),
      header: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
        child: TextField(
          controller: _search,
          decoration: InputDecoration(hintText: l10n.adminSearchUsersHint),
          onChanged: (v) =>
              ref.read(adminUserQueryProvider.notifier).state = v.trim(),
        ),
      ),
      itemBuilder: (context, user) => InkWell(
        // тап по строке открывает профиль, «назад» возвращает в админку
        onTap: () => context.push('/users/${user.id}'),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName,
                      style: AppText.callout.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      [
                        user.email,
                        if (user.isBlocked) l10n.adminBlockedLabel,
                      ].join(' · '),
                      style: AppText.small,
                    ),
                    if (user.isBlocked &&
                        (user.blockedReason?.isNotEmpty ?? false))
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          user.blockedReason!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Админа не блокируем, удалённого — некого блокировать
              if (user.isDeleted)
                Text(
                  l10n.adminDeletedLabel,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                )
              else if (user.isAdmin)
                Text(
                  l10n.adminRoleLabel,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                )
              else
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    foregroundColor: user.isBlocked
                        ? AppColors.success
                        : AppColors.error,
                    side: BorderSide(
                      color: user.isBlocked
                          ? AppColors.success
                          : AppColors.error,
                    ),
                    textStyle: AppText.smallMedium.copyWith(fontWeight: FontWeight.w600),
                  ),
                  onPressed: () =>
                      user.isBlocked ? _unblock(user) : _block(user),
                  child: Text(
                    user.isBlocked ? l10n.adminUnblock : l10n.adminBlock,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Экран 39 «Админ — блокировка»: причина обязательна.
class _BlockDialog extends StatefulWidget {
  const _BlockDialog({required this.user});

  final AdminUser user;

  @override
  State<_BlockDialog> createState() => _BlockDialogState();
}

class _BlockDialogState extends State<_BlockDialog> {
  final _reason = TextEditingController();

  @override
  void initState() {
    super.initState();
    _reason.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.adminBlockTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${widget.user.displayName} · ${widget.user.email}',
            style: AppText.small,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _reason,
            maxLines: 2,
            autofocus: true,
            decoration: InputDecoration(hintText: l10n.adminBlockReasonHint),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.adminBlockNote,
            style: const TextStyle(
              fontSize: 12,
              height: 1.35,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
          onPressed: _reason.text.trim().isEmpty
              ? null
              : () => Navigator.of(context).pop(_reason.text.trim()),
          child: Text(l10n.adminBlock),
        ),
      ],
    );
  }
}
