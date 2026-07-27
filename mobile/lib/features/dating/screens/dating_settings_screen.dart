import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/dating_api.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/selectable_chip.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../../l10n/app_localizations.dart';
import '../../chats/providers/chats_providers.dart';
import '../providers/dating_providers.dart';

/// Экран 20 «Анкета знакомств»: тумблер участия (мгновенный PATCH),
/// чипы «Что ищете» / «Кого показывать», вход в «Мои мэтчи».
class DatingSettingsScreen extends ConsumerWidget {
  const DatingSettingsScreen({super.key});

  Future<void> _update(
    BuildContext context,
    WidgetRef ref, {
    bool? isActive,
    String? lookingFor,
    String? showGender,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await ref
          .read(datingApiProvider)
          .updateProfile(
            isActive: isActive,
            lookingFor: lookingFor,
            showGender: showGender,
          );
      ref.invalidate(datingProfileProvider);
      ref.invalidate(deckControllerProvider);
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.error == 'PROFILE_INCOMPLETE'
                  ? l10n.datingProfileIncompleteBody
                  : l10n.genericError,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final profileAsync = ref.watch(datingProfileProvider);
    final matches = ref.watch(matchesProvider).valueOrNull ?? [];

    final lookingForOptions = {
      'any': l10n.lookingForAny,
      'friends': l10n.lookingForFriends,
      'dating': l10n.lookingForDating,
      'networking': l10n.lookingForNetworking,
    };
    final showGenderOptions = {
      'any': l10n.showGenderAny,
      'male': l10n.genderMale,
      'female': l10n.genderFemale,
    };

    return Scaffold(
      appBar: AppBar(title: Text(l10n.datingSettingsTitle)),
      body: SafeArea(
        child: profileAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, st) => Center(
            child: TextButton(
              onPressed: () => ref.invalidate(datingProfileProvider),
              child: Text(l10n.retry),
            ),
          ),
          data: (profile) => ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeThumbColor: AppColors.coral,
                title: Text(l10n.datingParticipate),
                subtitle: Text(
                  l10n.datingParticipateHint,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                value: profile.isActive,
                onChanged: (v) => _update(context, ref, isActive: v),
              ),
              const Divider(height: 32),
              Text(
                l10n.lookingForLabel,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final e in lookingForOptions.entries)
                    SelectableChip(
                      selected: profile.lookingFor == e.key,
                      onTap: () => _update(context, ref, lookingFor: e.key),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      child: Text(e.value),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                l10n.showGenderLabel,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final e in showGenderOptions.entries)
                    SelectableChip(
                      selected: profile.showGender == e.key,
                      onTap: () => _update(context, ref, showGender: e.key),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      child: Text(e.value),
                    ),
                ],
              ),
              const Divider(height: 32),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.myMatches),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (matches.isNotEmpty)
                      Text(
                        '${matches.length}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
                onTap: () => context.push('/dating/matches'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Экран 21 «Мои мэтчи».
class MyMatchesScreen extends ConsumerWidget {
  const MyMatchesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final matchesAsync = ref.watch(matchesProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.myMatches)),
      body: SafeArea(
        child: matchesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, st) => Center(
            child: TextButton(
              onPressed: () => ref.invalidate(matchesProvider),
              child: Text(l10n.retry),
            ),
          ),
          data: (matches) => matches.isEmpty
              ? Center(
                  child: Text(
                    l10n.matchesEmpty,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                )
              : ListView.builder(
                  itemCount: matches.length,
                  itemBuilder: (context, index) {
                    final m = matches[index];
                    return ListTile(
                      onTap: () => context.push('/users/${m.id}'),
                      leading: UserAvatar(
                        avatarUrl: m.avatarUrl,
                        name: m.displayName,
                      ),
                      title: Text(
                        m.displayName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      trailing: TextButton(
                        onPressed: () => openChatWith(context, ref, m.id),
                        child: Text(l10n.writeMessage),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
