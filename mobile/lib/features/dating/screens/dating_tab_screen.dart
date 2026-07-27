import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/dating_api.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/providers/session_controller.dart';
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
      data: (profile) =>
          profile.isActive ? const _DeckView() : _EnableView(profile: profile),
    );
  }
}

/// Экран 19 «Включение знакомств».
class _EnableView extends ConsumerStatefulWidget {
  const _EnableView({required this.profile});

  final DatingProfile profile;

  @override
  ConsumerState<_EnableView> createState() => _EnableViewState();
}

class _EnableViewState extends ConsumerState<_EnableView> {
  bool _submitting = false;

  Future<void> _enable() async {
    final l10n = AppLocalizations.of(context)!;
    // Нужны имя, фото, пол и дата рождения — иначе сначала в профиль
    if (!widget.profile.eligible) {
      final goToProfile = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.datingProfileIncompleteTitle),
          content: Text(l10n.datingProfileIncompleteBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.editProfile),
            ),
          ],
        ),
      );
      if (goToProfile == true && mounted) {
        context.push('/settings/edit-profile');
      }
      return;
    }
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
  const _DeckView();

  @override
  ConsumerState<_DeckView> createState() => _DeckViewState();
}

class _DeckViewState extends ConsumerState<_DeckView> {
  Offset _drag = Offset.zero;
  bool _animating = false;

  Future<void> _swipe({required bool like}) async {
    if (_animating) return;
    setState(() => _animating = true);
    final match = await ref
        .read(deckControllerProvider.notifier)
        .swipeTop(like: like);
    if (mounted) {
      setState(() {
        _drag = Offset.zero;
        _animating = false;
      });
    }
    if (match != null && mounted) {
      // Экран 08 «Это мэтч!» поверх колоды
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => MatchScreen(match: match),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final deck = ref.watch(deckControllerProvider);

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 12, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.tabDating,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.tune),
                  onPressed: () => context.push('/dating/settings'),
                ),
              ],
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
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // следующая карточка — фоном
                        if (deck.cards.length > 1)
                          Transform.scale(
                            scale: 0.95,
                            child: _DeckCardView(card: deck.cards[1]),
                          ),
                        GestureDetector(
                          onPanUpdate: (d) => setState(() => _drag += d.delta),
                          onPanEnd: (_) {
                            if (_drag.dx.abs() > 100) {
                              _swipe(like: _drag.dx > 0);
                            } else {
                              setState(() => _drag = Offset.zero);
                            }
                          },
                          onTap: () =>
                              context.push('/users/${deck.cards.first.id}'),
                          child: Transform.translate(
                            offset: _drag,
                            child: Transform.rotate(
                              angle: _drag.dx / 1200,
                              child: _DeckCardView(
                                card: deck.cards.first,
                                overlayLike: _drag.dx > 40,
                                overlayPass: _drag.dx < -40,
                              ),
                            ),
                          ),
                        ),
                      ],
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
                    onTap: () => _swipe(like: false),
                  ),
                  const SizedBox(width: 32),
                  _RoundActionButton(
                    icon: Icons.favorite,
                    color: AppColors.coral,
                    onTap: () => _swipe(like: true),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _DeckCardView extends StatelessWidget {
  const _DeckCardView({
    required this.card,
    this.overlayLike = false,
    this.overlayPass = false,
  });

  final DeckCard card;
  final bool overlayLike;
  final bool overlayPass;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.large),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (card.avatarUrl != null && card.avatarUrl!.isNotEmpty)
            CachedNetworkImage(
              imageUrl: absoluteFileUrl(card.avatarUrl!),
              fit: BoxFit.cover,
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
          if (overlayLike)
            const _SwipeOverlay(color: AppColors.coral, icon: Icons.favorite),
          if (overlayPass)
            const _SwipeOverlay(color: Colors.white, icon: Icons.close),
        ],
      ),
    );
  }
}

class _SwipeOverlay extends StatelessWidget {
  const _SwipeOverlay({required this.color, required this.icon});

  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black26,
      alignment: Alignment.center,
      child: Icon(icon, size: 96, color: color),
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
