import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/friends_api.dart';
import '../../../core/api/models.dart';

final friendsListProvider = FutureProvider<List<UserListItem>>(
  (ref) => ref.read(friendsApiProvider).friends(),
);

final incomingRequestsProvider = FutureProvider<List<UserListItem>>(
  (ref) => ref.read(friendsApiProvider).requests(incoming: true),
);

final outgoingRequestsProvider = FutureProvider<List<UserListItem>>(
  (ref) => ref.read(friendsApiProvider).requests(incoming: false),
);

final blockedUsersProvider = FutureProvider<List<UserListItem>>(
  (ref) => ref.read(friendsApiProvider).blocked(),
);

final publicProfileProvider = FutureProvider.family<PublicProfile, String>(
  (ref, id) => ref.read(peopleApiProvider).getById(id),
);

final relationStatusProvider = FutureProvider.family<RelationStatus, String>((
  ref,
  userId,
) async {
  final map = await ref.read(friendsApiProvider).statuses([userId]);
  return map[userId] ?? RelationStatus.none;
});

/// Сброс всех кэшей дружбы после любого действия (заявка/принятие/блок...)
void invalidateFriendship(WidgetRef ref, [String? userId]) {
  ref.invalidate(friendsListProvider);
  ref.invalidate(incomingRequestsProvider);
  ref.invalidate(outgoingRequestsProvider);
  ref.invalidate(blockedUsersProvider);
  if (userId != null) {
    ref.invalidate(relationStatusProvider(userId));
    ref.invalidate(publicProfileProvider(userId));
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

final peopleSearchProvider =
    FutureProvider.family<List<UserListItem>, PeopleSearchQuery>(
      (ref, query) => ref
          .read(peopleApiProvider)
          .search(
            q: query.q,
            cityId: query.cityId,
            homeCountry: query.homeCountry,
          ),
    );
