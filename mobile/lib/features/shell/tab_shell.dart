import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
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

/// Бейдж непрочитанных на вкладке «Сообщения»
class _UnreadBadge extends StatelessWidget {
  const _UnreadBadge({required this.count, required this.child});

  final int count;
  final Widget child;

  @override
  Widget build(BuildContext context) => Badge(
    isLabelVisible: count > 0,
    backgroundColor: AppColors.coral,
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
      case 0:
        ref.invalidate(datingProfileProvider);
        ref.read(deckControllerProvider.notifier).load();
      case 3:
        invalidateFriendship(ref);
      case 4:
        ref.read(sessionControllerProvider.notifier).refreshProfile();
    }
    ref.read(shellTabIndexProvider.notifier).state = i;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final index = ref.watch(shellTabIndexProvider);
    final unread = ref.watch(totalUnreadProvider);
    return Scaffold(
      body: IndexedStack(
        index: index,
        children: [
          const DatingTabScreen(),
          const ServicesListScreen(),
          const ChatsTabScreen(),
          const FriendsTabScreen(),
          const MyProfileTab(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: BottomNavigationBar(
          currentIndex: index,
          onTap: (i) => _openTab(ref, i),
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.background,
          // Выделение активной вкладки только цветом — как в макетах
          selectedItemColor: AppColors.coral,
          unselectedItemColor: AppColors.textSecondary,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.favorite_border, size: 26),
              activeIcon: const Icon(Icons.favorite, size: 26),
              label: l10n.tabDating,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.grid_view_outlined, size: 26),
              activeIcon: const Icon(Icons.grid_view, size: 26),
              label: l10n.tabServices,
            ),
            BottomNavigationBarItem(
              icon: _UnreadBadge(
                count: unread,
                child: const Icon(Icons.chat_bubble_outline, size: 26),
              ),
              activeIcon: _UnreadBadge(
                count: unread,
                child: const Icon(Icons.chat_bubble, size: 26),
              ),
              label: l10n.tabMessages,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.people_outline, size: 26),
              activeIcon: const Icon(Icons.people, size: 26),
              label: l10n.tabFriends,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline, size: 26),
              activeIcon: const Icon(Icons.person, size: 26),
              label: l10n.tabProfile,
            ),
          ],
        ),
      ),
    );
  }
}
