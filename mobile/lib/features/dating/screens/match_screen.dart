import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/dating_api.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../../l10n/app_localizations.dart';
import '../../chats/providers/chats_providers.dart';

/// Экран 08 «Это мэтч!» — показывается поверх колоды.
/// Дружба и диалог уже созданы сервером к этому моменту.
class MatchScreen extends ConsumerWidget {
  const MatchScreen({super.key, required this.match});

  final DatingMatch match;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Dialog.fullscreen(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.matchTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppColors.coral,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.matchSubtitle(match.displayName),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              Center(
                child: UserAvatar(
                  avatarUrl: match.avatarUrl,
                  name: match.displayName,
                  radius: 60,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  openChatWith(context, ref, match.id);
                },
                child: Text(l10n.matchWriteMessage),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.matchLater),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
