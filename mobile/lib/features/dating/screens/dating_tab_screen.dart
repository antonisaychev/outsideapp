import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/tab_header.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/chats_api.dart';
import '../../../core/api/dating_api.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/providers/session_controller.dart';
import '../../chats/providers/chats_providers.dart';
import '../providers/dating_providers.dart';
import 'match_screen.dart';

/// Вкладка «Знакомства»: экран 19 (включение) → 07 (колода).
class DatingTabScreen extends ConsumerWidget {
  const DatingTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final session = ref.watch(sessionControllerProvider);

    if (session.status != SessionStatus.ready) {
      return SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.guestDatingTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.push('/register'),
                  child: Text(l10n.createAccount),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => context.push('/login'),
                  child: Text(l10n.login),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final profileAsync = ref.watch(datingProfileProvider);
    return profileAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, st) => Center(
        child: TextButton(
          onPressed: () => ref.invalidate(datingProfileProvider),
          child: Text(l10n.retry),
        ),
      ),
      // Знакомства включены по умолчанию; выключить можно в настройках раздела
      data: (profile) =>
          profile.isActive ? _DeckView(profile: profile) : _DisabledView(),
    );
  }
}

/// Экран 19: знакомства выключены самим пользователем — предлагаем вернуть.
class _DisabledView extends ConsumerStatefulWidget {
  const _DisabledView();

  @override
  ConsumerState<_DisabledView> createState() => _DisabledViewState();
}

class _DisabledViewState extends ConsumerState<_DisabledView> {
  bool _submitting = false;

  Future<void> _enable() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _submitting = true);
    try {
      await ref.read(datingApiProvider).updateProfile(isActive: true);
      ref.invalidate(datingProfileProvider);
    } on ApiException {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.genericError)));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 88,
              height: 88,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.coralTint,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite,
                size: 40,
                color: AppColors.coral,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.datingEnableTitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.datingEnableBody,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _submitting ? null : _enable,
              child: _submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(l10n.datingEnableButton),
            ),
          ],
        ),
      ),
    );
  }
}

/// Экран 07 «Колода»: свайп вправо/влево или кнопки.
class _DeckView extends ConsumerStatefulWidget {
  const _DeckView({required this.profile});

  final DatingProfile profile;

  @override
  ConsumerState<_DeckView> createState() => _DeckViewState();
}

/// Куда ведёт текущая анимация карточки
enum _Flight { none, returning, leaving }

