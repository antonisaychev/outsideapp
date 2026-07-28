import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Шапка вкладки: крупный заголовок слева, иконки справа.
/// Единственный источник отступов и размеров для всех пяти вкладок —
/// раньше каждый экран задавал их по-своему (QA_NOTES №49).
class TabHeader extends StatelessWidget {
  const TabHeader({
    super.key,
    this.title,
    this.actions = const [],
    this.horizontalPadding = true,
  });

  final String? title;
  final List<Widget> actions;

  /// false — когда родитель уже даёт боковые отступы (скроллящийся профиль)
  final bool horizontalPadding;

  /// Отступы шапки: слева 24 под текст, справа 12 — иконки добирают своим полем
  static const padding = EdgeInsets.fromLTRB(24, 12, 12, 8);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: horizontalPadding
          ? padding
          : const EdgeInsets.fromLTRB(0, 12, 0, 8),
      child: Row(
        children: [
          Expanded(
            child: title == null
                ? const SizedBox(height: 44)
                : Text(
                    title!,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
          ),
          ...actions,
        ],
      ),
    );
  }
}

/// Иконка в шапке: один размер и одна область нажатия на всё приложение
class HeaderIconButton extends StatelessWidget {
  const HeaderIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.color,
    this.tooltip,
  });

  final Widget icon;
  final VoidCallback onPressed;
  final Color? color;
  final String? tooltip;

  static const iconSize = 24.0;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: icon,
      onPressed: onPressed,
      tooltip: tooltip,
      iconSize: iconSize,
      color: color ?? AppColors.textPrimary,
      constraints: const BoxConstraints.tightFor(width: 44, height: 44),
      padding: EdgeInsets.zero,
      splashRadius: 24,
    );
  }
}
