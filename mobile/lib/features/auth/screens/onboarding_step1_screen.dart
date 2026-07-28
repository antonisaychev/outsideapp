import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/users_api.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/selectable_chip.dart';
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
      maxWidth: 2400,
      maxHeight: 2400,
      imageQuality: 90,
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
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.onboardingStepLabel(1),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.onboardingStep1Title,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: GestureDetector(
                        onTap: _pickAvatar,
                        child: _avatarFile != null
                            ? CircleAvatar(
                                radius: 48,
                                backgroundImage: FileImage(_avatarFile!),
                              )
                            : CustomPaint(
                                painter: _DashedCirclePainter(),
                                child: const SizedBox(
                                  width: 96,
                                  height: 96,
                                  child: Icon(
                                    Icons.add,
                                    size: 28,
                                    color: AppColors.coral,
                                  ),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _firstNameController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(hintText: l10n.firstNameHint),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _lastNameController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(hintText: l10n.lastNameHint),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.genderLabel,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        SelectableChip(
                          selected: _gender == 'male',
                          onTap: () => setState(() => _gender = 'male'),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_gender == 'male') ...[
                                const Icon(Icons.check, size: 18),
                                const SizedBox(width: 6),
                              ],
                              Text(l10n.genderMale),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        SelectableChip(
                          selected: _gender == 'female',
                          onTap: () => setState(() => _gender = 'female'),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_gender == 'female') ...[
                                const Icon(Icons.check, size: 18),
                                const SizedBox(width: 6),
                              ],
                              Text(l10n.genderFemale),
                            ],
                          ),
                        ),
                      ],
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
                onPressed: formValid ? _submit : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Пунктирная окружность-плейсхолдер под фото профиля (макет, экран 15).
class _DashedCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final radius = size.width / 2 - 1;
    final center = Offset(size.width / 2, size.height / 2);
    const dashCount = 24;
    const dashAngle = 2 * math.pi / dashCount;
    for (var i = 0; i < dashCount; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i * dashAngle,
        dashAngle * 0.55,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
