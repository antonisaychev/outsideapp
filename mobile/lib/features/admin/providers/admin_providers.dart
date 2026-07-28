import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/admin_api.dart';

/// Поисковый запрос на вкладке «Пользователи»
final adminUserQueryProvider = StateProvider.autoDispose<String>((ref) => '');

final adminUsersProvider = FutureProvider.autoDispose<List<AdminUser>>((ref) {
  final query = ref.watch(adminUserQueryProvider);
  return ref.read(adminApiProvider).users(query: query);
});

/// Фильтр статуса на вкладке «Сервисы»: null = все
final adminServiceStatusProvider = StateProvider.autoDispose<String?>(
  (ref) => null,
);

final adminServicesProvider = FutureProvider.autoDispose<List<AdminService>>((
  ref,
) {
  final status = ref.watch(adminServiceStatusProvider);
  return ref.read(adminApiProvider).services(status: status);
});

final adminReportsProvider = FutureProvider.autoDispose<List<AdminReport>>(
  (ref) => ref.read(adminApiProvider).reports(),
);

final adminCategoriesProvider = FutureProvider.autoDispose<List<AdminCategory>>(
  (ref) => ref.read(adminApiProvider).categories(),
);
