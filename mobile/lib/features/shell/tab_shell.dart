import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../l10n/app_localizations.dart';
import '../chats/providers/chats_providers.dart';
import '../chats/screens/chats_tab_screen.dart';
import '../auth/providers/session_controller.dart';
import '../dating/providers/dating_providers.dart';
import '../dating/screens/dating_tab_screen.dart';
import '../friends/providers/friends_providers.dart';
import '../friends/screens/friends_tab_screen.dart';
import '../profile/screens/my_profile_tab.dart';
import '../services/screens/services_list_screen.dart';

/// Номера вкладок — по порядку из макетов Outside 2.0.
/// Порядок задаётся здесь: экраны переключают вкладки только этими константами.
class ShellTab {
  ShellTab._();

  static const dating = 0;
  static const friends = 1;
  static const services = 2;
  static const chats = 3;
  static const profile = 4;
}

/// Счётчик на иконке вкладки: непрочитанные сообщения, входящие заявки
class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count, required this.child});

  final int count;
  final Widget child;

  @override
  Widget build(BuildContext context) => Badge(
    isLabelVisible: count > 0,
    backgroundColor: AppColors.coral,
    textColor: Colors.white,
    textStyle: AppText.caption.copyWith(
      color: Colors.white,
      fontSize: 10.5,
      height: 1,
    ),
    label: Text('$count'),
    child: child,
  );
}

/// Главный экран с 5 вкладками (мастер-ТЗ §13) — все разделы реальные.
class TabShell extends ConsumerWidget {
  const TabShell({super.key});

  void _openTab(WidgetRef ref, int i) {
    // IndexedStack держит экраны живыми, поэтому свежесть обеспечиваем сами
    switch (i) {
      case ShellTab.dating:
        ref.invalidate(datingProfileProvider);
        ref.read(deckControllerProvider.notifier).load();
      case ShellTab.friends:
        invalidateFriendship(ref);
      case ShellTab.profile:
        ref.read(sessionControllerProvider.notifier).refreshProfile();
    }
    ref.read(shellTabIndexProvider.notifier).state = i;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final index = ref.watch(shellTabIndexProvider);
    final unread = ref.watch(totalUnreadProvider);
    final requests =
        ref.watch(incomingRequestsProvider).valueOrNull?.length ?? 0;

    return Scaffold(
      body: IndexedStack(
        index: index,
        children: const [
          DatingTabScreen(),
          FriendsTabScreen(),
          ServicesListScreen(),
          ChatsTabScreen(),
          MyProfileTab(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.neutral0,
          border: Border(top: BorderSide(color: AppColors.neutral200)),
        ),
        child: BottomNavigationBar(
          currentIndex: index,
          onTap: (i) => _openTab(ref, i),
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.neutral0,
          // Выделение активной вкладки только цветом — как в макетах
          selectedItemColor: AppColors.coral,
          unselectedItemColor: AppColors.neutral400,
          selectedLabelStyle: AppText.caption.copyWith(color: AppColors.coral),
          unselectedLabelStyle: AppText.caption,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.favorite_border, size: 25),
              activeIcon: const Icon(Icons.favorite, size: 25),
              label: l10n.tabDating,
            ),
            BottomNavigationBarItem(
              icon: _CountBadge(
                count: requests,
                child: const Icon(Icons.people_outline, size: 25),
              ),
              activeIcon: _CountBadge(
                count: requests,
                child: const Icon(Icons.people, size: 25),
              ),
              label: l10n.tabFriends,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.grid_view_outlined, size: 25),
              activeIcon: const Icon(Icons.grid_view, size: 25),
              label: l10n.tabServices,
            ),
            BottomNavigationBarItem(
              icon: _CountBadge(
                count: unread,
                child: const Icon(Icons.chat_bubble_outline, size: 25),
              ),
              activeIcon: _CountBadge(
                count: unread,
                child: const Icon(Icons.chat_bubble, size: 25),
              ),
              label: l10n.tabMessages,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline, size: 25),
              activeIcon: const Icon(Icons.person, size: 25),
              label: l10n.tabProfile,
            ),
          ],
        ),
      ),
    );
  }
}
