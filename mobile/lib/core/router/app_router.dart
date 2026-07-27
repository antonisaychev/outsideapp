import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/providers/session_controller.dart';
import '../../features/auth/screens/blocked_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/new_password_screen.dart';
import '../../features/auth/screens/onboarding_step1_screen.dart';
import '../../features/auth/screens/onboarding_step2_screen.dart';
import '../../features/auth/screens/onboarding_step3_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/verify_code_screen.dart';
import '../../features/auth/screens/welcome_screen.dart';
import '../../features/chats/screens/chat_screen.dart';
import '../../features/friends/screens/people_search_screen.dart';
import '../../features/friends/screens/user_profile_screen.dart';
import '../../features/profile/screens/blocked_users_screen.dart';
import '../../features/profile/screens/change_password_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart';
import '../../features/profile/screens/legal_screen.dart';
import '../../features/profile/screens/settings_screen.dart';
import '../../features/services/screens/add_service_screen.dart';
import '../../features/services/screens/favorites_screen.dart';
import '../../features/services/screens/service_card_screen.dart';
import '../../features/shell/tab_shell.dart';

const _publicPaths = {
  '/welcome',
  '/register',
  '/verify',
  '/login',
  '/forgot',
  '/verify-reset',
  '/reset-password',
};

/// Гостю (без токена) доступны просмотр главного экрана, карточек сервисов
/// и профилей (мастер-ТЗ §1: гостевой режим — просмотр всего, действия
/// через auth-gate).
bool _guestAllowed(String loc) =>
    loc == '/home' ||
    (loc.startsWith('/services/') && loc != '/services/add') ||
    loc.startsWith('/users/');

String _onboardingStepPath(SessionState session) {
  final profile = session.profile!;
  if (!profile.onboardingStep1Done) return '/onboarding/1';
  if (!profile.onboardingStep2Done) return '/onboarding/2';
  return '/onboarding/3';
}

/// Мостик между Riverpod-состоянием сессии и go_router: пробрасывает
/// изменения sessionControllerProvider как ChangeNotifier, чтобы GoRouter
/// пересчитывал redirect при смене статуса (гость/онбординг/блок/готов).
class _SessionRefreshNotifier extends ChangeNotifier {
  _SessionRefreshNotifier(Ref ref) {
    ref.listen(sessionControllerProvider, (_, _) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _SessionRefreshNotifier(ref);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final session = ref.read(sessionControllerProvider);
      final loc = state.matchedLocation;

      switch (session.status) {
        case SessionStatus.initializing:
          return loc == '/splash' ? null : '/splash';
        case SessionStatus.unauthenticated:
          if (_publicPaths.contains(loc) || _guestAllowed(loc)) return null;
          return '/welcome';
        case SessionStatus.blocked:
          return loc == '/blocked' ? null : '/blocked';
        case SessionStatus.onboarding:
          final step = _onboardingStepPath(session);
          return loc == step ? null : step;
        case SessionStatus.ready:
          final onAuthScreen =
              loc == '/splash' ||
              _publicPaths.contains(loc) ||
              loc.startsWith('/onboarding') ||
              loc == '/blocked';
          return onAuthScreen ? '/home' : null;
      }
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/verify',
        builder: (context, state) => VerifyCodeScreen(
          email: state.uri.queryParameters['email'] ?? '',
          purpose: VerifyPurpose.register,
        ),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/forgot',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/verify-reset',
        builder: (context, state) => VerifyCodeScreen(
          email: state.uri.queryParameters['email'] ?? '',
          purpose: VerifyPurpose.reset,
        ),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) => NewPasswordScreen(
          resetToken: state.uri.queryParameters['resetToken'] ?? '',
        ),
      ),
      GoRoute(
        path: '/onboarding/1',
        builder: (context, state) => const OnboardingStep1Screen(),
      ),
      GoRoute(
        path: '/onboarding/2',
        builder: (context, state) => const OnboardingStep2Screen(),
      ),
      GoRoute(
        path: '/onboarding/3',
        builder: (context, state) => const OnboardingStep3Screen(),
      ),
      GoRoute(
        path: '/blocked',
        builder: (context, state) => const BlockedScreen(),
      ),
      GoRoute(path: '/home', builder: (context, state) => const TabShell()),
      GoRoute(
        path: '/services/add',
        builder: (context, state) => const AddServiceScreen(),
      ),
      GoRoute(
        path: '/services/:id',
        builder: (context, state) =>
            ServiceCardScreen(serviceId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/favorites',
        builder: (context, state) => const FavoritesScreen(),
      ),
      GoRoute(
        path: '/chats/:id',
        builder: (context, state) => ChatScreen(
          conversationId: state.pathParameters['id']!,
          peerId: state.uri.queryParameters['peer'] ?? '',
        ),
      ),
      GoRoute(
        path: '/people-search',
        builder: (context, state) => const PeopleSearchScreen(),
      ),
      GoRoute(
        path: '/users/:id',
        builder: (context, state) =>
            UserProfileScreen(userId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/settings/edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/settings/password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: '/settings/blocked',
        builder: (context, state) => const BlockedUsersScreen(),
      ),
      GoRoute(
        path: '/settings/legal/:doc',
        builder: (context, state) =>
            LegalScreen(doc: state.pathParameters['doc']!),
      ),
    ],
  );
});
