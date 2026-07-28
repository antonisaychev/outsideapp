import 'package:flutter/material.dart';

/// Компактные галочки статуса как в Telegram: вторая галочка наложена на
/// первую со смещением, а не рядом (Icons.done_all слишком широкая).
class ReadTicks extends StatelessWidget {
  const ReadTicks({
    super.key,
    required this.read,
    this.color = Colors.white70,
    this.size = 13,
  });

  final bool read;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (!read) {
      return Icon(Icons.check, size: size, color: color);
    }
    // Ширина чуть больше одной галочки — за счёт наложения выглядит плотно
    return SizedBox(
      width: size * 1.35,
      height: size,
      child: Stack(
        children: [
          Icon(Icons.check, size: size, color: color),
          Positioned(
            left: size * 0.35,
            child: Icon(Icons.check, size: size, color: color),
          ),
        ],
      ),
    );
  }
}
