import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/friends_api.dart';
import '../../../core/api/models.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/providers/session_controller.dart';

// Все списки user-scoped: watch(currentUserIdProvider) сбрасывает кэш
// при смене аккаунта (выход/вход другим пользователем).

final friendsListProvider = FutureProvider<List<UserListItem>>((ref) {
  ref.watch(currentUserIdProvider);
  return ref.read(friendsApiProvider).friends();
});

final incomingRequestsProvider = FutureProvider<List<UserListItem>>((ref) {
  ref.watch(currentUserIdProvider);
  return ref.read(friendsApiProvider).requests(incoming: true);
});

final outgoingRequestsProvider = FutureProvider<List<UserListItem>>((ref) {
  ref.watch(currentUserIdProvider);
  return ref.read(friendsApiProvider).requests(incoming: false);
});

final blockedUsersProvider = FutureProvider<List<UserListItem>>((ref) {
  ref.watch(currentUserIdProvider);
  return ref.read(friendsApiProvider).blocked();
});

final publicProfileProvider = FutureProvider.autoDispose
    .family<PublicProfile, String>(
      (ref, id) => ref.read(peopleApiProvider).getById(id),
    );

final relationStatusProvider = FutureProvider.autoDispose
    .family<RelationStatus, String>((ref, userId) async {
      ref.watch(currentUserIdProvider);
      final map = await ref.read(friendsApiProvider).statuses([userId]);
      return map[userId] ?? RelationStatus.none;
    });

/// Пакетные статусы отношений (для поиска людей и других списков).
/// Ключ — id через запятую. Живёт здесь, чтобы invalidateFriendship
/// сбрасывал и его.
final relationStatusesProvider = FutureProvider.autoDispose
    .family<Map<String, RelationStatus>, String>((ref, idsCsv) {
      ref.watch(currentUserIdProvider);
      final ids = idsCsv.split(',').where((s) => s.isNotEmpty).toList();
      return ref.read(friendsApiProvider).statuses(ids);
    });

/// Сброс всех кэшей дружбы после любого действия (заявка/принятие/блок...)
void invalidateFriendship(WidgetRef ref, [String? userId]) {
  ref.invalidate(friendsListProvider);
  ref.invalidate(incomingRequestsProvider);
  ref.invalidate(outgoingRequestsProvider);
  ref.invalidate(blockedUsersProvider);
  ref.invalidate(relationStatusesProvider); // все инстансы family
  if (userId != null) {
    ref.invalidate(relationStatusProvider(userId));
    ref.invalidate(publicProfileProvider(userId));
  }
}

/// Обёртка для действий дружбы: ошибка сервера показывается тостом (а не
/// глотается молча), кэши сбрасываются ВСЕГДА — даже если запрос упал
/// (иначе интерфейс остаётся с устаревшими кнопками, см. QA_NOTES №24).
Future<void> runFriendAction(
  WidgetRef ref,
  BuildContext context,
  String? userId,
  Future<void> Function() action,
) async {
  try {
    await action();
  } on ApiException {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.genericError)),
      );
    }
  } finally {
    invalidateFriendship(ref, userId);
  }
}

class PeopleSearchQuery {
  const PeopleSearchQuery({this.q, this.cityId, this.homeCountry});

  final String? q;
  final int? cityId;
  final String? homeCountry;

  @override
  bool operator ==(Object other) =>
      other is PeopleSearchQuery &&
      other.q == q &&
      other.cityId == cityId &&
      other.homeCountry == homeCountry;

  @override
  int get hashCode => Object.hash(q, cityId, homeCountry);
}

final peopleSearchProvider = FutureProvider.autoDispose
    .family<List<UserListItem>, PeopleSearchQuery>(
      (ref, query) => ref
          .read(peopleApiProvider)
          .search(
            q: query.q,
            cityId: query.cityId,
            homeCountry: query.homeCountry,
          ),
    );
