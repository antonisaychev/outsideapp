import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../l10n/app_localizations.dart';
import '../data/countries.dart';
import '../providers/session_controller.dart';

/// Экран 16 «Откуда вы?» — 2 из 3. Одиночный выбор страны.
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
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('2 / 3', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              Text(
                l10n.onboardingStep2Title,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.onboardingStep2Subtitle,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      ...featured.map(
                        (c) => _CountryChip(
                          country: c,
                          selected: _selectedCode == c.code,
                          onTap: () => setState(() => _selectedCode = c.code),
                        ),
                      ),
                      if (_selectedCode != null && !_selectedIsFeatured)
                        _CountryChip(
                          country: _selectedCountry!,
                          selected: true,
                          onTap: _openSearch,
                        ),
                      ActionChip(
                        avatar: const Icon(Icons.search, size: 18),
                        label: Text(l10n.otherCountry),
                        onPressed: _openSearch,
                      ),
                    ],
                  ),
                ),
              ),
              PrimaryButton(
                label: l10n.next,
                loading: _submitting,
                onPressed: _selectedCode != null ? _submit : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountryChip extends StatelessWidget {
  const _CountryChip({
    required this.country,
    required this.selected,
    required this.onTap,
  });

  final Country country;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text('${country.flag} ${country.nameRu}'),
      selected: selected,
      onSelected: (_) => onTap(),
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
                labelText: widget.l10n.searchCountry,
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: AppColors.surface,
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
                    title: Text(c.nameRu),
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
