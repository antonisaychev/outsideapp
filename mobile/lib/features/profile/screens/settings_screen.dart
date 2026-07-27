import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/users_api.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/providers/session_controller.dart';

/// Экран 14 «Настройки».
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _pickLanguage(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Русский'),
              onTap: () => Navigator.of(context).pop('ru'),
            ),
            ListTile(
              title: const Text('English'),
              onTap: () => Navigator.of(context).pop('en'),
            ),
          ],
        ),
      ),
    );
    if (selected != null) {
      // Применяется мгновенно: MaterialApp слушает profile.lang
      await ref.read(sessionControllerProvider.notifier).updateProfile({
        'lang': selected,
      });
    }
  }

  Future<void> _confirmLogout(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.logoutConfirmTitle),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              l10n.logout,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(sessionControllerProvider.notifier).logout();
      // Явный переход (та же особенность, что в login_screen): настройки
      // открыты push'ем, redirect базы /home для гостя ничего не делает
      if (context.mounted) context.go('/welcome');
    }
  }

  Future<void> _deleteAccountFlow(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    // Двойное подтверждение: предупреждение → ввод пароля
    final warned = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteAccountTitle),
        content: Text(l10n.deleteAccountWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              l10n.deleteAccountContinue,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (warned != true || !context.mounted) return;

    final passwordController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteAccountPasswordTitle),
        content: TextField(
          controller: passwordController,
          obscureText: true,
          obscuringCharacter: '●',
          decoration: InputDecoration(hintText: l10n.passwordHint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              l10n.deleteAccountConfirm,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await ref
          .read(usersApiProvider)
          .deleteAccount(password: passwordController.text);
      await ref.read(sessionControllerProvider.notifier).logout();
      if (context.mounted) context.go('/welcome');
    } on ApiException {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.wrongPassword)));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final profile = ref.watch(sessionControllerProvider).profile;
    final langName = profile?.lang == 'en' ? 'English' : 'Русский';

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: SafeArea(
        child: ListView(
          children: [
            _SectionHeader(l10n.settingsSectionProfile),
            ListTile(
              title: Text(l10n.editProfile),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/settings/edit-profile'),
            ),
            _SectionHeader(l10n.settingsSectionAccount),
            ListTile(
              title: Text(l10n.changePassword),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/settings/password'),
            ),
            ListTile(
              title: const Text('Email'),
              trailing: Text(
                profile?.email ?? '',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            ListTile(
              title: Text(l10n.languageTitle),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(langName, style: Theme.of(context).textTheme.bodyMedium),
                  const Icon(Icons.chevron_right),
                ],
              ),
              onTap: () => _pickLanguage(context, ref, l10n),
            ),
            _SectionHeader(l10n.settingsSectionDating),
            ListTile(
              title: Text(l10n.tabDating),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(l10n.comingSoonSection))),
            ),
            _SectionHeader(l10n.settingsSectionPrivacy),
            ListTile(
              title: Text(l10n.blockedUsersTitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/settings/blocked'),
            ),
            if (profile?.isAdmin ?? false) ...[
              _SectionHeader(l10n.settingsSectionAdmin),
              ListTile(
                title: Text(l10n.adminTitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(l10n.comingSoonSection))),
              ),
            ],
            _SectionHeader(l10n.settingsSectionAbout),
            ListTile(
              title: Text(l10n.termsTitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/settings/legal/terms'),
            ),
            ListTile(
              title: Text(l10n.privacyTitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/settings/legal/privacy'),
            ),
            const SizedBox(height: 8),
            ListTile(
              title: Text(
                l10n.logout,
                style: const TextStyle(color: AppColors.coral),
              ),
              onTap: () => _confirmLogout(context, ref, l10n),
            ),
            ListTile(
              title: Text(
                l10n.deleteAccountTitle,
                style: const TextStyle(color: AppColors.error),
              ),
              onTap: () => _deleteAccountFlow(context, ref, l10n),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
