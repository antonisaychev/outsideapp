import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client.dart';

/// Диалог в списке «Сообщения» (GET /chats).
class Conversation {
  Conversation({
    required this.id,
    required this.peerId,
    required this.peerUsername,
    this.peerFirstName,
    this.peerLastName,
    this.peerAvatarUrl,
    this.lastMessageText,
    this.lastMessageAt,
    this.unreadCount = 0,
    this.lastMessageDeleted = false,
    this.isOnline = false,
  });

  final String id;
  final String peerId;
  final String peerUsername;
  final String? peerFirstName;
  final String? peerLastName;
  final String? peerAvatarUrl;
  final String? lastMessageText;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final bool lastMessageDeleted;

  /// Собеседник заходил за последние 5 минут
  final bool isOnline;

  String get peerName {
    final name = [
      peerFirstName,
      peerLastName,
    ].where((s) => s != null && s.isNotEmpty).join(' ');
    return name.isEmpty ? '@$peerUsername' : name;
  }

  factory Conversation.fromJson(Map<String, dynamic> json) => Conversation(
    id: json['id'] as String,
    peerId: json['other_id'] as String,
    peerUsername: json['username'] as String,
    peerFirstName: json['first_name'] as String?,
    peerLastName: json['last_name'] as String?,
    peerAvatarUrl: json['avatar_url'] as String?,
    lastMessageText: json['last_message_text'] as String?,
    lastMessageAt: json['last_message_at'] != null
        ? DateTime.tryParse(json['last_message_at'] as String)
        : null,
    unreadCount: (json['unread_count'] as int?) ?? 0,
    lastMessageDeleted: (json['last_message_deleted'] as bool?) ?? false,
    isOnline: (json['is_online'] as bool?) ?? false,
  );
}

/// Сообщение (GET /chats/:id/messages, POST /chats/:id/messages, WS message.new).
class ChatMessage {
  ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.createdAt,
    this.readAt,
    this.deletedAt,
  });

  final String id;
  final String senderId;
  final String text;
  final DateTime createdAt;
  final DateTime? readAt;
  final DateTime? deletedAt;

  bool get isDeleted => deletedAt != null;

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    id: json['id'] as String,
    senderId: json['sender_id'] as String,
    text: json['text'] as String,
    createdAt: DateTime.parse(json['created_at'] as String),
    readAt: json['read_at'] != null
        ? DateTime.tryParse(json['read_at'] as String)
        : null,
    deletedAt: json['deleted_at'] != null
        ? DateTime.tryParse(json['deleted_at'] as String)
        : null,
  );

  ChatMessage copyWith({DateTime? readAt, DateTime? deletedAt}) => ChatMessage(
    id: id,
    senderId: senderId,
    text: text,
    createdAt: createdAt,
    readAt: readAt ?? this.readAt,
    deletedAt: deletedAt ?? this.deletedAt,
  );
}

class ChatsApi {
  ChatsApi(this._dio);
  final Dio _dio;

  Future<List<Conversation>> conversations() async {
    try {
      final r = await _dio.get('/chats');
      return (r.data as List)
          .map((e) => Conversation.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw toApiException(e);
    }
  }

  /// Найти/создать диалог с другом. Возвращает id диалога.
  Future<String> openWith(String userId) async {
    try {
      final r = await _dio.post('/chats', data: {'user_id': userId});
      return r.data['id'] as String;
    } on DioException catch (e) {
      throw toApiException(e);
    }
  }

  Future<List<ChatMessage>> messages(
    String conversationId, {
    DateTime? before,
    int limit = 30,
  }) async {
    try {
      final r = await _dio.get(
        '/chats/$conversationId/messages',
        queryParameters: {
          'limit': limit,
          if (before != null) 'before': before.toIso8601String(),
        },
      );
      return (r.data as List)
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw toApiException(e);
    }
  }

  Future<ChatMessage> send(String conversationId, String text) async {
    try {
      final r = await _dio.post(
        '/chats/$conversationId/messages',
        data: {'text': text},
      );
      return ChatMessage.fromJson(r.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw toApiException(e);
    }
  }

  Future<void> deleteMessage(String conversationId, String messageId) async {
    try {
      await _dio.delete('/chats/$conversationId/messages/$messageId');
    } on DioException catch (e) {
      throw toApiException(e);
    }
  }

  Future<void> markRead(String conversationId) async {
    try {
      await _dio.post('/chats/$conversationId/read');
    } on DioException catch (e) {
      throw toApiException(e);
    }
  }
}

final chatsApiProvider = Provider<ChatsApi>(
  (ref) => ChatsApi(ref.read(dioProvider)),
);
