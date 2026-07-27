import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/users_api.dart';
import '../../../core/utils/localized_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/selectable_chip.dart';
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
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.onboardingStepLabel(3),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.onboardingStep3Title,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 20),
                    citiesAsync.when(
                      loading: () => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 48),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (err, st) => Center(
                        child: TextButton(
                          onPressed: () => ref.invalidate(citiesProvider),
                          child: Text(l10n.retry),
                        ),
                      ),
                      data: (cities) => Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final city in cities) ...[
                            SelectableChip(
                              selected: _selectedCityId == city.id,
                              onTap: () =>
                                  setState(() => _selectedCityId = city.id),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    city.flag,
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        localizedName(
                                          context,
                                          city.nameRu,
                                          city.nameEn,
                                        ),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: _selectedCityId == city.id
                                              ? AppColors.coral
                                              : AppColors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        localizedName(
                                          context,
                                          city.countryRu,
                                          city.countryEn,
                                        ),
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          Text(
                            l10n.citiesFootnote,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: PrimaryButton(
                label: l10n.done,
                loading: _submitting,
                onPressed: _selectedCityId != null ? _submit : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
