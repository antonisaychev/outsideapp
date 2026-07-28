import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../api/api_client.dart';
import '../api/models.dart';
import '../theme/app_colors.dart';

/// Фото профиля крупным планом: листается свайпом, снизу точки.
/// Свой вариант: карточка со скруглением в общих отступах экрана,
/// а не полноэкранное фото под шапкой.
class PhotoGallery extends StatefulWidget {
  const PhotoGallery({
    super.key,
    required this.photos,
    this.fallbackUrl,
    this.name,
  });

  final List<UserPhoto> photos;

  /// Если галереи ещё нет — показываем аватар
  final String? fallbackUrl;
  final String? name;

  @override
  State<PhotoGallery> createState() => _PhotoGalleryState();
}

class _PhotoGalleryState extends State<PhotoGallery> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<String> get _urls => widget.photos.isNotEmpty
      ? widget.photos.map((p) => p.url).toList()
      : [
          if (widget.fallbackUrl != null && widget.fallbackUrl!.isNotEmpty)
            widget.fallbackUrl!,
        ];

  @override
  Widget build(BuildContext context) {
    final urls = _urls;
    if (urls.isEmpty) return _Placeholder(name: widget.name);

    return AspectRatio(
      aspectRatio: 3 / 4,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        child: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: urls.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (context, i) => GestureDetector(
                onTap: () => _openViewer(i),
                child: CachedNetworkImage(
                  imageUrl: absoluteFileUrl(urls[i]),
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.medium,
                  placeholder: (context, url) =>
                      Container(color: AppColors.surface),
                  errorWidget: (context, url, error) =>
                      Container(color: AppColors.surface),
                ),
              ),
            ),
            if (urls.length > 1)
              Positioned(
                left: 0,
                right: 0,
                bottom: 14,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < urls.length; i++)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: i == _index ? 18 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: i == _index ? Colors.white : Colors.white54,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _openViewer(int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (context) =>
            _PhotoViewer(urls: _urls, initial: initialIndex),
      ),
    );
  }
}

/// Нет ни одного фото — крупный круг с инициалом
class _Placeholder extends StatelessWidget {
  const _Placeholder({this.name});

  final String? name;

  @override
  Widget build(BuildContext context) {
    final initial = (name != null && name!.isNotEmpty)
        ? name!.substring(0, 1).toUpperCase()
        : '?';
    return Center(
      child: CircleAvatar(
        radius: 52,
        backgroundColor: AppColors.surface,
        child: Text(
          initial,
          style: const TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _PhotoViewer extends StatelessWidget {
  const _PhotoViewer({required this.urls, required this.initial});

  final List<String> urls;
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
        itemCount: urls.length,
        itemBuilder: (context, index) => InteractiveViewer(
          child: Center(
            child: CachedNetworkImage(
              imageUrl: absoluteFileUrl(urls[index]),
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
