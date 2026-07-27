import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../api/api_client.dart';
import '../theme/app_colors.dart';

/// Круглая аватарка: фото с сервера или серый круг с инициалом.
class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, this.avatarUrl, this.name, this.radius = 24});

  final String? avatarUrl;
  final String? name;
  final double radius;

  @override
  Widget build(BuildContext context) {
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
