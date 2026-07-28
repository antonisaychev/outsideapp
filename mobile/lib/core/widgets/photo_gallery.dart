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
              itemBuilder: (context, i) => CachedNetworkImage(
                imageUrl: absoluteFileUrl(urls[i]),
                fit: BoxFit.cover,
                filterQuality: FilterQuality.medium,
                placeholder: (context, url) =>
                    Container(color: AppColors.surface),
                errorWidget: (context, url, error) =>
                    Container(color: AppColors.surface),
              ),
            ),
            // Тап по левой/правой половине листает; свайп по-прежнему работает —
            // при перетаскивании жест уходит в PageView
            if (urls.length > 1)
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () => _step(-1, urls.length),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () => _step(1, urls.length),
                    ),
                  ),
                ],
              ),
            if (urls.length > 1)
              Positioned(
                left: 0,
                right: 0,
                bottom: 14,
                // точки не должны перехватывать тап по нижней части фото
                child: IgnorePointer(
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
              ),
          ],
        ),
      ),
    );
  }

  /// Соседнее фото по кругу: с последнего — снова на первое
  void _step(int delta, int count) {
    final next = (_index + delta + count) % count;
    _controller.animateToPage(
      next,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
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
