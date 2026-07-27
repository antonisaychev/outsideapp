import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/localized_names.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/selectable_chip.dart';
import '../../../l10n/app_localizations.dart';
import '../data/countries.dart';
import '../providers/session_controller.dart';

/// Экран 16 «Откуда вы?» — 2 из 3. Одиночный выбор страны, сетка 2 колонки.
class OnboardingStep2Screen extends ConsumerStatefulWidget {
  const OnboardingStep2Screen({super.key});

  @override
  ConsumerState<OnboardingStep2Screen> createState() =>
      _OnboardingStep2ScreenState();
}

class _OnboardingStep2ScreenState extends ConsumerState<OnboardingStep2Screen> {
  String? _selectedCode;
  bool _submitting = false;

  Country? get _selectedCountry {
    if (_selectedCode == null) return null;
    for (final c in allCountries) {
      if (c.code == _selectedCode) return c;
    }
    return null;
  }

  bool get _selectedIsFeatured =>
      _selectedCode != null && featuredCountryCodes.contains(_selectedCode);

  Future<void> _openSearch() async {
    final code = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) =>
          _CountrySearchSheet(l10n: AppLocalizations.of(context)!),
    );
    if (code != null) setState(() => _selectedCode = code);
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      await ref.read(sessionControllerProvider.notifier).updateProfile({
        'home_country': _selectedCode,
      });
      // роутер сам переведёт на шаг 3
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final featured = allCountries
        .where((c) => featuredCountryCodes.contains(c.code))
        .toList();
    // Выбранная «другая» страна показывается в сетке вместо последней ячейки
    final gridCountries = List<Country>.of(featured);
    if (_selectedCode != null && !_selectedIsFeatured) {
      gridCountries[gridCountries.length - 1] = _selectedCountry!;
    }
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.onboardingStepLabel(2),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.onboardingStep2Title,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.onboardingStep2Subtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 20),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 3.4,
                      children: [
                        for (final c in gridCountries)
                          SelectableChip(
                            selected: _selectedCode == c.code,
                            onTap: () => setState(() => _selectedCode = c.code),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 0,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  c.flag,
                                  style: const TextStyle(fontSize: 20),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    localizedName(context, c.nameRu, c.nameEn),
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: _selectedCode == c.code
                                          ? AppColors.coral
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      onPressed: _openSearch,
                      child: Text(l10n.otherCountry),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: PrimaryButton(
                label: l10n.next,
                loading: _submitting,
                onPressed: _selectedCode != null ? _submit : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountrySearchSheet extends StatefulWidget {
  const _CountrySearchSheet({required this.l10n});
  final AppLocalizations l10n;

  @override
  State<_CountrySearchSheet> createState() => _CountrySearchSheetState();
}

class _CountrySearchSheetState extends State<_CountrySearchSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = allCountries
        .where(
          (c) =>
              c.nameRu.toLowerCase().contains(_query.toLowerCase()) ||
              c.nameEn.toLowerCase().contains(_query.toLowerCase()),
        )
        .toList();
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              autofocus: true,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: widget.l10n.searchCountry,
                prefixIcon: const Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final c = filtered[index];
                  return ListTile(
                    leading: Text(c.flag, style: const TextStyle(fontSize: 24)),
                    title: Text(localizedName(context, c.nameRu, c.nameEn)),
                    onTap: () => Navigator.of(context).pop(c.code),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
