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
    this.seed = '',
  });

  final String tab;
  final int cityId;
  final int? categoryId;

  /// Зерно перемешивания: одно на заход в раздел, меняется при обновлении —
  /// иначе при подгрузке страниц карточки повторялись бы
  final String seed;

  @override
  bool operator ==(Object other) =>
      other is ServicesListKey &&
      other.tab == tab &&
      other.cityId == cityId &&
      other.categoryId == categoryId &&
      other.seed == seed;

  @override
  int get hashCode => Object.hash(tab, cityId, categoryId, seed);
}

final servicesListProvider =
    FutureProvider.family<List<ServiceSummary>, ServicesListKey>(
      (ref, key) => ref
          .read(servicesApiProvider)
          .list(
            tab: key.tab,
            cityId: key.cityId,
            categoryId: key.categoryId,
            seed: key.seed,
          ),
    );

/// Категории для текущего места: пустые фильтры не показываем
final placeCategoriesProvider = FutureProvider<List<ServiceCategory>>((ref) {
  final cityId = ref.watch(viewCityIdProvider);
  return ref.read(servicesApiProvider).getCategories(cityId: cityId);
});

// Деталка содержит liked_by_me/is_favorite — сбрасываем при смене аккаунта
final serviceDetailProvider = FutureProvider.autoDispose
    .family<ServiceDetail, String>((ref, id) {
      ref.watch(currentUserIdProvider);
      return ref.read(servicesApiProvider).getById(id);
    });

final favoritesProvider = FutureProvider<List<ServiceSummary>>((ref) {
  ref.watch(currentUserIdProvider);
  return ref.read(servicesApiProvider).favorites();
});
