import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';

/// Пустое состояние по макетам Outside 2.0: иконка в круге, заголовок,
/// пояснение и (необязательно) кнопка с ближайшим полезным действием.
/// Раньше на месте пустых списков была одна серая строка текста.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
    this.tone = EmptyStateTone.brand,
  });

  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EmptyStateTone tone;

  @override
  Widget build(BuildContext context) {
    final isBrand = tone == EmptyStateTone.brand;
    final isError = tone == EmptyStateTone.error;
    final bg = isError
        ? AppColors.errorBg
        : isBrand
        ? AppColors.coralBg
        : AppColors.neutral100;
    final fg = isError
        ? AppColors.error
        : isBrand
        ? AppColors.coral
        : AppColors.neutral500;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
              child: Icon(icon, size: 32, color: fg),
            ),
            const SizedBox(height: AppSpacing.l),
            Text(title, textAlign: TextAlign.center, style: AppText.h3),
            const SizedBox(height: AppSpacing.s),
            Text(
              description,
              textAlign: TextAlign.center,
              style: AppText.callout.copyWith(color: AppColors.neutral500),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.xl),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 44),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screen,
                  ),
                  textStyle: AppText.smallMedium.copyWith(color: Colors.white),
                ),
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

enum EmptyStateTone { brand, neutral, error }
