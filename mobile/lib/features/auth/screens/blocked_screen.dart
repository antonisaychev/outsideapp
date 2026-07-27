import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/session_controller.dart';

/// Экран 25 «Аккаунт заблокирован».
class BlockedScreen extends ConsumerWidget {
  const BlockedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final reason = ref.watch(sessionControllerProvider).blockedReason;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.block, size: 64, color: AppColors.error),
              const SizedBox(height: 24),
              Text(
                l10n.blockedTitle,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              if (reason != null) ...[
                const SizedBox(height: 16),
                Text(
                  '${l10n.blockedReasonLabel} $reason',
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 32),
              OutlinedButton(
                onPressed: () => launchUrl(
                  Uri(
                    scheme: 'mailto',
                    path: 'support@outside.ink',
                    query:
                        'subject=${Uri.encodeComponent('Блокировка аккаунта')}',
                  ),
                ),
                child: Text(l10n.contactSupport),
              ),
              const SizedBox(height: 12),
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
