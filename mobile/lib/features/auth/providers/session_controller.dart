import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/auth_api.dart';
import '../../../core/api/models.dart';
import '../../../core/api/users_api.dart';
import '../../../core/storage/token_storage.dart';

enum SessionStatus { initializing, unauthenticated, onboarding, blocked, ready }

class SessionState {
  const SessionState({required this.status, this.profile, this.blockedReason});

  final SessionStatus status;
  final MeProfile? profile;
  final String? blockedReason;

  static const initial = SessionState(status: SessionStatus.initializing);
}

/// Единая точка входа в сессию: держит статус (гость/онбординг/блок/готов),
/// используется и экранами, и роутером для auth-gate редиректов.
class SessionController extends StateNotifier<SessionState> {
  SessionController(this._ref) : super(SessionState.initial) {
    _bootstrap();
  }

  final Ref _ref;

  TokenStorage get _tokenStorage => _ref.read(tokenStorageProvider);
  AuthApi get _authApi => _ref.read(authApiProvider);
  UsersApi get _usersApi => _ref.read(usersApiProvider);

  Future<void> _bootstrap() async {
    final token = await _tokenStorage.readAccessToken();
    if (token == null) {
      state = const SessionState(status: SessionStatus.unauthenticated);
      return;
    }
    await _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _usersApi.getMe();
      state = SessionState(
        status: profile.onboardingComplete
            ? SessionStatus.ready
            : SessionStatus.onboarding,
        profile: profile,
      );
      debugPrint('[session] profile loaded, status=${state.status}');
    } on ApiException catch (e) {
      debugPrint('[session] loadProfile failed: $e');
      if (e.statusCode == 403 && e.error == 'BLOCKED') {
        state = SessionState(
          status: SessionStatus.blocked,
          blockedReason: e.extra?['reason'] as String?,
        );
      } else {
        await _tokenStorage.clear();
        state = const SessionState(status: SessionStatus.unauthenticated);
      }
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String username,
  }) {
    return _authApi.register(
      email: email,
      password: password,
      username: username,
    );
  }

  Future<void> resendCode(String email) => _authApi.resend(email: email);

  Future<void> verifyCode({required String email, required String code}) async {
    final tokens = await _authApi.verify(email: email, code: code);
    await _tokenStorage.saveTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
      userId: tokens.userId,
    );
    await _loadProfile();
  }

  Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
  }) async {
    final tokens = await _authApi.reset(
      resetToken: resetToken,
      newPassword: newPassword,
    );
    await _tokenStorage.saveTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
      userId: tokens.userId,
    );
    await _loadProfile();
  }

  /// BLOCKED обрабатывается здесь (меняет статус сессии на экран блокировки);
  /// остальные ошибки (неверный пароль, не подтверждён email, TRY_LATER)
  /// пробрасываются наверх — их показывает сам экран входа.
  Future<void> login({required String email, required String password}) async {
    try {
      final tokens = await _authApi.login(email: email, password: password);
      await _tokenStorage.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
        userId: tokens.userId,
      );
      await _loadProfile();
    } on ApiException catch (e) {
      if (e.statusCode == 403 && e.error == 'BLOCKED') {
        state = SessionState(
          status: SessionStatus.blocked,
          blockedReason: e.extra?['reason'] as String?,
        );
        return;
      }
      rethrow;
    }
  }

  Future<void> updateProfile(Map<String, dynamic> fields) async {
    final profile = await _usersApi.patchMe(fields);
    state = SessionState(
      status: profile.onboardingComplete
          ? SessionStatus.ready
          : SessionStatus.onboarding,
      profile: profile,
    );
  }

  Future<void> logout() async {
    await _tokenStorage.clear();
    state = const SessionState(status: SessionStatus.unauthenticated);
  }
}

final sessionControllerProvider =
    StateNotifierProvider<SessionController, SessionState>(
      (ref) => SessionController(ref),
    );
