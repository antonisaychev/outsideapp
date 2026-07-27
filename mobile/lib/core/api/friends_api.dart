import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client.dart';
import 'models.dart';

/// Статус отношений с пользователем (GET /friends/status).
enum RelationStatus {
  none,
  accepted,
  pendingOutgoing,
  pendingIncoming,
  blockedByMe,
  blockedByThem,
  declined;

  static RelationStatus fromApi(String value) {
    switch (value) {
      case 'accepted':
        return RelationStatus.accepted;
      case 'pending_outgoing':
        return RelationStatus.pendingOutgoing;
      case 'pending_incoming':
        return RelationStatus.pendingIncoming;
      case 'blocked_by_me':
        return RelationStatus.blockedByMe;
      case 'blocked_by_them':
        return RelationStatus.blockedByThem;
      case 'declined':
        return RelationStatus.declined;
      default:
        return RelationStatus.none;
    }
  }
}

class FriendsApi {
  FriendsApi(this._dio);
  final Dio _dio;

  Future<List<UserListItem>> friends() async {
    try {
      final r = await _dio.get('/friends');
      return (r.data as List)
          .map((e) => UserListItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw toApiException(e);
    }
  }

  Future<List<UserListItem>> requests({required bool incoming}) async {
    try {
      final r = await _dio.get(
        '/friends/requests',
        queryParameters: {'direction': incoming ? 'incoming' : 'outgoing'},
      );
      return (r.data as List)
          .map((e) => UserListItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw toApiException(e);
    }
  }

  /// Возвращает новый статус ('pending_outgoing' | 'accepted' — при взаимной)
  Future<String> sendRequest(String userId) async {
    try {
      final r = await _dio.post('/friends/requests', data: {'user_id': userId});
      return r.data['status'] as String;
    } on DioException catch (e) {
      throw toApiException(e);
    }
  }

  Future<void> acceptRequest(String userId) async {
    try {
      await _dio.post('/friends/requests/$userId/accept');
    } on DioException catch (e) {
      throw toApiException(e);
    }
  }

  Future<void> declineRequest(String userId) async {
    try {
      await _dio.post('/friends/requests/$userId/decline');
    } on DioException catch (e) {
      throw toApiException(e);
    }
  }

  Future<void> cancelRequest(String userId) async {
    try {
      await _dio.delete('/friends/requests/$userId');
    } on DioException catch (e) {
      throw toApiException(e);
    }
  }

  Future<void> removeFriend(String userId) async {
    try {
      await _dio.delete('/friends/$userId');
    } on DioException catch (e) {
      throw toApiException(e);
    }
  }

  Future<void> blockUser(String userId) async {
    try {
      await _dio.post('/friends/$userId/block');
    } on DioException catch (e) {
      throw toApiException(e);
    }
  }

  Future<void> unblockUser(String userId) async {
    try {
      await _dio.delete('/friends/$userId/block');
    } on DioException catch (e) {
      throw toApiException(e);
    }
  }

  Future<List<UserListItem>> blocked() async {
    try {
      final r = await _dio.get('/friends/blocked');
      return (r.data as List)
          .map((e) => UserListItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw toApiException(e);
    }
  }

  Future<Map<String, RelationStatus>> statuses(List<String> userIds) async {
    if (userIds.isEmpty) return {};
    try {
      final r = await _dio.get(
        '/friends/status',
        queryParameters: {'user_ids': userIds.join(',')},
      );
      return (r.data as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, RelationStatus.fromApi(value as String)),
      );
    } on DioException catch (e) {
      throw toApiException(e);
    }
  }
}

class PeopleApi {
  PeopleApi(this._dio);
  final Dio _dio;

  Future<List<UserListItem>> search({
    String? q,
    int? cityId,
    String? homeCountry,
  }) async {
    try {
      final r = await _dio.get(
        '/users',
        queryParameters: {
          'q': ?q,
          'city_id': ?cityId,
          'home_country': ?homeCountry,
        },
      );
      return (r.data as List)
          .map((e) => UserListItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw toApiException(e);
    }
  }

  Future<PublicProfile> getById(String id) async {
    try {
      final r = await _dio.get('/users/$id');
      return PublicProfile.fromJson(r.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw toApiException(e);
    }
  }

  Future<void> report(
    String userId, {
    required String reasonType,
    String? comment,
  }) async {
    try {
      await _dio.post(
        '/users/$userId/report',
        data: {
          'reason_type': reasonType,
          if (comment != null && comment.isNotEmpty) 'comment': comment,
        },
      );
    } on DioException catch (e) {
      throw toApiException(e);
    }
  }
}

final friendsApiProvider = Provider<FriendsApi>(
  (ref) => FriendsApi(ref.read(dioProvider)),
);
final peopleApiProvider = Provider<PeopleApi>(
  (ref) => PeopleApi(ref.read(dioProvider)),
);
