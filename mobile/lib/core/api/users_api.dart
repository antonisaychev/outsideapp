import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client.dart';
import 'models.dart';

class UsersApi {
  UsersApi(this._dio);
  final Dio _dio;

  Future<bool> checkUsername(String username) async {
    try {
      final r = await _dio.get(
        '/users/check-username',
        queryParameters: {'u': username},
      );
      return r.data['available'] as bool;
    } on DioException catch (e) {
      throw toApiException(e);
    }
  }

  Future<MeProfile> getMe() async {
    try {
      final r = await _dio.get('/me');
      return MeProfile.fromJson(r.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw toApiException(e);
    }
  }

  Future<MeProfile> patchMe(Map<String, dynamic> fields) async {
    try {
      final r = await _dio.patch('/me', data: fields);
      return MeProfile.fromJson(r.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw toApiException(e);
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _dio.patch(
        '/me/password',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );
    } on DioException catch (e) {
      throw toApiException(e);
    }
  }

  Future<void> deleteAccount({required String password}) async {
    try {
      await _dio.delete('/me', data: {'password': password});
    } on DioException catch (e) {
      throw toApiException(e);
    }
  }

  Future<String> uploadAvatar(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(filePath),
      });
      final r = await _dio.post('/me/avatar', data: formData);
      return r.data['avatar_url'] as String;
    } on DioException catch (e) {
      throw toApiException(e);
    }
  }

  /// Фото профиля: до 10 штук, первое — главное
  Future<List<UserPhoto>> photos() async {
    try {
      final r = await _dio.get('/me/photos');
      return UserPhoto.listFrom(r.data);
    } on DioException catch (e) {
      throw toApiException(e);
    }
  }

  Future<List<UserPhoto>> addPhoto(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(filePath),
      });
      final r = await _dio.post('/me/photos', data: formData);
      return UserPhoto.listFrom(r.data['photos']);
    } on DioException catch (e) {
      throw toApiException(e);
    }
  }

  Future<List<UserPhoto>> deletePhoto(String photoId) async {
    try {
      final r = await _dio.delete('/me/photos/$photoId');
      return UserPhoto.listFrom(r.data['photos']);
    } on DioException catch (e) {
      throw toApiException(e);
    }
  }

  Future<List<UserPhoto>> makeMainPhoto(String photoId) async {
    try {
      final r = await _dio.post('/me/photos/$photoId/main');
      return UserPhoto.listFrom(r.data['photos']);
    } on DioException catch (e) {
      throw toApiException(e);
    }
  }
}

final usersApiProvider = Provider<UsersApi>(
  (ref) => UsersApi(ref.read(dioProvider)),
);

class PublicApi {
  PublicApi(this._dio);
  final Dio _dio;

  Future<List<City>> getCities() async {
    try {
      final r = await _dio.get('/cities');
      return (r.data as List)
          .map((e) => City.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw toApiException(e);
    }
  }
}

final publicApiProvider = Provider<PublicApi>(
  (ref) => PublicApi(ref.read(dioProvider)),
);

final citiesProvider = FutureProvider<List<City>>(
  (ref) => ref.read(publicApiProvider).getCities(),
);
