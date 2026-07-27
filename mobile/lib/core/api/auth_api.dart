import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client.dart';

class AuthTokens {
  AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
  });
  final String accessToken;
  final String refreshToken;
  final String userId;
}

class AuthApi {
  AuthApi(this._dio);
  final Dio _dio;

  Future<void> register({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      await _dio.post(
        '/auth/register',
        data: {'email': email, 'password': password, 'username': username},
      );
    } on DioException catch (e) {
      throw toApiException(e);
    }
  }

  Future<AuthTokens> verify({
    required String email,
    required String code,
  }) async {
    try {
      final r = await _dio.post(
        '/auth/verify',
        data: {'email': email, 'code': code},
      );
      return _tokensFrom(r.data);
    } on DioException catch (e) {
      throw toApiException(e);
    }
  }

  Future<void> resend({required String email}) async {
    try {
      await _dio.post('/auth/resend', data: {'email': email});
    } on DioException catch (e) {
      throw toApiException(e);
    }
  }

  Future<AuthTokens> login({
    required String email,
    required String password,
  }) async {
    try {
      final r = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      return _tokensFrom(r.data);
    } on DioException catch (e) {
      throw toApiException(e);
    }
  }

  Future<void> forgot({required String email}) async {
    try {
      await _dio.post('/auth/forgot', data: {'email': email});
    } on DioException catch (e) {
      throw toApiException(e);
    }
  }

  Future<String> verifyReset({
    required String email,
    required String code,
  }) async {
    try {
      final r = await _dio.post(
        '/auth/verify-reset',
        data: {'email': email, 'code': code},
      );
      return r.data['reset_token'] as String;
    } on DioException catch (e) {
      throw toApiException(e);
    }
  }

  Future<AuthTokens> reset({
    required String resetToken,
    required String newPassword,
  }) async {
    try {
      final r = await _dio.post(
        '/auth/reset',
        data: {'reset_token': resetToken, 'new_password': newPassword},
      );
      return _tokensFrom(r.data);
    } on DioException catch (e) {
      throw toApiException(e);
    }
  }

  AuthTokens _tokensFrom(dynamic data) => AuthTokens(
    accessToken: data['access_token'] as String,
    refreshToken: data['refresh_token'] as String,
    userId: data['user_id'] as String,
  );
}

final authApiProvider = Provider<AuthApi>(
  (ref) => AuthApi(ref.read(dioProvider)),
);
