import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/users_api.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/session_controller.dart';

/// Экран 15 «Как вас зовут?» — 1 из 3. Фото опционально, остальное обязательно.
class OnboardingStep1Screen extends ConsumerStatefulWidget {
  const OnboardingStep1Screen({super.key});

  @override
  ConsumerState<OnboardingStep1Screen> createState() =>
      _OnboardingStep1ScreenState();
}

class _OnboardingStep1ScreenState extends ConsumerState<OnboardingStep1Screen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  String? _gender;
  File? _avatarFile;
  bool _submitting = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    // Сжатие на клиенте до 1280px по длинной стороне (ТЗ v5.6 §4)
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1280,
      maxHeight: 1280,
      imageQuality: 85,
    );
    if (picked != null) setState(() => _avatarFile = File(picked.path));
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _submitting = true);
    try {
      // Аватар опционален: его ошибка не должна блокировать онбординг
      if (_avatarFile != null) {
        try {
          await ref.read(usersApiProvider).uploadAvatar(_avatarFile!.path);
        } on ApiException {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(l10n.avatarUploadFailed)));
          }
        }
      }
      await ref.read(sessionControllerProvider.notifier).updateProfile({
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'gender': _gender,
      });
      // роутер сам переведёт на шаг 2 по смене профиля в статусе сессии
    } on ApiException {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.genericError)));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final formValid =
        _firstNameController.text.trim().isNotEmpty &&
        _lastNameController.text.trim().isNotEmpty &&
        _gender != null;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('1 / 3', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              Text(
                l10n.onboardingStep1Title,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),
              Center(
                child: GestureDetector(
                  onTap: _pickAvatar,
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: AppColors.surface,
                    backgroundImage: _avatarFile != null
                        ? FileImage(_avatarFile!)
                        : null,
                    child: _avatarFile == null
                        ? const Icon(
                            Icons.add,
                            size: 32,
                            color: AppColors.textSecondary,
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _firstNameController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(labelText: l10n.firstNameLabel),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _lastNameController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(labelText: l10n.lastNameLabel),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: Text(l10n.genderMale),
                      selected: _gender == 'male',
                      onSelected: (_) => setState(() => _gender = 'male'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ChoiceChip(
                      label: Text(l10n.genderFemale),
                      selected: _gender == 'female',
                      onSelected: (_) => setState(() => _gender = 'female'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                label: l10n.next,
                loading: _submitting,
                onPressed: formValid ? _submit : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