class _DeckViewState extends ConsumerState<_DeckView>
    with SingleTickerProviderStateMixin {
  /// Смещение карточки. ValueNotifier, а не setState: перерисовывается
  /// только трансформация, само фото не пересобирается на каждый кадр.
  final _drag = ValueNotifier<Offset>(Offset.zero);

  late final AnimationController _controller;
  _Flight _flight = _Flight.none;
  Offset _flightFrom = Offset.zero;
  Offset _flightTo = Offset.zero;

  /// Порог принятия свайпа и скорость броска, при которой порог не нужен
  static const _distanceThreshold = 110.0;
  static const _velocityThreshold = 800.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController.unbounded(vsync: this)
      ..addListener(_onTick);
  }

  @override
  void dispose() {
    _controller.dispose();
    _drag.dispose();
    super.dispose();
  }

  void _onTick() {
    switch (_flight) {
      case _Flight.returning:
        // Пружина возвращает карточку в центр
        _drag.value = Offset.lerp(_flightFrom, Offset.zero, _controller.value)!;
      case _Flight.leaving:
        _drag.value = Offset.lerp(
          _flightFrom,
          _flightTo,
          Curves.easeOut.transform(_controller.value.clamp(0.0, 1.0)),
        )!;
      case _Flight.none:
        break;
    }
  }

  void _onPanStart(DragStartDetails _) {
    if (_flight == _Flight.leaving) return;
    _controller.stop();
    _flight = _Flight.none;
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (_flight == _Flight.leaving) return;
    _drag.value += d.delta;
  }

  void _onPanEnd(DragEndDetails d) {
    if (_flight == _Flight.leaving) return;
    final velocity = d.velocity.pixelsPerSecond;
    final dx = _drag.value.dx;
    final accepted =
        dx.abs() > _distanceThreshold ||
        (velocity.dx.abs() > _velocityThreshold && dx.abs() > 20);
    if (accepted) {
      _fly(like: dx > 0 || (dx.abs() <= 20 && velocity.dx > 0), velocity: velocity);
    } else {
      _settleBack(velocity);
    }
  }

  /// Мягкий пружинный возврат с учётом того, с какой скоростью отпустили
  void _settleBack(Offset velocity) {
    final from = _drag.value;
    if (from == Offset.zero) return;
    // Скорость вдоль направления «к центру», нормированная к отрезку 0..1
    final unitVelocity =
        -(velocity.dx * from.dx + velocity.dy * from.dy) /
        (from.distanceSquared);
    _flightFrom = from;
    _flight = _Flight.returning;
    _controller
        .animateWith(
          SpringSimulation(
            const SpringDescription(mass: 1, stiffness: 320, damping: 26),
            0,
            1,
            unitVelocity.clamp(-8.0, 8.0),
          ),
        )
        .then((_) {
          // Пружина затухает около единицы — добиваем ровно в центр
          if (mounted && _flight == _Flight.returning) {
            _flight = _Flight.none;
            _drag.value = Offset.zero;
          }
        });
  }

  /// Карточка улетает за край экрана, продолжая движение руки
  void _fly({required bool like, Offset velocity = Offset.zero}) {
    if (_flight == _Flight.leaving) return;
    final width = MediaQuery.sizeOf(context).width;
    _flightFrom = _drag.value;
    _flightTo = Offset(
      (like ? 1 : -1) * (width + 250),
      _drag.value.dy + velocity.dy * 0.15,
    );
    _flight = _Flight.leaving;
    _controller.value = 0;
    // Контроллер unbounded (нужен для пружины), поэтому animateTo, не forward
    _controller
        .animateTo(1, duration: const Duration(milliseconds: 260))
        .then((_) {
          if (mounted) _commit(like: like);
        });
  }

  /// Свайп ушёл на сервер; карточка снимается с колоды мгновенно
  Future<void> _commit({required bool like}) async {
    final pending = ref
        .read(deckControllerProvider.notifier)
        .swipeTop(like: like);
    // Колода уже сдвинулась (снятие карточки синхронное) — возвращаем позицию
    _flight = _Flight.none;
    _drag.value = Offset.zero;
    final match = await pending;
    if (!mounted || match == null) return;

    // Диалог готовим заранее: кнопка «Написать» не должна ждать сеть
    String? conversationId;
    try {
      conversationId = await ref.read(chatsApiProvider).openWith(match.id);
    } catch (_) {
      // не страшно — попробуем ещё раз по нажатию кнопки
    }
    if (!mounted) return;

    // Экран 08 «Это мэтч!» — поверх всего, вместе с нижними вкладками
    final write = await Navigator.of(context, rootNavigator: true).push<bool>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => MatchScreen(match: match),
      ),
    );
    // Чат открываем отсюда: у экрана мэтча после закрытия context уже мёртв
    if (write != true || !mounted) return;
    if (conversationId != null) {
      context.push('/chats/$conversationId?peer=${match.id}');
    } else {
      await openChatWith(context, ref, match.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final deck = ref.watch(deckControllerProvider);

    return SafeArea(
      child: Column(
        children: [
          TabHeader(
            title: l10n.tabDating,
            actions: [
              HeaderIconButton(
                icon: const Icon(Icons.tune),
                onPressed: () => context.push('/dating/settings'),
              ),
            ],
          ),
          // Без фото/пола/даты рождения карточка не показывается другим
          if (!widget.profile.eligible)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.coralTint,
                  borderRadius: BorderRadius.circular(AppRadius.small),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.datingIncompleteBanner,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.35,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () => context.push('/settings/edit-profile'),
                      child: Text(l10n.datingIncompleteAction),
                    ),
                  ],
                ),
              ),
            ),
          if (deck.limitReached)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text(
                l10n.likeLimitReached,
                style: const TextStyle(color: AppColors.error, fontSize: 13),
              ),
            ),
          Expanded(
            child: deck.loading
                ? const Center(child: CircularProgressIndicator())
                : deck.cards.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            l10n.deckEmpty,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () => ref
                                .read(deckControllerProvider.notifier)
                                .load(),
                            child: Text(l10n.retry),
                          ),
                        ],
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                    child: ValueListenableBuilder<Offset>(
                      valueListenable: _drag,
                      // Фото карточек в child — они не пересобираются при таскании
                      child: _DeckCardView(
                        key: ValueKey(deck.cards.first.id),
                        card: deck.cards.first,
                      ),
                      builder: (context, drag, card) {
                        // 0 → карточка в центре, 1 → на пороге принятия
                        final progress = (drag.dx.abs() / _distanceThreshold)
                            .clamp(0.0, 1.0);
                        // значок проступает не сразу, а после первых 25 px
                        final overlay = ((drag.dx.abs() - 25) / 85).clamp(
                          0.0,
                          1.0,
                        );
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            // следующая карточка — фоном, подрастает по мере свайпа
                            if (deck.cards.length > 1)
                              Transform.scale(
                                scale: 0.94 + 0.06 * progress,
                                child: _DeckCardView(
                                  key: ValueKey(deck.cards[1].id),
                                  card: deck.cards[1],
                                ),
                              ),
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onPanStart: _onPanStart,
                              onPanUpdate: _onPanUpdate,
                              onPanEnd: _onPanEnd,
                              onTap: () =>
                                  context.push('/users/${deck.cards.first.id}'),
                              child: Transform.translate(
                                offset: drag,
                                child: Transform.rotate(
                                  // наклон как в Tinder: тем сильнее, чем дальше увели
                                  angle: drag.dx / 2200,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.large,
                                    ),
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        card!,
                                        if (overlay > 0)
                                          Opacity(
                                            opacity: overlay,
                                            child: _SwipeOverlay(
                                              scale: 0.7 + 0.3 * overlay,
                                              color: drag.dx > 0
                                                  ? AppColors.coral
                                                  : Colors.white,
                                              icon: drag.dx > 0
                                                  ? Icons.favorite
                                                  : Icons.close,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
          ),
          if (!deck.loading && deck.cards.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16, top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _RoundActionButton(
                    icon: Icons.close,
                    color: AppColors.textSecondary,
                    onTap: () => _fly(like: false),
                  ),
                  const SizedBox(width: 32),
                  _RoundActionButton(
                    icon: Icons.favorite,
                    color: AppColors.coral,
                    onTap: () => _fly(like: true),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _DeckCardView extends StatefulWidget {
  const _DeckCardView({super.key, required this.card});

  final DeckCard card;

  @override
  State<_DeckCardView> createState() => _DeckCardViewState();
}

class _DeckCardViewState extends State<_DeckCardView> {
  int _photoIndex = 0;

  DeckCard get card => widget.card;

  /// Все фото анкеты; если галереи нет — одно главное
  List<String> get _urls => card.photos.isNotEmpty
      ? card.photos.map((p) => p.url).toList()
      : [if (card.avatarUrl != null && card.avatarUrl!.isNotEmpty) card.avatarUrl!];

  void _step(int delta) {
    final urls = _urls;
    if (urls.length < 2) return;
    setState(() => _photoIndex = (_photoIndex + delta) % urls.length);
  }

  @override
  Widget build(BuildContext context) {
    final urls = _urls;
    final photoUrl = urls.isEmpty
        ? null
        : urls[_photoIndex.clamp(0, urls.length - 1)];
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.large),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (photoUrl != null)
            CachedNetworkImage(
              imageUrl: absoluteFileUrl(photoUrl),
              fit: BoxFit.cover,
              filterQuality: FilterQuality.medium,
              fadeInDuration: const Duration(milliseconds: 120),
              placeholder: (context, url) =>
                  Container(color: AppColors.surface),
              errorWidget: (context, url, error) =>
                  Container(color: AppColors.surface),
            )
          else
            Container(color: AppColors.surface),
          // затемнение снизу под текст
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.center,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black87],
              ),
            ),
          ),
          if (urls.length > 1) ...[
            // зоны листания фото: левая и правая трети карточки
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => _step(-1),
                  ),
                ),
                const Spacer(),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => _step(1),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Row(
                children: [
                  for (var i = 0; i < urls.length; i++)
                    Expanded(
                      child: Container(
                        height: 3,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: i == _photoIndex
                              ? Colors.white
                              : Colors.white38,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.age != null
                      ? '${card.displayName}, ${card.age}'
                      : card.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (card.bio != null && card.bio!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    card.bio!,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SwipeOverlay extends StatelessWidget {
  const _SwipeOverlay({
    required this.color,
    required this.icon,
    this.scale = 1,
  });

  final Color color;
  final IconData icon;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black26,
      alignment: Alignment.center,
      child: Transform.scale(
        scale: scale,
        child: Icon(icon, size: 96, color: color),
      ),
    );
  }
}

class _RoundActionButton extends StatelessWidget {
  const _RoundActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 64,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, size: 30, color: color),
      ),
    );
  }
}
