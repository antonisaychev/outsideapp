import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../api/api_client.dart';
import '../api/models.dart';
import '../theme/app_colors.dart';

/// Лента фото профиля под аватаром. Первое фото — то же, что аватар,
/// поэтому лента показывается только когда снимков больше одного.
class PhotoStrip extends StatelessWidget {
  const PhotoStrip({super.key, required this.photos});

  final List<UserPhoto> photos;

  @override
  Widget build(BuildContext context) {
    if (photos.length < 2) return const SizedBox.shrink();
    return SizedBox(
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: photos.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) => GestureDetector(
          onTap: () => _openViewer(context, index),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.small),
            child: CachedNetworkImage(
              imageUrl: absoluteFileUrl(photos[index].url),
              width: 104,
              height: 104,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: 104,
                color: AppColors.surface,
              ),
              errorWidget: (context, url, error) => Container(
                width: 104,
                color: AppColors.surface,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openViewer(BuildContext context, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (context) => _PhotoViewer(photos: photos, initial: initialIndex),
      ),
    );
  }
}

class _PhotoViewer extends StatelessWidget {
  const _PhotoViewer({required this.photos, required this.initial});

  final List<UserPhoto> photos;
  final int initial;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: PageView.builder(
        controller: PageController(initialPage: initial),
        itemCount: photos.length,
        itemBuilder: (context, index) => InteractiveViewer(
          child: Center(
            child: CachedNetworkImage(
              imageUrl: absoluteFileUrl(photos[index].url),
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
