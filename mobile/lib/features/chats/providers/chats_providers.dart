import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/chats_api.dart';
import '../../../core/ws/ws_events.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/providers/session_controller.dart';

/// Активная вкладка таб-шелла (вынесена в провайдер, чтобы экраны могли
/// переключать вкладки — например «К друзьям» из пустых сообщений).
/// Стартовая вкладка — «Сервисы» (ShellTab.services)
final shellTabIndexProvider = StateProvider<int>((ref) => 2);

/// «Написать» из любого места: найти/создать диалог и открыть его.
Future<void> openChatWith(
  BuildContext context,
  WidgetRef ref,
  String userId,
) async {
  final l10n = AppLocalizations.of(context)!;
  try {
    final conversationId = await ref.read(chatsApiProvider).openWith(userId);
    if (context.mounted) {
      context.push('/chats/$conversationId?peer=$userId');
    }
  } on ApiException catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.error == 'NOT_FRIENDS'
                ? l10n.cannotMessageUser
                : l10n.genericError,
          ),
        ),
      );
    }
  }
}

/// Список диалогов: user-scoped + обновляется по WS-событиям сообщений.
final conversationsProvider = FutureProvider<List<Conversation>>((ref) {
  ref.watch(currentUserIdProvider);
  // Любое message.new/message.read обновляет список (порядок, превью, бейджи)
  ref.listen(wsEventsProvider, (_, next) {
    final event = next.valueOrNull?.event;
    if (event == 'message.new' ||
        event == 'message.read' ||
        event == 'message.deleted') {
      ref.invalidateSelf();
    }
  });
  return ref.read(chatsApiProvider).conversations();
});

/// Суммарный бейдж непрочитанных для вкладки «Сообщения».
final totalUnreadProvider = Provider<int>((ref) {
  final conversations = ref.watch(conversationsProvider).valueOrNull ?? [];
  return conversations.fold(0, (sum, c) => sum + c.unreadCount);
});

/// Статус локального сообщения: отправляется / отправлено / ошибка.
enum LocalMessageStatus { sending, sent, failed }

class LocalMessage {
  const LocalMessage({
    required this.localId,
    required this.message,
    required this.status,
  });

  final String localId;
  final ChatMessage message;
  final LocalMessageStatus status;

  LocalMessage copyWith({ChatMessage? message, LocalMessageStatus? status}) =>
      LocalMessage(
        localId: localId,
        message: message ?? this.message,
        status: status ?? this.status,
      );
}

class ChatState {
  const ChatState({
    this.messages = const [],
    this.loading = true,
    this.loadingMore = false,
    this.hasMore = true,
    this.cannotMessage = false,
  });

  /// Новые первыми (как отдаёт API; ListView reverse: true).
  final List<LocalMessage> messages;
  final bool loading;
  final bool loadingMore;
  final bool hasMore;

  /// Плашка «Вы не можете писать этому пользователю» вместо поля ввода.
  final bool cannotMessage;

  ChatState copyWith({
    List<LocalMessage>? messages,
    bool? loading,
    bool? loadingMore,
    bool? hasMore,
    bool? cannotMessage,
  }) => ChatState(
    messages: messages ?? this.messages,
    loading: loading ?? this.loading,
    loadingMore: loadingMore ?? this.loadingMore,
    hasMore: hasMore ?? this.hasMore,
    cannotMessage: cannotMessage ?? this.cannotMessage,
  );
}

class ChatController extends StateNotifier<ChatState> {
  ChatController(this._ref, this.conversationId) : super(const ChatState()) {
    _load();
    // Входящие события этого диалога
    _ref.listen(wsEventsProvider, (_, next) {
      final e = next.valueOrNull;
      if (e == null) return;
      if (e.event == 'message.new') {
        final data = e.data as Map<String, dynamic>;
        if (data['conversation_id'] == conversationId) {
          _onIncoming(ChatMessage.fromJson(data));
        }
      } else if (e.event == 'message.read') {
        final data = e.data as Map<String, dynamic>;
        if (data['conversation_id'] == conversationId) {
          _markMineRead();
        }
      } else if (e.event == 'message.deleted') {
        final data = e.data as Map<String, dynamic>;
        if (data['conversation_id'] == conversationId) {
          _applyDeleted(data['message_id'] as String);
        }
      }
    });
  }

  final Ref _ref;
  final String conversationId;
  int _localSeq = 0;

  ChatsApi get _api => _ref.read(chatsApiProvider);

  String get _myId => _ref.read(currentUserIdProvider) ?? '';

