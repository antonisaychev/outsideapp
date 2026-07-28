import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Значок «проверено админом» — коралловый кружок с галочкой.
/// Ставится только из админки, поэтому обычному пользователю его не подделать.
class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({super.key, this.size = 18});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.coral,
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.check, size: size * 0.68, color: Colors.white),
    );
  }
}

/// Значок «у карточки есть владелец» для мини-карточки в списке.
class OwnerBadge extends StatelessWidget {
  const OwnerBadge({super.key, this.size = 18});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.textPrimary,
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.person, size: size * 0.68, color: Colors.white),
    );
  }
}

/// Зелёная точка «в сети» поверх аватара или рядом с именем.
class OnlineDot extends StatelessWidget {
  const OnlineDot({super.key, this.size = 10});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.success,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: size * 0.18),
      ),
    );
  }
}
