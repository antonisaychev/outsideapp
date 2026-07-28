import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/friends_api.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/providers/session_controller.dart';
import '../../friends/providers/friends_providers.dart';
import '../providers/chats_providers.dart';
import '../widgets/read_ticks.dart';

/// Экран 09 «Чат»: optimistic-отправка, ✓/✓✓, подгрузка истории вверх.
/// Высота поля ввода и круглой кнопки отправки — одно значение на двоих,
/// иначе они не совпадают по краям (QA_NOTES №58)
const double _composerHeight = 48;

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.peerId,
  });

  final String conversationId;
  final String peerId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      // reverse: true — конец списка (старые сообщения) это maxScrollExtent
      if (_scrollController.position.pixels >
          _scrollController.position.maxScrollExtent - 200) {
        ref
            .read(chatControllerProvider(widget.conversationId).notifier)
            .loadMore();
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();
    setState(() {});
    ref.read(chatControllerProvider(widget.conversationId).notifier).send(text);
  }

  Future<void> _messageActions(LocalMessage m) async {
    final l10n = AppLocalizations.of(context)!;
    if (m.message.isDeleted || m.status != LocalMessageStatus.sent) return;
    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.error),
              title: Text(
                l10n.deleteMessage,
                style: const TextStyle(color: AppColors.error),
              ),
              onTap: () async {
                Navigator.of(sheetContext).pop();
                final ok = await ref
                    .read(
                      chatControllerProvider(widget.conversationId).notifier,
                    )
                    .deleteMessage(m.message.id);
                if (!ok && mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(l10n.genericError)));
                }
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

  String _formatTime(DateTime time) {
    final local = time.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final chat = ref.watch(chatControllerProvider(widget.conversationId));
    final myId = ref.watch(currentUserIdProvider);
    final peerAsync = ref.watch(publicProfileProvider(widget.peerId));
    final relationAsync = ref.watch(relationStatusProvider(widget.peerId));
    final peer = peerAsync.valueOrNull;
    // Плашка вместо ввода: собеседник не друг/заблокирован/удалён
    final blocked =
        chat.cannotMessage ||
        (relationAsync.valueOrNull != null &&
            relationAsync.valueOrNull != RelationStatus.accepted);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: GestureDetector(
          onTap: () => context.push('/users/${widget.peerId}'),
          child: Row(
            children: [
              UserAvatar(
                avatarUrl: peer?.avatarUrl,
                name: peer?.displayName,
                radius: 18,
                isOnline: peer?.isOnline ?? false,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  peer?.displayName ?? '',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: chat.loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      itemCount:
                          chat.messages.length + (chat.loadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= chat.messages.length) {
                          return const Padding(
                            padding: EdgeInsets.all(12),
                            child: Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          );
                        }
                        final m = chat.messages[index];
                        final isMine = m.message.senderId == myId;
                        return _MessageBubble(
                          message: m,
                          isMine: isMine,
                          time: _formatTime(m.message.createdAt),
                          onRetry: () => ref
                              .read(
                                chatControllerProvider(
                                  widget.conversationId,
                                ).notifier,
                              )
                              .retry(m.localId),
                          onLongPress: isMine ? () => _messageActions(m) : null,
                          retryLabel: l10n.retry,
                          deletedLabel: l10n.messageDeleted,
                        );
                      },
                    ),
            ),
            if (blocked)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: AppColors.surface,
                child: Text(
                  l10n.cannotMessageUser,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(
                  // Кнопка тянется по высоте поля — центры и края совпадают
                  // при любой высоте текста (QA_NOTES №58)
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        maxLines: 5,
                        minLines: 1,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(2000),
                        ],
                        onChanged: (_) => setState(() {}),
                        // Поле-«таблетка» как в макете 09: тот же размер,
                        // что и круглая кнопка рядом
                        decoration: InputDecoration(
                          hintText: l10n.messageHint,
                          filled: true,
                          fillColor: AppColors.surface,
                          isDense: true,
                          constraints: const BoxConstraints(
                            minHeight: _composerHeight,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              _composerHeight / 2,
                            ),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              _composerHeight / 2,
                            ),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              _composerHeight / 2,
                            ),
                            borderSide: const BorderSide(
                              color: AppColors.coral,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Круглая кнопка: иконка строго по центру
                    GestureDetector(
                      onTap: _textController.text.trim().isEmpty ? null : _send,
                      child: Container(
                        width: _composerHeight,
                        height: _composerHeight,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _textController.text.trim().isEmpty
                              ? AppColors.border
                              : AppColors.coral,
                        ),
                        child: const Icon(
                          Icons.arrow_upward_rounded,
                          size: 22,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.isMine,
    required this.time,
    required this.onRetry,
    required this.onLongPress,
    required this.retryLabel,
    required this.deletedLabel,
  });

  final LocalMessage message;
  final bool isMine;
  final String time;
  final VoidCallback onRetry;
  final VoidCallback? onLongPress;
  final String retryLabel;
  final String deletedLabel;

  @override
  Widget build(BuildContext context) {
    final failed = message.status == LocalMessageStatus.failed;
    final deleted = message.message.isDeleted;
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onTap: failed ? onRetry : null,
        onLongPress: deleted ? null : onLongPress,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 3),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          decoration: BoxDecoration(
            color: deleted
                ? AppColors.surface
                : (isMine ? AppColors.coral : AppColors.surface),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(isMine ? 18 : 4),
              bottomRight: Radius.circular(isMine ? 4 : 18),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                deleted ? deletedLabel : message.message.text,
                style: TextStyle(
                  fontSize: 15,
                  fontStyle: deleted ? FontStyle.italic : FontStyle.normal,
                  color: deleted
                      ? AppColors.textSecondary
                      : (isMine ? Colors.white : AppColors.textPrimary),
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (failed) ...[
                    Icon(
                      Icons.error_outline,
                      size: 14,
                      color: Colors.red.shade200,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      retryLabel,
                      style: TextStyle(
                        fontSize: 11,
                        color: isMine
                            ? Colors.white70
                            : AppColors.textSecondary,
                      ),
                    ),
                  ] else ...[
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 11,
                        color: isMine
                            ? Colors.white70
                            : AppColors.textSecondary,
                      ),
                    ),
                    if (isMine) ...[
                      const SizedBox(width: 4),
                      message.status == LocalMessageStatus.sending
                          ? const SizedBox(
                              width: 10,
                              height: 10,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                                color: Colors.white70,
                              ),
                            )
                          : ReadTicks(read: message.message.readAt != null),
                    ],
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