  Future<void> _load() async {
    try {
      final messages = await _api.messages(conversationId);
      state = state.copyWith(
        messages: [
          for (final m in messages)
            LocalMessage(
              localId: m.id,
              message: m,
              status: LocalMessageStatus.sent,
            ),
        ],
        loading: false,
        hasMore: messages.length >= 30,
      );
      await markRead();
    } on ApiException {
      state = state.copyWith(loading: false);
    }
  }

  Future<void> loadMore() async {
    if (state.loadingMore || !state.hasMore || state.messages.isEmpty) return;
    state = state.copyWith(loadingMore: true);
    try {
      final oldest = state.messages.last.message.createdAt;
      final older = await _api.messages(conversationId, before: oldest);
      state = state.copyWith(
        messages: [
          ...state.messages,
          for (final m in older)
            LocalMessage(
              localId: m.id,
              message: m,
              status: LocalMessageStatus.sent,
            ),
        ],
        loadingMore: false,
        hasMore: older.length >= 30,
      );
    } on ApiException {
      state = state.copyWith(loadingMore: false);
    }
  }

  Future<void> send(String text) async {
    final localId =
        'local_${_localSeq++}_${DateTime.now().microsecondsSinceEpoch}';
    final optimistic = LocalMessage(
      localId: localId,
      message: ChatMessage(
        id: localId,
        senderId: _myId,
        text: text,
        createdAt: DateTime.now(),
      ),
      status: LocalMessageStatus.sending,
    );
    state = state.copyWith(messages: [optimistic, ...state.messages]);
    await _deliver(localId, text);
  }

  Future<void> retry(String localId) async {
    final failed = state.messages
        .where((m) => m.localId == localId)
        .firstOrNull;
    if (failed == null) return;
    _update(localId, (m) => m.copyWith(status: LocalMessageStatus.sending));
    await _deliver(localId, failed.message.text);
  }

  Future<void> _deliver(String localId, String text) async {
    try {
      final sent = await _api.send(conversationId, text);
      _update(
        localId,
        (m) => m.copyWith(message: sent, status: LocalMessageStatus.sent),
      );
    } on ApiException catch (e) {
      if (e.error == 'CANNOT_MESSAGE') {
        state = state.copyWith(cannotMessage: true);
      }
      _update(localId, (m) => m.copyWith(status: LocalMessageStatus.failed));
    }
  }

  void _update(String localId, LocalMessage Function(LocalMessage) fn) {
    state = state.copyWith(
      messages: [
        for (final m in state.messages)
          if (m.localId == localId) fn(m) else m,
      ],
    );
  }

  void _onIncoming(ChatMessage message) {
    // защита от дублей (история могла уже содержать это сообщение)
    if (state.messages.any((m) => m.message.id == message.id)) return;
    state = state.copyWith(
      messages: [
        LocalMessage(
          localId: message.id,
          message: message,
          status: LocalMessageStatus.sent,
        ),
        ...state.messages,
      ],
    );
    // экран открыт — сразу помечаем прочитанным
    markRead();
  }

  /// Удаление своего сообщения: текст скрывается у обоих, остаётся заглушка.
  /// Возвращает true при успехе — экран покажет ошибку, если false
  /// (молчаливый провал прятал «сервер не обновлён», см. QA_NOTES №30)
  Future<bool> deleteMessage(String messageId) async {
    try {
      await _api.deleteMessage(conversationId, messageId);
      _applyDeleted(messageId);
      _ref.invalidate(conversationsProvider);
      return true;
    } on ApiException {
      return false;
    }
  }

  void _applyDeleted(String messageId) {
    state = state.copyWith(
      messages: [
        for (final m in state.messages)
          if (m.message.id == messageId)
            m.copyWith(message: m.message.copyWith(deletedAt: DateTime.now()))
          else
            m,
      ],
    );
  }

  void _markMineRead() {
    final now = DateTime.now();
    state = state.copyWith(
      messages: [
        for (final m in state.messages)
          if (m.message.senderId == _myId && m.message.readAt == null)
            m.copyWith(message: m.message.copyWith(readAt: now))
          else
            m,
      ],
    );
  }

  Future<void> markRead() async {
    try {
      await _api.markRead(conversationId);
      _ref.invalidate(conversationsProvider);
    } on ApiException {
      // некритично — бейдж обновится при следующем открытии
    }
  }
}

final chatControllerProvider = StateNotifierProvider.autoDispose
    .family<ChatController, ChatState, String>(
      (ref, conversationId) => ChatController(ref, conversationId),
    );
