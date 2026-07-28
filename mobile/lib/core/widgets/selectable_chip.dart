import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';

/// Выбираемый чип/карточка по макету: серый фон в покое,
/// коралловая рамка + светло-розовый фон при выборе.
class SelectableChip extends StatelessWidget {
  const SelectableChip({
    super.key,
    required this.selected,
    required this.onTap,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  });

  final bool selected;
  final VoidCallback onTap;
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: padding,
        decoration: BoxDecoration(
          // Выбранный — сплошной коралл с белым текстом (макеты Outside 2.0)
          color: selected ? AppColors.coral : AppColors.neutral100,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: DefaultTextStyle.merge(
          style: AppText.smallMedium.copyWith(
            color: selected ? Colors.white : AppColors.neutral600,
          ),
          child: child,
        ),
      ),
    );
  }
}
