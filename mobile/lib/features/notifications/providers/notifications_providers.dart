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

final notificationsListProvider = FutureProvider<List<AppNotification>>((ref) {
  ref.watch(currentUserIdProvider);
  return ref.read(notificationsApiProvider).list();
});
