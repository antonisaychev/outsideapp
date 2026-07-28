import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../api/api_client.dart';
import '../theme/app_colors.dart';
import 'verified_badge.dart';

/// Круглая аватарка: фото с сервера или серый круг с инициалом.
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    this.avatarUrl,
    this.name,
    this.radius = 24,
    this.isOnline = false,
  });

  final String? avatarUrl;
  final String? name;
  final double radius;

  /// Человек заходил за последние 5 минут — рисуем зелёную точку
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    if (!isOnline) return _avatar(context);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _avatar(context),
        Positioned(right: 0, bottom: 0, child: OnlineDot(size: radius * 0.42)),
      ],
    );
  }

  Widget _avatar(BuildContext context) {
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.surface,
        backgroundImage: CachedNetworkImageProvider(
          absoluteFileUrl(avatarUrl!),
        ),
      );
    }
    final initial = (name != null && name!.isNotEmpty)
        ? name!.characters.first.toUpperCase()
        : '?';
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.surface,
      child: Text(
        initial,
        style: TextStyle(
          fontSize: radius * 0.8,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
