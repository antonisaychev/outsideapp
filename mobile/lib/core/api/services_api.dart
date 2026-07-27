import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client.dart';
import 'models.dart';

/// Кандидаты-дубли из 409 POSSIBLE_DUPLICATE при создании сервиса.
class DuplicateCandidate {
  DuplicateCandidate({
    required this.id,
    required this.title,
    required this.photoUrl,
  });

  final String id;
  final String title;
  final String photoUrl;

  factory DuplicateCandidate.fromJson(Map<String, dynamic> json) =>
      DuplicateCandidate(
        id: json['id'] as String,
        title: json['title'] as String,
        photoUrl: json['photo_url'] as String,
      );
}

class DuplicateException implements Exception {
  DuplicateException(this.candidates);
  final List<DuplicateCandidate> candidates;
}

class LikeResult {
  LikeResult({
    required this.liked,
    required this.likesCount,
    required this.confirmCount,
    required this.confirmThreshold,
    required this.status,
  });

  final bool liked;
  final int likesCount;
  final int confirmCount;
  final int confirmThreshold;
  final String status;

  factory LikeResult.fromJson(Map<String, dynamic> json) => LikeResult(
    liked: json['liked'] as bool,
    likesCount: json['likes_count'] as int,
    confirmCount: json['confirm_count'] as int,
    confirmThreshold: json['confirm_threshold'] as int,
    status: json['status'] as String,
  );
}

class ServicesApi {
  ServicesApi(this._dio);
  final Dio _dio;

  Future<List<ServiceCategory>> getCategories() async {
    try {
      final r = await _dio.get('/categories');
      return (r.data as List)
          .map((e) => ServiceCategory.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw toApiException(e);
    }
  }

  Future<List<ServiceSummary>> list({
    required String tab,
    required int cityId,
    int? categoryId,
    int page = 1,
  }) async {
    try {
      final r = await _dio.get(
        '/services',
        queryParameters: {
          'tab': tab,
          'city_id': cityId,
          'category_id': ?categoryId,
          'page': page,
        },
      );
      return (r.data as List)
          .map((e) => ServiceSummary.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw toApiException(e);
    }
  }

  Future<ServiceDetail> getById(String id) async {
    try {
      final r = await _dio.get('/services/$id');
      return ServiceDetail.fromJson(r.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw toApiException(e);
    }
  }

  Future<LikeResult> toggleLike(String id) async {
    try {
      final r = await _dio.post('/services/$id/like');
      return LikeResult.fromJson(r.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw toApiException(e);
    }
  }

  Future<void> addFavorite(String id) async {
    try {
      await _dio.post('/services/$id/favorite');
    } on DioException catch (e) {
      throw toApiException(e);
    }
  }

  Future<void> removeFavorite(String id) async {
    try {
      await _dio.delete('/services/$id/favorite');
    } on DioException catch (e) {
      throw toApiException(e);
    }
  }

  Future<List<ServiceSummary>> favorites() async {
    try {
      final r = await _dio.get('/me/favorites');
      return (r.data as List)
          .map((e) => ServiceSummary.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw toApiException(e);
    }
  }

  Future<void> report(
    String id, {
    required String reasonType,
    String? comment,
  }) async {
    try {
      await _dio.post(
        '/services/$id/report',
        data: {
          'reason_type': reasonType,
          if (comment != null && comment.isNotEmpty) 'comment': comment,
        },
      );
    } on DioException catch (e) {
      throw toApiException(e);
    }
  }

  /// Создание: multipart с 1-5 фото; 409 POSSIBLE_DUPLICATE → DuplicateException.
  Future<ServiceDetail> create({
    required String title,
    required String description,
    required int categoryId,
    int? cityId,
    String? websiteUrl,
    String? mapUrl,
    required List<String> photoPaths,
    bool force = false,
  }) async {
    final formData = FormData.fromMap({
      'title': title,
      'description': description,
      'category_id': categoryId,
      'city_id': ?cityId,
      if (websiteUrl != null && websiteUrl.isNotEmpty)
        'website_url': websiteUrl,
      if (mapUrl != null && mapUrl.isNotEmpty) 'map_url': mapUrl,
      if (force) 'force': 'true',
      'photos': [
        for (final path in photoPaths) await MultipartFile.fromFile(path),
      ],
    });
    try {
      final r = await _dio.post('/services', data: formData);
      return ServiceDetail.fromJson(r.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final api = toApiException(e);
      if (api.statusCode == 409 && api.error == 'POSSIBLE_DUPLICATE') {
        final candidates = ((api.extra?['candidates'] as List?) ?? [])
            .map((c) => DuplicateCandidate.fromJson(c as Map<String, dynamic>))
            .toList();
        throw DuplicateException(candidates);
      }
      throw api;
    }
  }
}

final servicesApiProvider = Provider<ServicesApi>(
  (ref) => ServicesApi(ref.read(dioProvider)),
);

final categoriesProvider = FutureProvider<List<ServiceCategory>>(
  (ref) => ref.read(servicesApiProvider).getCategories(),
);
