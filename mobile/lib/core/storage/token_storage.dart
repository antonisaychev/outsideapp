import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Хранилище access/refresh токенов (Keychain на iOS).
class TokenStorage {
  TokenStorage(this._storage);

  final FlutterSecureStorage _storage;

  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';
  static const _userIdKey = 'user_id';

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required String userId,
  }) async {
    await Future.wait([
      _storage.write(key: _accessKey, value: accessToken),
      _storage.write(key: _refreshKey, value: refreshToken),
      _storage.write(key: _userIdKey, value: userId),
    ]);
  }

  Future<void> saveAccessToken(String accessToken) =>
      _storage.write(key: _accessKey, value: accessToken);
  Future<void> saveRefreshToken(String refreshToken) =>
      _storage.write(key: _refreshKey, value: refreshToken);

  Future<String?> readAccessToken() => _storage.read(key: _accessKey);
  Future<String?> readRefreshToken() => _storage.read(key: _refreshKey);
  Future<String?> readUserId() => _storage.read(key: _userIdKey);

  Future<void> clear() async {
    await Future.wait([
      _storage.delete(key: _accessKey),
      _storage.delete(key: _refreshKey),
      _storage.delete(key: _userIdKey),
    ]);
  }
}
