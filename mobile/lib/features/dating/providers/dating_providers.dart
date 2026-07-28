import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/dating_api.dart';
import '../../auth/providers/session_controller.dart';

// User-scoped: сбрасываются при смене аккаунта (см. QA_NOTES №22)

final datingProfileProvider = FutureProvider<DatingProfile>((ref) {
  ref.watch(currentUserIdProvider);
  return ref.read(datingApiProvider).getProfile();
});

/// Колода: локально снимаем свайпнутые карточки, подгружаем новую пачку,
/// когда осталось мало (сервер сам исключает уже свайпнутых).
class DeckState {
  const DeckState({
    this.cards = const [],
    this.loading = true,
    this.limitReached = false,
  });

  final List<DeckCard> cards;
  final bool loading;

  /// Достигнут суточный лимит лайков (100/сутки, мастер-ТЗ §7)
  final bool limitReached;

  DeckState copyWith({
    List<DeckCard>? cards,
    bool? loading,
    bool? limitReached,
  }) => DeckState(
    cards: cards ?? this.cards,
    loading: loading ?? this.loading,
    limitReached: limitReached ?? this.limitReached,
  );
}

class DeckController extends StateNotifier<DeckState> {
  DeckController(this._ref) : super(const DeckState()) {
    load();
  }

  final Ref _ref;

  DatingApi get _api => _ref.read(datingApiProvider);

  Future<void> load() async {
    state = state.copyWith(loading: true);
    try {
      final cards = await _api.deck();
      state = state.copyWith(cards: cards, loading: false);
    } on ApiException {
      state = state.copyWith(cards: [], loading: false);
    }
  }

  /// Свайп верхней карточки. Возвращает данные мэтча, если он случился.
  Future<DatingMatch?> swipeTop({required bool like}) async {
    if (state.cards.isEmpty) return null;
    final card = state.cards.first;
    // сразу убираем карточку — интерфейс не ждёт сервер
    state = state.copyWith(cards: state.cards.skip(1).toList());
    try {
      final result = await _api.swipe(card.id, like: like);
      if (state.cards.length <= 2) await load();
      if (result.match) return result.user;
    } on ApiException catch (e) {
      if (e.error == 'LIKE_LIMIT_REACHED') {
        state = state.copyWith(limitReached: true);
      }
    }
    return null;
  }
}

final deckControllerProvider =
    StateNotifierProvider.autoDispose<DeckController, DeckState>(
      (ref) => DeckController(ref),
    );
