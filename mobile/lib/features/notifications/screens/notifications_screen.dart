import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/friends_api.dart';
import '../../../core/api/notifications_api.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../../l10n/app_localizations.dart';
import '../../friends/providers/friends_providers.dart';
import '../providers/notifications_providers.dart';

/// Экран 18 «Уведомления»: открытие = read-all, заявки принимаются
/// прямо из строки, тап ведёт на соответствующий экран.
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  /// id отправителей, чьи заявки уже обработаны в этой сессии экрана
  final _handled = <String, String>{};

  @override
  void initState() {
    super.initState();
    // Список читается при открытии — бейдж обнуляем после загрузки
    Future.microtask(() async {
      await ref.read(notificationsListProvider.future);
      if (mounted) ref.invalidate(unreadNotificationsProvider);
    });
  }

  String _title(AppNotification n, AppLocalizations l10n) {
    switch (n.type) {
      case 'friend_request':
        return l10n.notifFriendRequest(n.actorName);
      case 'friend_accepted':
        return l10n.notifFriendAccepted(n.actorName);
      case 'match':
        return l10n.notifMatch(n.actorName);
      case 'service_recommended':
        return l10n.notifServiceRecommended;
      case 'service_hidden':
        return l10n.notifServiceHidden;
      default:
        return n.type;
    }
  }

  void _openTarget(AppNotification n) {
    switch (n.type) {
      case 'friend_request':
      case 'friend_accepted':
      case 'match':
        if (n.actorId != null) context.push('/users/${n.actorId}');
      case 'service_recommended':
      case 'service_hidden':
        if (n.entityId != null) context.push('/services/${n.entityId}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final listAsync = ref.watch(notificationsListProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.notificationsTitle)),
      body: SafeArea(
        child: listAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, st) => Center(
            child: TextButton(
              onPressed: () => ref.invalidate(notificationsListProvider),
              child: Text(l10n.retry),
            ),
          ),
          data: (items) => items.isEmpty
              ? Center(
                  child: Text(
                    l10n.notificationsEmpty,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async =>
                      ref.invalidate(notificationsListProvider),
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final n = items[index];
                      final handled = _handled[n.id];
                      return ListTile(
                        onTap: () => _openTarget(n),
                        leading: UserAvatar(
                          avatarUrl: n.actorAvatarUrl,
                          name: n.actorName,
                        ),
                        title: Text(_title(n, l10n)),
                        subtitle: handled != null
                            ? Text(
                                handled,
                                style: const TextStyle(
                                  color: AppColors.coral,
                                  fontSize: 13,
                                ),
                              )
                            : null,
                        // Принять/Отклонить прямо в строке (спека, экран 18)
                        trailing:
                            n.type == 'friend_request' &&
                                n.actorId != null &&
                                handled == null
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextButton(
                                    onPressed: () async {
                                      await runFriendAction(
                                        ref,
                                        context,
                                        n.actorId,
                                        () => ref
                                            .read(friendsApiProvider)
                                            .acceptRequest(n.actorId!),
                                      );
                                      setState(
                                        () => _handled[n.id] = l10n.nowFriends,
                                      );
                                    },
                                    child: Text(l10n.acceptRequest),
                                  ),
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      foregroundColor: AppColors.textSecondary,
                                    ),
                                    onPressed: () async {
                                      await runFriendAction(
                                        ref,
                                        context,
                                        n.actorId,
                                        () => ref
                                            .read(friendsApiProvider)
                                            .declineRequest(n.actorId!),
                                      );
                                      setState(
                                        () => _handled[n.id] =
                                            l10n.requestDeclined,
                                      );
                                    },
                                    child: Text(l10n.declineRequest),
                                  ),
                                ],
                              )
                            : null,
                      );
                    },
                  ),
                ),
        ),
      ),
    );
  }
}
