import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/notifications_api.dart';
import '../../../core/ws/ws_events.dart';
import '../../auth/providers/session_controller.dart';

/// Бейдж колокольчика. User-scoped + растёт мгновенно по WS-событию
/// notification.new (backend/src/utils/notify.js шлёт его при создании).
final unreadNotificationsProvider = FutureProvider<int>((ref) {
  ref.watch(currentUserIdProvider);
  ref.listen(wsEventsProvider, (_, next) {
    if (next.valueOrNull?.event == 'notification.new') {
      ref.invalidateSelf();
    }
  });
  return ref.read(notificationsApiProvider).unreadCount();
});

/// Список уведомлений. autoDispose — при каждом открытии экрана данные
/// свежие (события могли прийти с другого устройства, см. QA_NOTES №25).
/// Ответ содержит is_read ДО обнуления, поэтому новые подсвечены розовым.
final notificationsListProvider =
    FutureProvider.autoDispose<List<AppNotification>>((ref) {
      ref.watch(currentUserIdProvider);
      ref.listen(wsEventsProvider, (_, next) {
        if (next.valueOrNull?.event == 'notification.new') {
          ref.invalidateSelf();
        }
      });
      return ref.read(notificationsApiProvider).list();
    });
