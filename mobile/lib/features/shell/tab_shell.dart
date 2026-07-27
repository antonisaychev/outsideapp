import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../friends/providers/friends_providers.dart';
import '../friends/screens/friends_tab_screen.dart';
import '../profile/screens/my_profile_tab.dart';
import '../services/screens/services_list_screen.dart';

/// Главный экран с 5 вкладками (мастер-ТЗ §13). Реальные: Сервисы, Друзья,
/// Профиль; Знакомства и Сообщения — заглушки до своих итераций.
class TabShell extends ConsumerStatefulWidget {
  const TabShell({super.key});

  @override
  ConsumerState<TabShell> createState() => _TabShellState();
}

class _TabShellState extends ConsumerState<TabShell> {
  // Стартуем с «Сервисов» (индекс 1) — гостевой раздел по ТЗ
  int _index = 1;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          _ComingSoonTab(title: l10n.tabDating),
          const ServicesListScreen(),
          _ComingSoonTab(title: l10n.tabMessages),
          const FriendsTabScreen(),
          const MyProfileTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) {
          // Возврат на «Друзья» перезапрашивает списки: изменения могли
          // прийти с другого устройства (IndexedStack держит экран живым)
          if (i == 3) invalidateFriendship(ref);
          setState(() => _index = i);
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
            icon: const Icon(Icons.chat_bubble_outline),
            selectedIcon: const Icon(Icons.chat_bubble, color: AppColors.coral),
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
