import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/session_controller.dart';
import 'l10n/app_localizations.dart';

void main() {
  runApp(const ProviderScope(child: OutsideApp()));
}

class OutsideApp extends ConsumerWidget {
  const OutsideApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    // Язык из профиля (настройки), null = язык устройства
    final lang = ref.watch(
      sessionControllerProvider.select((s) => s.profile?.lang),
    );
    return MaterialApp.router(
      title: 'Outside',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      locale: lang != null ? Locale(lang) : null,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    );
  }
}
