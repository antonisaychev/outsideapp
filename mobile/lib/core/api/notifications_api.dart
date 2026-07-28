import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client.dart';

/// Уведомление (GET /notifications). Типы с backend/src/utils/notify.js:
/// friend_request | friend_accepted | match | service_recommended |
/// service_hidden
class AppNotification {
  AppNotification({
    required this.id,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.entityId,
    this.actorId,
    this.actorUsername,
    this.actorFirstName,
    this.actorAvatarUrl,
    this.entityTitle,
    this.entityPhotoUrl,
  });

  final String id;
  final String type;
  final bool isRead;
  final DateTime createdAt;
  final String? entityId;
  final String? actorId;
  final String? actorUsername;
  final String? actorFirstName;
  final String? actorAvatarUrl;

  /// Название сервиса для уведомлений о карточках
  final String? entityTitle;

  /// Обложка сервиса — показываем вместо аватара в уведомлениях о карточках
  final String? entityPhotoUrl;

  String get actorName {
    if (actorFirstName != null && actorFirstName!.isNotEmpty) {
      return actorFirstName!;
    }
    return actorUsername != null ? '@$actorUsername' : '';
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      AppNotification(
        id: json['id'] as String,
        type: json['type'] as String,
        isRead: (json['is_read'] as bool?) ?? false,
        createdAt: DateTime.parse(json['created_at'] as String),
        entityId: json['entity_id'] as String?,
        actorId: json['actor_id'] as String?,
        actorUsername: json['actor_username'] as String?,
        actorFirstName: json['actor_first_name'] as String?,
        actorAvatarUrl: json['actor_avatar_url'] as String?,
        entityTitle: json['entity_title'] as String?,
        entityPhotoUrl: json['entity_photo_url'] as String?,
      );
}

class NotificationsApi {
  NotificationsApi(this._dio);
  final Dio _dio;

  Future<int> unreadCount() async {
    try {
      final r = await _dio.get('/notifications/unread-count');
      return (r.data['count'] as int?) ?? 0;
    } on DioException catch (e) {
      throw toApiException(e);
    }
  }

  /// Открытие списка помечает всё прочитанным на сервере (спека: read-all)
  Future<List<AppNotification>> list() async {
    try {
      final r = await _dio.get('/notifications');
      return (r.data as List)
          .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw toApiException(e);
    }
  }
}

final notificationsApiProvider = Provider<NotificationsApi>(
  (ref) => NotificationsApi(ref.read(dioProvider)),
);
