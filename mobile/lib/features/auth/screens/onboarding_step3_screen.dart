import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/users_api.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/session_controller.dart';

/// Экран 17 «Где вы находитесь?» — 3 из 3, завершает онбординг.
class OnboardingStep3Screen extends ConsumerStatefulWidget {
  const OnboardingStep3Screen({super.key});

  @override
  ConsumerState<OnboardingStep3Screen> createState() =>
      _OnboardingStep3ScreenState();
}

class _OnboardingStep3ScreenState extends ConsumerState<OnboardingStep3Screen> {
  int? _selectedCityId;
  bool _submitting = false;

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      await ref.read(sessionControllerProvider.notifier).updateProfile({
        'city_id': _selectedCityId,
      });
      // роутер сам переведёт на главный экран — онбординг завершён
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final citiesAsync = ref.watch(citiesProvider);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('3 / 3', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              Text(
                l10n.onboardingStep3Title,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: citiesAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, st) => Center(
                    child: TextButton(
                      onPressed: () => ref.invalidate(citiesProvider),
                      child: Text(l10n.retry),
                    ),
                  ),
                  data: (cities) => RadioGroup<int>(
                    groupValue: _selectedCityId,
                    onChanged: (value) =>
                        setState(() => _selectedCityId = value),
                    child: ListView.builder(
                      itemCount: cities.length,
                      itemBuilder: (context, index) {
                        final city = cities[index];
                        return RadioListTile<int>(
                          value: city.id,
                          title: Text('${city.flag} ${city.nameRu}'),
                          subtitle: Text(city.countryRu),
                        );
                      },
                    ),
                  ),
                ),
              ),
              PrimaryButton(
                label: l10n.done,
                loading: _submitting,
                onPressed: _selectedCityId != null ? _submit : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
