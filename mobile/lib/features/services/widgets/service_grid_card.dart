import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/models.dart';
import '../../../core/theme/app_colors.dart';

/// Карточка сервиса в плитке (макет 04/43): фото с сердечком и бейджем
/// количества фото, название, «Категория · Город», 👍 счётчик.
class ServiceGridCard extends StatelessWidget {
  const ServiceGridCard({
    super.key,
    required this.service,
    required this.categoryName,
    required this.cityName,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteTap,
  });

  final ServiceSummary service;
  final String categoryName;
  final String cityName;
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
          borderRadius: BorderRadius.circular(AppRadius.medium),
          border: Border.all(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Фиксированная пропорция — миниатюры одинаковые независимо
            // от того, в одну или две строки лёг заголовок ниже
            AspectRatio(
              aspectRatio: 1.35,
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
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: onFavoriteTap,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          size: 18,
                          color: isFavorite
                              ? AppColors.coral
                              : AppColors.textPrimary,
                        ),
                      ),
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
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$categoryName · $cityName',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.thumb_up,
                          size: 14,
                          color: AppColors.coral,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${service.likesCount}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
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
