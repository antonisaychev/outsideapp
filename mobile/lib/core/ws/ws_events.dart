import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../features/auth/providers/session_controller.dart';
import '../api/api_client.dart';

/// Событие с сервера: message.new / message.read / user.online /
/// user.offline / notification.new (backend/src/ws.js).
class WsEvent {
  const WsEvent(this.event, this.data);

  final String event;
  final dynamic data;
}

String get _wsUrl => '${apiBaseUrl.replaceFirst('http', 'ws')}/ws';

/// Живой поток WS-событий. Подключается только у залогиненного пользователя,
/// переподключается с паузой 3 сек при обрыве, закрывается при выходе
/// (за счёт watch(currentUserIdProvider) провайдер пересоздаётся).
final wsEventsProvider = StreamProvider<WsEvent>((ref) async* {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return; // гость — без сокета

  var disposed = false;
  ref.onDispose(() => disposed = true);

  while (!disposed) {
    WebSocketChannel? channel;
    try {
      final token = await ref.read(tokenStorageProvider).readAccessToken();
      if (token == null) return;
      channel = WebSocketChannel.connect(Uri.parse('$_wsUrl?token=$token'));
      ref.onDispose(() => channel?.sink.close());
      await for (final raw in channel.stream) {
        final map = jsonDecode(raw as String) as Map<String, dynamic>;
        yield WsEvent(map['event'] as String, map['data']);
      }
    } catch (_) {
      // обрыв соединения — переподключимся ниже
    }
    if (disposed) return;
    await Future<void>.delayed(const Duration(seconds: 3));
  }
});
