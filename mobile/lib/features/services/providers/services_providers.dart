import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/models.dart';
import '../../../core/api/services_api.dart';
import '../../auth/providers/session_controller.dart';

/// Место просмотра раздела «Сервисы»: по умолчанию — из профиля,
/// для гостя — Бали (id 1); переключатель в шапке не меняет профиль.
final viewCityIdProvider = StateProvider<int>((ref) {
  final profile = ref.watch(sessionControllerProvider.select((s) => s.profile));
  return profile?.cityId ?? 1;
});

/// Выбранная категория-фильтр (null = «Все»).
final selectedCategoryProvider = StateProvider<int?>((ref) => null);

class ServicesListKey {
  const ServicesListKey({
    required this.tab,
    required this.cityId,
    this.categoryId,
  });

  final String tab;
  final int cityId;
  final int? categoryId;

  @override
  bool operator ==(Object other) =>
      other is ServicesListKey &&
      other.tab == tab &&
      other.cityId == cityId &&
      other.categoryId == categoryId;

  @override
  int get hashCode => Object.hash(tab, cityId, categoryId);
}

final servicesListProvider =
    FutureProvider.family<List<ServiceSummary>, ServicesListKey>(
      (ref, key) => ref
          .read(servicesApiProvider)
          .list(tab: key.tab, cityId: key.cityId, categoryId: key.categoryId),
    );

final serviceDetailProvider = FutureProvider.family<ServiceDetail, String>(
  (ref, id) => ref.read(servicesApiProvider).getById(id),
);

final favoritesProvider = FutureProvider<List<ServiceSummary>>(
  (ref) => ref.read(servicesApiProvider).favorites(),
);
