import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/dating_api.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/providers/session_controller.dart';

/// Экран 08 «Это мэтч!» — полноэкранный, поверх колоды.
/// Дружба и диалог уже созданы сервером к этому моменту.
///
/// Возвращает `true`, если нажали «Написать сообщение» — чат открывает
/// вызывающий экран, у которого живой context (QA_NOTES №39).
class MatchScreen extends ConsumerWidget {
  const MatchScreen({super.key, required this.match});

  final DatingMatch match;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final me = ref.watch(sessionControllerProvider).profile;

    return Scaffold(
      body: Container(
        // Градиент на весь экран, включая области под статус-баром
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.gradientStart, AppColors.gradientEnd],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Spacer(flex: 3),
                Text(
                  l10n.matchTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.matchSubtitle(match.displayName),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.4,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 36),
                // Две аватарки внахлёст — как в макете
                SizedBox(
                  height: 120,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Transform.translate(
                        offset: const Offset(-50, 0),
                        child: _RingAvatar(
                          avatarUrl: me?.avatarUrl,
                          name: me?.firstName,
                        ),
                      ),
                      Transform.translate(
                        offset: const Offset(50, 0),
                        child: _RingAvatar(
                          avatarUrl: match.avatarUrl,
                          name: match.displayName,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(flex: 2),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.coral,
                      elevation: 0,
                      minimumSize: const Size.fromHeight(56),
                      shape: const StadiumBorder(),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(l10n.matchWriteMessage),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(l10n.matchLater),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Аватар в белом кольце — чтобы круги читались на градиенте
class _RingAvatar extends StatelessWidget {
  const _RingAvatar({this.avatarUrl, this.name});

  final String? avatarUrl;
  final String? name;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      padding: const EdgeInsets.all(3),
      child: UserAvatar(avatarUrl: avatarUrl, name: name, radius: 57),
    );
  }
}
