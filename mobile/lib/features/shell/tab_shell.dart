import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../chats/providers/chats_providers.dart';
import '../chats/screens/chats_tab_screen.dart';
import '../friends/providers/friends_providers.dart';
import '../friends/screens/friends_tab_screen.dart';
import '../profile/screens/my_profile_tab.dart';
import '../services/screens/services_list_screen.dart';

/// Главный экран с 5 вкладками (мастер-ТЗ §13). Реальные: Сервисы,
/// Сообщения, Друзья, Профиль; Знакомства — заглушка до своей итерации.
class TabShell extends ConsumerWidget {
  const TabShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final index = ref.watch(shellTabIndexProvider);
    final unread = ref.watch(totalUnreadProvider);
    return Scaffold(
      body: IndexedStack(
        index: index,
        children: [
          _ComingSoonTab(title: l10n.tabDating),
          const ServicesListScreen(),
          const ChatsTabScreen(),
          const FriendsTabScreen(),
          const MyProfileTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) {
          // Возврат на «Друзья» перезапрашивает списки: изменения могли
          // прийти с другого устройства (IndexedStack держит экран живым)
          if (i == 3) invalidateFriendship(ref);
          ref.read(shellTabIndexProvider.notifier).state = i;
        },
        backgroundColor: AppColors.background,
        indicatorColor: AppColors.coralTint,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.favorite_border),
            selectedIcon: const Icon(Icons.favorite, color: AppColors.coral),
            label: l10n.tabDating,
          ),
          NavigationDestination(
            icon: const Icon(Icons.grid_view_outlined),
            selectedIcon: const Icon(Icons.grid_view, color: AppColors.coral),
            label: l10n.tabServices,
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: unread > 0,
              backgroundColor: AppColors.coral,
              label: Text('$unread'),
              child: const Icon(Icons.chat_bubble_outline),
            ),
            selectedIcon: Badge(
              isLabelVisible: unread > 0,
              backgroundColor: AppColors.coral,
              label: Text('$unread'),
              child: const Icon(Icons.chat_bubble, color: AppColors.coral),
            ),
            label: l10n.tabMessages,
          ),
          NavigationDestination(
            icon: const Icon(Icons.people_outline),
            selectedIcon: const Icon(Icons.people, color: AppColors.coral),
            label: l10n.tabFriends,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person, color: AppColors.coral),
            label: l10n.tabProfile,
          ),
        ],
      ),
    );
  }
}

class _ComingSoonTab extends StatelessWidget {
  const _ComingSoonTab({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              l10n.comingSoonSection,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
