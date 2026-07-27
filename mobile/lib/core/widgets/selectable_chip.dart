import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

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
      borderRadius: BorderRadius.circular(AppRadius.small),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: padding,
        decoration: BoxDecoration(
          color: selected ? AppColors.coralTint : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.small),
          border: Border.all(
            color: selected ? AppColors.coral : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: child,
      ),
    );
  }
}
