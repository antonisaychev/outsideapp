import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client.dart';

/// Пользователь в списке администрирования (экран 26)
class AdminUser {
  AdminUser({
    required this.id,
    required this.email,
    required this.username,
    this.firstName,
    this.lastName,
    required this.role,
    required this.isBlocked,
    this.blockedReason,
    this.cityId,
  });

  final String id;
  final String email;
  final String username;
  final String? firstName;
  final String? lastName;
  final String role;
  final bool isBlocked;
  final String? blockedReason;
  final int? cityId;

  String get displayName {
    final name = [firstName, lastName].where((p) => p?.isNotEmpty ?? false);
    return name.isEmpty ? '@$username' : name.join(' ');
  }

  factory AdminUser.fromJson(Map<String, dynamic> json) => AdminUser(
    id: json['id'] as String,
    email: json['email'] as String,
    username: json['username'] as String,
    firstName: json['first_name'] as String?,
    lastName: json['last_name'] as String?,
    role: json['role'] as String? ?? 'user',
    isBlocked: json['is_blocked'] as bool? ?? false,
    blockedReason: json['blocked_reason'] as String?,
    cityId: json['city_id'] as int?,
  );
}

/// Карточка сервиса в списке администрирования (экран 27)
class AdminService {
  AdminService({
    required this.id,
    required this.title,
    required this.photoUrl,
    required this.cityId,
    required this.categoryId,
    required this.status,
    required this.likesCount,
    required this.confirmCount,
    required this.authorUsername,
  });

  final String id;
  final String title;
  final String photoUrl;
  final int cityId;
  final int categoryId;
  final String status;
  final int likesCount;
  final int confirmCount;
  final String authorUsername;

  bool get isPending => status == 'pending';
  bool get isHidden => status == 'hidden';

  factory AdminService.fromJson(Map<String, dynamic> json) => AdminService(
    id: json['id'] as String,
    title: json['title'] as String,
    photoUrl: json['photo_url'] as String? ?? '',
    cityId: json['city_id'] as int,
    categoryId: json['category_id'] as int,
    status: json['status'] as String,
    likesCount: json['likes_count'] as int? ?? 0,
    confirmCount: json['confirm_count'] as int? ?? 0,
    authorUsername: json['author_username'] as String? ?? '',
  );
}

/// Жалоба на сервис или на пользователя (экран 28)
class AdminReport {
  AdminReport({
    required this.kind,
    required this.id,
    required this.reasonType,
    this.comment,
    required this.reporterId,
    required this.reporterUsername,
    required this.targetId,
    required this.targetLabel,
  });

  /// 'service' или 'user' — от этого зависит и адрес разрешения жалобы
  final String kind;
  final String id;
  final String reasonType;
  final String? comment;
  final String reporterId;
  final String reporterUsername;
  final String targetId;
  final String targetLabel;

  factory AdminReport.fromJson(Map<String, dynamic> json) => AdminReport(
    kind: json['kind'] as String,
    id: json['id'] as String,
    reasonType: json['reason_type'] as String? ?? '',
    comment: json['comment'] as String?,
    reporterId: json['reporter_id'] as String? ?? '',
    reporterUsername: json['reporter_username'] as String? ?? '',
    targetId: json['target_id'] as String,
    targetLabel: json['target_label'] as String? ?? '',
  );
}

/// Категория с числом сервисов (экран 42)
class AdminCategory {
  AdminCategory({
    required this.id,
    required this.nameRu,
    required this.nameEn,
    required this.servicesCount,
  });

  final int id;
  final String nameRu;
  final String nameEn;
  final int servicesCount;

  factory AdminCategory.fromJson(Map<String, dynamic> json) => AdminCategory(
    id: json['id'] as int,
    nameRu: json['name_ru'] as String,
    nameEn: json['name_en'] as String,
    servicesCount: json['services_count'] as int? ?? 0,
  );
}

class AdminApi {
  AdminApi(this._dio);
  final Dio _dio;

  // --- Пользователи ---

  Future<List<AdminUser>> users({String? query, int page = 1}) async {
    try {
      final r = await _dio.get(
        '/admin/users',
        queryParameters: {
          if (query != null && query.isNotEmpty) 'q': query,
          'page': page,
        },
      );
      final users = (r.data as List)
          .map((e) => AdminUser.fromJson(e as Map<String, dynamic>))
          .toList();
      // Заблокированные опускаются в конец, порядок внутри групп сохраняется
      users.sort((a, b) {
        if (a.isBlocked == b.isBlocked) return 0;
        return a.isBlocked ? 1 : -1;
      });
      return users;
    } on DioException catch (e) {
      throw toApiException(e);
    }
  }

  Future<void> blockUser(String id, String reason) async {
    try {
      await _dio.post('/admin/users/$id/block', data: {'reason': reason});
    } on DioException catch (e) {
      throw toApiException(e);
    }
  }

  Future<void> unblockUser(String id) async {
    try {
      await _dio.post('/admin/users/$id/unblock');
    } on DioException catch (e) {
      throw toApiException(e);
    }
  }

  // --- Сервисы ---

  Future<List<AdminService>> services({String? status, int? cityId}) async {
    try {
      final r = await _dio.get(
        '/admin/services',
        queryParameters: {
          'status': ?status,
          'city_id': ?cityId,
          'limit': 50,
        },
      );
      return (r.data as List)
          .map((e) => AdminService.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw toApiException(e);
    }
  }

  Future<void> approveService(String id) async {
    try {
      await _dio.post('/admin/services/$id/approve');
    } on DioException catch (e) {
      throw toApiException(e);
    }
  }

  Future<void> hideService(String id) async {
    try {
      await _dio.post('/admin/services/$id/hide');
    } on DioException catch (e) {
      throw toApiException(e);
    }
  }

  Future<void> unhideService(String id) async {
    try {
      await _dio.post('/admin/services/$id/unhide');
    } on DioException catch (e) {
      throw toApiException(e);
    }
  }

  /// Жёсткое удаление: карточка, фото и связанные записи стираются
  Future<void> deleteService(String id) async {
    try {
      await _dio.delete('/admin/services/$id');
    } on DioException catch (e) {
      throw toApiException(e);
    }
  }

  Future<void> updateService(String id, Map<String, dynamic> fields) async {
    try {
      await _dio.patch('/admin/services/$id', data: fields);
    } on DioException catch (e) {
      throw toApiException(e);
    }
  }

  // --- Категории ---

  Future<List<AdminCategory>> categories() async {
    try {
      final r = await _dio.get('/admin/categories');
      return (r.data as List)
          .map((e) => AdminCategory.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw toApiException(e);
    }
  }

  Future<void> createCategory(String nameRu, String nameEn) async {
    try {
      await _dio.post(
        '/admin/categories',
        data: {'name_ru': nameRu, 'name_en': nameEn},
      );
    } on DioException catch (e) {
      throw toApiException(e);
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      await _dio.delete('/admin/categories/$id');
    } on DioException catch (e) {
      throw toApiException(e);
    }
  }

  // --- Жалобы ---

  Future<List<AdminReport>> reports() async {
    try {
      final r = await _dio.get('/admin/reports');
      return (r.data as List)
          .map((e) => AdminReport.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw toApiException(e);
    }
  }

  Future<void> resolveReport(String kind, String id) async {
    try {
      await _dio.post('/admin/reports/$kind/$id/resolve');
    } on DioException catch (e) {
      throw toApiException(e);
    }
  }
}

final adminApiProvider = Provider<AdminApi>(
  (ref) => AdminApi(ref.read(dioProvider)),
);
