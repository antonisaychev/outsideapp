import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/friends_api.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../../l10n/app_localizations.dart';
import '../../friends/providers/friends_providers.dart';

/// Экран 34 «Заблокированные».
class BlockedUsersScreen extends ConsumerWidget {
  const BlockedUsersScreen({super.key});

  Future<void> _unblock(
    BuildContext context,
    WidgetRef ref,
    String userId,
    String name,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.unblockConfirmTitle(name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.unblockUser),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(friendsApiProvider).unblockUser(userId);
      ref.invalidate(blockedUsersProvider);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final blockedAsync = ref.watch(blockedUsersProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.blockedScreenTitle)),
      body: SafeArea(
        child: blockedAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, st) => Center(
            child: TextButton(
              onPressed: () => ref.invalidate(blockedUsersProvider),
              child: Text(l10n.retry),
            ),
          ),
          data: (users) => users.isEmpty
              ? Center(
                  child: Text(
                    l10n.blockedListEmpty,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                )
              : ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final u = users[index];
                    return ListTile(
                      leading: UserAvatar(
                        avatarUrl: u.avatarUrl,
                        name: u.displayName,
                      ),
                      title: Text(
                        u.displayName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      trailing: TextButton(
                        onPressed: () =>
                            _unblock(context, ref, u.id, u.displayName),
                        child: Text(l10n.unblockUser),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
