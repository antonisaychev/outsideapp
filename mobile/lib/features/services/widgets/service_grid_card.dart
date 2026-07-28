import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/models.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/widgets/verified_badge.dart';

/// Карточка сервиса в плитке (макет 04/43): фото с сердечком и бейджем
/// количества фото, название, категория, 👍 счётчик. Место не пишем —
/// лента и так показывает только карточки места из профиля.
class ServiceGridCard extends StatelessWidget {
  const ServiceGridCard({
    super.key,
    required this.service,
    required this.categoryName,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteTap,
  });

  final ServiceSummary service;
  final String categoryName;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppRadius.large),
          border: Border.all(color: AppColors.neutral200),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Фиксированная пропорция — миниатюры одинаковые независимо
            // от того, в одну или две строки лёг заголовок ниже
            AspectRatio(
              aspectRatio: 4 / 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: absoluteFileUrl(service.photoUrl),
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        Container(color: AppColors.surface),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.surface,
                      child: const Icon(
                        Icons.image_outlined,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  // Значки в один ряд: избранное, проверено, есть владелец
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Row(
                      children: [
                        if (service.ownerId != null) ...[
                          const _BadgeBubble(child: OwnerBadge(size: 16)),
                          const SizedBox(width: 6),
                        ],
                        if (service.isVerified) ...[
                          const _BadgeBubble(child: VerifiedBadge(size: 16)),
                          const SizedBox(width: 6),
                        ],
                        GestureDetector(
                          onTap: onFavoriteTap,
                          child: Container(
                            width: 32,
                            height: 32,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              size: 18,
                              color: isFavorite
                                  ? AppColors.coral
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (service.photosCount > 1)
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${service.photosCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                // Название сверху, счётчик прижат к низу — так карточки
                // одинаково читаются при заголовке в одну и в две строки
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          service.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.bodyStrong,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          categoryName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.small,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.thumb_up,
                          size: 15,
                          color: AppColors.coral,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${service.likesCount}',
                          style: AppText.smallMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Белый кружок-подложка, чтобы значок читался на любом фото
class _BadgeBubble extends StatelessWidget {
  const _BadgeBubble({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: child,
    );
  }
}
