import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../providers/session_controller.dart';

/// Временная заглушка после входа/онбординга — таб-бар с 5 разделами
/// и настоящие фичевые экраны появятся в следующих итерациях.
class HomePlaceholderScreen extends ConsumerWidget {
  const HomePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final profile = ref.watch(sessionControllerProvider).profile;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.homeWelcomeTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              if (profile?.firstName != null) ...[
                const SizedBox(height: 8),
                Text(
                  '@${profile!.username}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: 32),
              TextButton(
                onPressed: () =>
                    ref.read(sessionControllerProvider.notifier).logout(),
                child: Text(l10n.logout),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
