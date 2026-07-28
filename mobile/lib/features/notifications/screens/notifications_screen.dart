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
  /// id уведомлений, обработанных в этой сессии экрана → текст результата
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

  String _text(AppNotification n, AppLocalizations l10n) {
    switch (n.type) {
      case 'friend_request':
        return l10n.notifFriendRequest(n.actorName);
      case 'friend_accepted':
        return l10n.notifFriendAccepted(n.actorName);
      case 'match':
        return l10n.notifMatch(n.actorName);
      case 'service_recommended':
        return l10n.notifServiceRecommended(n.entityTitle ?? '');
      case 'service_hidden':
        return l10n.notifServiceHidden(n.entityTitle ?? '');
      default:
        return n.type;
    }
  }

  /// «5 минут назад», «2 часа назад», «Вчера» — как в макете
  String _relativeTime(DateTime time, AppLocalizations l10n) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return l10n.timeJustNow;
    if (diff.inMinutes < 60) return l10n.timeMinutesAgo(diff.inMinutes);
    if (diff.inHours < 24) return l10n.timeHoursAgo(diff.inHours);
    if (diff.inDays == 1) return l10n.timeYesterday;
    return l10n.timeDaysAgo(diff.inDays);
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

  /// id уведомлений, у которых показываем «Принять/Отклонить»
  final _actionable = <String>{};

  /// Кнопки — только у САМОГО СВЕЖЕГО friend_request от каждого отправителя
  /// и только если заявка ещё висит (старые записи остаются историей).
  List<AppNotification> _withActionFlags(
    List<AppNotification> items,
    Map<String, RelationStatus> statuses,
  ) {
    _actionable.clear();
    final seen = <String>{};
    for (final n in items) {
      if (n.type != 'friend_request' || n.actorId == null) continue;
      if (!seen.add(n.actorId!)) continue; // уже был свежее — этот в историю
      if (statuses[n.actorId] == RelationStatus.pendingIncoming) {
        _actionable.add(n.id);
      }
    }
    return items;
  }

  Future<void> _accept(AppNotification n, AppLocalizations l10n) async {
    await runFriendAction(
      ref,
      context,
      n.actorId,
      () => ref.read(friendsApiProvider).acceptRequest(n.actorId!),
    );
    if (mounted) setState(() => _handled[n.id] = l10n.nowFriends);
  }

  Future<void> _decline(AppNotification n, AppLocalizations l10n) async {
    await runFriendAction(
      ref,
      context,
      n.actorId,
      () => ref.read(friendsApiProvider).declineRequest(n.actorId!),
    );
    if (mounted) setState(() => _handled[n.id] = l10n.requestDeclined);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final listAsync = ref.watch(notificationsListProvider);
    // Статусы отношений: кнопки прячем, если заявка уже неактуальна
    final statusesAsync = ref.watch(
      relationStatusesProvider(
        (listAsync.valueOrNull ?? [])
            .where((n) => n.type == 'friend_request' && n.actorId != null)
            .map((n) => n.actorId!)
            .toSet()
            .join(','),
      ),
    );
    final statuses = statusesAsync.valueOrNull ?? const {};

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: listAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, st) => Center(
            child: TextButton(
              onPressed: () => ref.invalidate(notificationsListProvider),
              child: Text(l10n.retry),
            ),
          ),
          data: (items) => RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(notificationsListProvider);
              ref.invalidate(relationStatusesProvider);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                  child: Text(
                    l10n.notificationsTitle,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                ),
                if (items.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 80),
                    child: Center(
                      child: Text(
                        l10n.notificationsEmpty,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                for (final n in _withActionFlags(items, statuses))
                  _NotificationRow(
                    notification: n,
                    text: _text(n, l10n),
                    time: _relativeTime(n.createdAt, l10n),
                    handledLabel: _handled[n.id],
                    // Кнопки только у актуальной входящей заявки
                    showActions:
                        _actionable.contains(n.id) && _handled[n.id] == null,
                    onTap: () => _openTarget(n),
                    onAccept: () => _accept(n, l10n),
                    onDecline: () => _decline(n, l10n),
                    acceptLabel: l10n.acceptRequest,
                    declineLabel: l10n.declineRequest,
                  ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Строка уведомления по макету 18: аватар слева, текст на всю ширину,
/// под ним время, кнопки — отдельной строкой; непрочитанное с розовым фоном.
class _NotificationRow extends StatelessWidget {
  const _NotificationRow({
    required this.notification,
    required this.text,
    required this.time,
    required this.handledLabel,
    required this.showActions,
    required this.onTap,
    required this.onAccept,
    required this.onDecline,
    required this.acceptLabel,
    required this.declineLabel,
  });

  final AppNotification notification;
  final String text;
  final String time;
  final String? handledLabel;
  final bool showActions;
  final VoidCallback onTap;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final String acceptLabel;
  final String declineLabel;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: notification.isRead ? null : AppColors.coralTint,
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserAvatar(
              avatarUrl: notification.actorAvatarUrl,
              name: notification.actorName,
              radius: 22,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.35,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (handledLabel != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      handledLabel!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.coral,
                      ),
                    ),
                  ],
                  if (showActions) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(0, 40),
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                          ),
                          onPressed: onAccept,
                          child: Text(acceptLabel),
                        ),
                        const SizedBox(width: 10),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 40),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: AppColors.border),
                          ),
                          onPressed: onDecline,
                          child: Text(declineLabel),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
