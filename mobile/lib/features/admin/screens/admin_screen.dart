import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import 'admin_categories_tab.dart';
import 'admin_reports_tab.dart';
import 'admin_services_tab.dart';
import 'admin_users_tab.dart';

/// Экраны 26–28, 42 «Администрирование»: один заголовок и четыре вкладки.
class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key});

  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 4, vsync: this);

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.adminTitle,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ),
            ),
            TabBar(
              controller: _tabs,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              labelColor: AppColors.textPrimary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.coral,
              indicatorSize: TabBarIndicatorSize.label,
              dividerColor: Colors.transparent,
              labelStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              tabs: [
                Tab(text: l10n.adminTabUsers),
                Tab(text: l10n.adminTabServices),
                Tab(text: l10n.adminTabReports),
                Tab(text: l10n.adminTabCategories),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: const [
                  AdminUsersTab(),
                  AdminServicesTab(),
                  AdminReportsTab(),
                  AdminCategoriesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Общая обёртка над списком вкладки: загрузка, ошибка, пустое состояние.
class AdminList<T> extends StatelessWidget {
  const AdminList({
    super.key,
    required this.async,
    required this.emptyText,
    required this.onRefresh,
    required this.itemBuilder,
    this.header,
  });

  final AsyncValue<List<T>> async;
  final String emptyText;
  final VoidCallback onRefresh;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final Widget? header;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return async.when(
      loading: () => Column(
        children: [
          ?header,
          const Expanded(child: Center(child: CircularProgressIndicator())),
        ],
      ),
      error: (err, st) => Column(
        children: [
          ?header,
          Expanded(
            child: Center(
              child: TextButton(onPressed: onRefresh, child: Text(l10n.retry)),
            ),
          ),
        ],
      ),
      data: (items) => Column(
        children: [
          ?header,
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => onRefresh(),
              child: items.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 80),
                          child: Center(
                            child: Text(
                              emptyText,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 24),
                      itemCount: items.length,
                      itemBuilder: (context, i) =>
                          itemBuilder(context, items[i]),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
