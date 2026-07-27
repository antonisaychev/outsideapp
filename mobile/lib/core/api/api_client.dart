import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../storage/token_storage.dart';

/// Адрес backend. По умолчанию — боевой сервер; переопределяется через
/// --dart-define=API_BASE_URL=... (например, для локальной разработки).
const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://api.outside.ink',
);

/// Файлы (фото) backend отдаёт относительными путями /uploads/...
String absoluteFileUrl(String path) =>
    path.startsWith('http') ? path : '$apiBaseUrl$path';

/// Единая ошибка API: коды из backend в формате { error: 'CODE' } или
/// { errors: {field: 'CODE'} } (см. CLAUDE.md, раздел «Конвенции кода»).
class ApiException implements Exception {
  ApiException({required this.statusCode, this.error, this.errors, this.extra});

  final int statusCode;
  final String? error;
  final Map<String, String>? errors;
  final Map<String, dynamic>? extra;

  String? fieldError(String field) => errors?[field];

  bool get isNetworkError => statusCode == 0;

  @override
  String toString() =>
      'ApiException($statusCode, error: $error, errors: $errors)';
}

ApiException toApiException(DioException e) {
  final data = e.response?.data;
  if (data is Map) {
    final map = Map<String, dynamic>.from(data);
    Map<String, String>? errors;
    final errorsRaw = map['errors'];
    if (errorsRaw is Map) {
      errors = errorsRaw.map(
        (key, value) => MapEntry(key.toString(), value.toString()),
      );
    }
    final extra = Map<String, dynamic>.from(map)
      ..remove('error')
      ..remove('errors');
    return ApiException(
      statusCode: e.response?.statusCode ?? 0,
      error: map['error']?.toString(),
      errors: errors,
      extra: extra.isEmpty ? null : extra,
    );
  }
  return ApiException(
    statusCode: e.response?.statusCode ?? 0,
    error: 'NETWORK_ERROR',
  );
}

class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this._dio, this._tokenStorage);

  final Dio _dio;
  final TokenStorage _tokenStorage;
  Future<String?>? _refreshing;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenStorage.readAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final isAuthEndpoint = err.requestOptions.path.startsWith('/auth/');
    if (err.response?.statusCode == 401 && !isAuthEndpoint) {
      final newToken = await (_refreshing ??= _refresh().whenComplete(
        () => _refreshing = null,
      ));
      if (newToken != null) {
        try {
          final opts = err.requestOptions;
          opts.headers['Authorization'] = 'Bearer $newToken';
          final response = await _dio.fetch(opts);
          return handler.resolve(response);
        } catch (_) {
          // упадём ниже в handler.next(err) с исходной ошибкой
        }
      } else {
        await _tokenStorage.clear();
      }
    }
    handler.next(err);
  }

  Future<String?> _refresh() async {
    final refreshToken = await _tokenStorage.readRefreshToken();
    if (refreshToken == null) return null;
    try {
      final response = await _dio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );
      final access = response.data['access_token'] as String;
      final newRefresh = response.data['refresh_token'] as String;
      await _tokenStorage.saveAccessToken(access);
      await _tokenStorage.saveRefreshToken(newRefresh);
      return access;
    } catch (_) {
      return null;
    }
  }
}

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage(const FlutterSecureStorage());
});

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );
  dio.interceptors.add(_AuthInterceptor(dio, ref.read(tokenStorageProvider)));
  return dio;
});
