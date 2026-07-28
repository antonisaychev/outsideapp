import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/tab_header.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../../l10n/app_localizations.dart';
import '../../shell/tab_shell.dart';
import '../../auth/providers/session_controller.dart';
import '../providers/chats_providers.dart';

/// Экран 10 «Сообщения»: список диалогов, сортировка по последнему сообщению.
class ChatsTabScreen extends ConsumerWidget {
  const ChatsTabScreen({super.key});

  String _formatTime(BuildContext context, DateTime? time) {
    if (time == null) return '';
    final local = time.toLocal();
    final now = DateTime.now();
    final isToday =
        local.year == now.year &&
        local.month == now.month &&
        local.day == now.day;
    if (isToday) {
      return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
    }
    return '${local.day.toString().padLeft(2, '0')}.${local.month.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final session = ref.watch(sessionControllerProvider);

    // Гость — приглашение войти (сообщения только для друзей)
    if (session.status != SessionStatus.ready) {
      return SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.guestMessagesTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.push('/register'),
                  child: Text(l10n.createAccount),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => context.push('/login'),
                  child: Text(l10n.login),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final conversationsAsync = ref.watch(conversationsProvider);
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TabHeader(
            title: l10n.messagesTitle,
            actions: const [NotificationsBellButton()],
          ),
          Expanded(
            child: conversationsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, st) => Center(
                child: TextButton(
                  onPressed: () => ref.invalidate(conversationsProvider),
                  child: Text(l10n.retry),
                ),
              ),
              data: (conversations) => RefreshIndicator(
                onRefresh: () async => ref.invalidate(conversationsProvider),
                child: conversations.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height: MediaQuery.sizeOf(context).height * 0.6,
                            child: EmptyState(
                              icon: Icons.chat_bubble_outline_rounded,
                              title: l10n.chatsEmptyTitle,
                              description: l10n.chatsEmptyBody,
                              actionLabel: l10n.toFriends,
                              onAction: () => ref
                                  .read(shellTabIndexProvider.notifier)
                                  .state = ShellTab.friends,
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: conversations.length,
                        itemBuilder: (context, index) {
                          final c = conversations[index];
                          return ListTile(
                            onTap: () =>
                                context.push('/chats/${c.id}?peer=${c.peerId}'),
                            leading: UserAvatar(
                              avatarUrl: c.peerAvatarUrl,
                              name: c.peerName,
                              isOnline: c.isOnline,
                            ),
                            title: Text(
                              c.peerName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              c.lastMessageDeleted
                                  ? l10n.messageDeleted
                                  : (c.lastMessageText ?? ''),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: c.lastMessageDeleted
                                  ? const TextStyle(fontStyle: FontStyle.italic)
                                  : null,
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  _formatTime(context, c.lastMessageAt),
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(fontSize: 12),
                                ),
                                const SizedBox(height: 4),
                                if (c.unreadCount > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 7,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.coral,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${c.unreadCount}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  )
                                else
                                  const SizedBox(height: 18),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
