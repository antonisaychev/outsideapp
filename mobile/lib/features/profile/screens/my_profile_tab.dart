import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/tab_header.dart';
import '../../../core/api/users_api.dart';
import '../../../core/utils/localized_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/photo_strip.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/data/countries.dart';
import '../../auth/providers/session_controller.dart';

/// Экран 12 «Профиль свой» (вкладка Профиль).
class MyProfileTab extends ConsumerWidget {
  const MyProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final session = ref.watch(sessionControllerProvider);
    final profile = session.profile;
    final cities = ref.watch(citiesProvider).valueOrNull ?? [];

    // Гость на вкладке профиля — приглашение войти
    if (profile == null) {
      return SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.guestProfileTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.push('/register'),
                  child: Text(l10n.createAccount),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => context.push('/login'),
                  child: Text(l10n.login),
                ),
              ],
            ),
          ),
        ),
      );
    }

    String cityName(int? id) {
      for (final c in cities) {
        if (c.id == id) return localizedName(context, c.nameRu, c.nameEn);
      }
      return '';
    }

    String countryFlag(String? code) {
      if (code == null) return '';
      for (final c in allCountries) {
        if (c.code == code) return c.flag;
      }
      return '';
    }

    final name = [
      profile.firstName,
      profile.lastName,
    ].where((s) => s != null && s.isNotEmpty).join(' ');

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 14, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TabHeader(
              horizontalPadding: false,
              actions: [
                HeaderIconButton(
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () => context.push('/settings'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Center(
              child: UserAvatar(
                avatarUrl: profile.avatarUrl,
                name: name,
                radius: 52,
              ),
            ),
            if (profile.photos.length > 1) ...[
              const SizedBox(height: 16),
              PhotoStrip(photos: profile.photos),
            ],
            const SizedBox(height: 16),
            Text(
              name,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () async {
                await Clipboard.setData(
                  ClipboardData(
                    text: 'https://outside.ink/@${profile.username}',
                  ),
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(l10n.linkCopied)));
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '@${profile.username}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.copy,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${countryFlag(profile.homeCountry)} → ${cityName(profile.cityId)}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Counter(value: profile.friendsCount, label: l10n.countFriends),
                const SizedBox(width: 40),
                _Counter(
                  value: profile.servicesCount,
                  label: l10n.countRecommendations,
                ),
              ],
            ),
            if (profile.bio != null && profile.bio!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(profile.bio!, textAlign: TextAlign.center),
            ],
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () => context.push('/settings/edit-profile'),
              child: Text(l10n.editProfile),
            ),
          ],
        ),
      ),
    );
  }
}

class _Counter extends StatelessWidget {
  const _Counter({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$value',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
