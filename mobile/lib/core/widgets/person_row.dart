import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import 'user_avatar.dart';

/// Строка человека — один компонент на все списки: друзья, заявки, поиск,
/// заблокированные, выбор владельца в админке (макеты Outside 2.0, раздел 5).
///
/// Аватар 52 с зелёной точкой «в сети», имя, под ним строка состояния:
/// «В сети» зелёным либо место/никнейм серым.
class PersonRow extends StatelessWidget {
  const PersonRow({
    super.key,
    required this.name,
    this.avatarUrl,
    this.subtitle,
    this.isOnline = false,
    this.trailing,
    this.onTap,
  });

  final String name;
  final String? avatarUrl;
  final String? subtitle;
  final bool isOnline;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screen,
          vertical: 10,
        ),
        child: Row(
          children: [
            UserAvatar(
              avatarUrl: avatarUrl,
              name: name,
              radius: 26,
              isOnline: isOnline,
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.bodyStrong,
                  ),
                  if (isOnline || (subtitle?.isNotEmpty ?? false)) ...[
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        if (isOnline) ...[
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.online,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Expanded(
                          child: Text(
                            subtitle ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.small.copyWith(
                              color: isOnline
                                  ? AppColors.success
                                  : AppColors.neutral500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: AppSpacing.m),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}
