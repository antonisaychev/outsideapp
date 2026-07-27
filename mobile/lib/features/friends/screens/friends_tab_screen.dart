import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/friends_api.dart';
import '../../../core/api/models.dart';
import '../../../core/api/users_api.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/friends_providers.dart';

/// Экран 11 «Друзья»: табы Мои друзья / Входящие · N / Исходящие.
class FriendsTabScreen extends ConsumerStatefulWidget {
  const FriendsTabScreen({super.key});

  @override
  ConsumerState<FriendsTabScreen> createState() => _FriendsTabScreenState();
}

class _FriendsTabScreenState extends ConsumerState<FriendsTabScreen> {
  int _tab = 0;

  Future<void> _accept(String userId) => runFriendAction(
    ref,
    context,
    userId,
    () => ref.read(friendsApiProvider).acceptRequest(userId),
  );

  Future<void> _decline(String userId) => runFriendAction(
    ref,
    context,
    userId,
    () => ref.read(friendsApiProvider).declineRequest(userId),
  );

  Future<void> _cancel(String userId) => runFriendAction(
    ref,
    context,
    userId,
    () => ref.read(friendsApiProvider).cancelRequest(userId),
  );

  Future<void> _friendActionsSheet(UserListItem friend) async {
    final l10n = AppLocalizations.of(context)!;
    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 4),
              child: Text(
                friend.displayName,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.chat_bubble_outline),
              title: Text(l10n.writeMessage),
              onTap: () {
                Navigator.of(sheetContext).pop();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(l10n.comingSoonSection)));
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.person_remove_outlined,
                color: AppColors.error,
              ),
              title: Text(
                l10n.removeFriend,
                style: const TextStyle(color: AppColors.error),
              ),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _confirmRemove(friend);
              },
            ),
            ListTile(
              leading: const Icon(Icons.block, color: AppColors.error),
              title: Text(
                l10n.blockUser,
                style: const TextStyle(color: AppColors.error),
              ),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _confirmBlock(friend);
              },
            ),
            ListTile(
              title: Center(child: Text(l10n.cancel)),
              onTap: () => Navigator.of(sheetContext).pop(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmRemove(UserListItem friend) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.removeFriendTitle(friend.displayName)),
        content: Text(l10n.removeFriendWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              l10n.removeFriendConfirm,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      if (!mounted) return;
      await runFriendAction(
        ref,
        context,
        friend.id,
        () => ref.read(friendsApiProvider).removeFriend(friend.id),
      );
    }
  }

  Future<void> _confirmBlock(UserListItem friend) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.blockUserTitle(friend.displayName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              l10n.blockUser,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      if (!mounted) return;
      await runFriendAction(
        ref,
        context,
        friend.id,
        () => ref.read(friendsApiProvider).blockUser(friend.id),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final incoming = ref.watch(incomingRequestsProvider).valueOrNull ?? [];
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 12, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.tabFriends,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () => context.push('/people-search'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  _TabLabel(
                    text: l10n.friendsTabMy,
                    active: _tab == 0,
                    onTap: () => _switchTab(0),
                  ),
                  const SizedBox(width: 16),
                  _TabLabel(
                    text: incoming.isEmpty
                        ? l10n.friendsTabIncoming
                        : '${l10n.friendsTabIncoming} · ${incoming.length}',
                    active: _tab == 1,
                    onTap: () => _switchTab(1),
                  ),
                  const SizedBox(width: 16),
                  _TabLabel(
                    text: l10n.friendsTabOutgoing,
                    active: _tab == 2,
                    onTap: () => _switchTab(2),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(child: _buildTabContent(l10n)),
          ],
        ),
      ),
    );
  }

  /// Переключение таба всегда перезапрашивает его список — иначе на другом
  /// устройстве не видно свежих заявок (см. QA_NOTES №23)
  void _switchTab(int tab) {
    switch (tab) {
      case 1:
        ref.invalidate(incomingRequestsProvider);
      case 2:
        ref.invalidate(outgoingRequestsProvider);
      default:
        ref.invalidate(friendsListProvider);
    }
    setState(() => _tab = tab);
  }

  Widget _buildTabContent(AppLocalizations l10n) {
    switch (_tab) {
      case 1:
        return _buildIncoming(l10n);
      case 2:
        return _buildOutgoing(l10n);
      default:
        return _buildFriends(l10n);
    }
  }

  Widget _buildFriends(AppLocalizations l10n) {
    final friendsAsync = ref.watch(friendsListProvider);
    final cities = ref.watch(citiesProvider).valueOrNull ?? const <City>[];
    String cityName(int? id) {
      for (final c in cities) {
        if (c.id == id) return c.nameRu;
      }
      return '';
    }

    return friendsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, st) => Center(
        child: TextButton(
          onPressed: () => ref.invalidate(friendsListProvider),
          child: Text(l10n.retry),
        ),
      ),
      data: (friends) => RefreshIndicator(
        onRefresh: () async => invalidateFriendship(ref),
        child: friends.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 120),
                    child: Column(
                      children: [
                        Text(
                          l10n.friendsEmpty,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => context.push('/people-search'),
                          child: Text(l10n.findPeople),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: friends.length,
                itemBuilder: (context, index) {
                  final f = friends[index];
                  return ListTile(
                    onTap: () => context.push('/users/${f.id}'),
                    leading: UserAvatar(
                      avatarUrl: f.avatarUrl,
                      name: f.displayName,
                    ),
                    title: Text(
                      f.displayName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(cityName(f.cityId)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chat_bubble_outline),
                          onPressed: () =>
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(l10n.comingSoonSection)),
                              ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.more_horiz),
                          onPressed: () => _friendActionsSheet(f),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildIncoming(AppLocalizations l10n) {
    final incomingAsync = ref.watch(incomingRequestsProvider);
    final cities = ref.watch(citiesProvider).valueOrNull ?? const <City>[];
    String cityName(int? id) {
      for (final c in cities) {
        if (c.id == id) return c.nameRu;
      }
      return '';
    }

    return incomingAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, st) => Center(
        child: TextButton(
          onPressed: () => ref.invalidate(incomingRequestsProvider),
          child: Text(l10n.retry),
        ),
      ),
      data: (requests) => RefreshIndicator(
        onRefresh: () async => ref.invalidate(incomingRequestsProvider),
        child: requests.isEmpty
            ? _EmptyScrollable(text: l10n.incomingEmpty)
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final r = requests[index];
                  final city = cityName(r.cityId);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.coralTint,
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () => context.push('/users/${r.id}'),
                          child: Row(
                            children: [
                              UserAvatar(
                                avatarUrl: r.avatarUrl,
                                name: r.displayName,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      r.displayName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      city.isEmpty
                                          ? l10n.wantsToBeFriends
                                          : '$city · ${l10n.wantsToBeFriends}',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(0, 44),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                              ),
                              onPressed: () => _accept(r.id),
                              child: Text(l10n.acceptRequest),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(0, 44),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                backgroundColor: Colors.white,
                                side: const BorderSide(color: AppColors.border),
                              ),
                              onPressed: () => _decline(r.id),
                              child: Text(l10n.declineRequest),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildOutgoing(AppLocalizations l10n) {
    final outgoingAsync = ref.watch(outgoingRequestsProvider);
    return outgoingAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, st) => Center(
        child: TextButton(
          onPressed: () => ref.invalidate(outgoingRequestsProvider),
          child: Text(l10n.retry),
        ),
      ),
      data: (requests) => RefreshIndicator(
        onRefresh: () async => ref.invalidate(outgoingRequestsProvider),
        child: requests.isEmpty
            ? _EmptyScrollable(text: l10n.outgoingEmpty)
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final r = requests[index];
                  return ListTile(
                    onTap: () => context.push('/users/${r.id}'),
                    leading: UserAvatar(
                      avatarUrl: r.avatarUrl,
                      name: r.displayName,
                    ),
                    title: Text(
                      r.displayName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    trailing: TextButton(
                      onPressed: () => _cancel(r.id),
                      child: Text(l10n.cancelRequest),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

/// Пустое состояние, которое можно «потянуть вниз» для обновления.
class _EmptyScrollable extends StatelessWidget {
  const _EmptyScrollable({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 120),
          child: Center(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ),
      ],
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
              fontSize: 15,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              color: active ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 3,
            width: 40,
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
