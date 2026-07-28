import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/dating_api.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/selectable_chip.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/dating_providers.dart';

/// Экран 20 «Анкета знакомств»: участие, что ищете, кого показывать.
/// Выбор применяется сразу, запрос уходит фоном — без ожидания сети.
class DatingSettingsScreen extends ConsumerStatefulWidget {
  const DatingSettingsScreen({super.key});

  @override
  ConsumerState<DatingSettingsScreen> createState() =>
      _DatingSettingsScreenState();
}

class _DatingSettingsScreenState extends ConsumerState<DatingSettingsScreen> {
  // Локальные значения перекрывают серверные, пока ответ в пути
  bool? _isActive;
  String? _lookingFor;
  String? _showGender;

  Future<void> _update(
    AppLocalizations l10n, {
    bool? isActive,
    String? lookingFor,
    String? showGender,
  }) async {
    setState(() {
      if (isActive != null) _isActive = isActive;
      if (lookingFor != null) _lookingFor = lookingFor;
      if (showGender != null) _showGender = showGender;
    });
    try {
      await ref
          .read(datingApiProvider)
          .updateProfile(
            isActive: isActive,
            lookingFor: lookingFor,
            showGender: showGender,
          );
      ref.invalidate(datingProfileProvider);
      // Фильтры изменились — колоду набираем заново
      if (lookingFor != null || showGender != null || isActive == true) {
        ref.read(deckControllerProvider.notifier).load();
      }
    } on ApiException {
      // Возвращаем прежнее значение: правда за сервером
      setState(() {
        if (isActive != null) _isActive = null;
        if (lookingFor != null) _lookingFor = null;
        if (showGender != null) _showGender = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.genericError)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final profileAsync = ref.watch(datingProfileProvider);

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
          data: (profile) {
            final isActive = _isActive ?? profile.isActive;
            final lookingFor = _lookingFor ?? profile.lookingFor;
            final showGender = _showGender ?? profile.showGender;
            return ListView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: AppColors.coral,
                  title: Text(
                    l10n.datingParticipate,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: Text(
                    l10n.datingParticipateHint,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  value: isActive,
                  onChanged: (v) => _update(l10n, isActive: v),
                ),
                const Divider(height: 32),
                _Section(
                  title: l10n.lookingForLabel,
                  options: lookingForOptions,
                  selected: lookingFor,
                  onSelect: (key) => _update(l10n, lookingFor: key),
                ),
                const Divider(height: 32),
                _Section(
                  title: l10n.showGenderLabel,
                  options: showGenderOptions,
                  selected: showGender,
                  onSelect: (key) => _update(l10n, showGender: key),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Заголовок секции + ряд чипов — одинаково для обеих настроек
class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  final String title;
  final Map<String, String> options;
  final String selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final e in options.entries)
              SelectableChip(
                selected: selected == e.key,
                onTap: () => onSelect(e.key),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                child: Text(e.value),
              ),
          ],
        ),
      ],
    );
  }
}
