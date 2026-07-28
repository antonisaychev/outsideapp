import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/friends_api.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/utils/localized_names.dart';
import '../../../core/api/models.dart';
import '../../../core/api/users_api.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/data/countries.dart';
import '../../auth/providers/session_controller.dart';
import '../providers/friends_providers.dart';

enum _Filter { compatriots, sameCity }

/// Экран 22 «Поиск людей»: live-поиск (debounce 300мс) + чипы
/// «Земляки» / «Все на {городе}».
class PeopleSearchScreen extends ConsumerStatefulWidget {
  const PeopleSearchScreen({super.key});

  @override
  ConsumerState<PeopleSearchScreen> createState() => _PeopleSearchScreenState();
}

class _PeopleSearchScreenState extends ConsumerState<PeopleSearchScreen> {
  final _searchController = TextEditingController();
  _Filter _filter = _Filter.sameCity;
  String _query = '';
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _query = value.trim());
    });
  }

  PeopleSearchQuery _buildQuery(MeProfile? me) {
    return PeopleSearchQuery(
      q: _query.isEmpty ? null : _query,
      cityId: me?.cityId,
      homeCountry: _filter == _Filter.compatriots ? me?.homeCountry : null,
    );
  }

  Future<void> _sendRequest(UserListItem user) async {
    await runFriendAction(
      ref,
      context,
      user.id,
      () => ref.read(friendsApiProvider).sendRequest(user.id),
    );
  }

  Future<void> _cancelRequest(UserListItem user) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.cancelRequestTitle),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              l10n.cancelRequest,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      if (!mounted) return;
      await runFriendAction(
        ref,
        context,
        user.id,
        () => ref.read(friendsApiProvider).cancelRequest(user.id),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final me = ref.watch(sessionControllerProvider).profile;
    final cities = ref.watch(citiesProvider).valueOrNull ?? const <City>[];
    String cityName(int? id) {
      for (final c in cities) {
        if (c.id == id) return localizedName(context, c.nameRu, c.nameEn);
      }
      return '';
    }

    String countryFlag(String? code) {
      if (code == null) return '';
      for (final c in allCountries) {
        if (c.code == code) return c.flag;
      }
      return '';
    }

    final resultsAsync = ref.watch(peopleSearchProvider(_buildQuery(me)));

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
              child: Text(
                l10n.peopleSearchTitle,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextField(
                controller: _searchController,
                onChanged: _onQueryChanged,
                decoration: InputDecoration(
                  hintText: l10n.peopleSearchHint,
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  _FilterChip(
                    label:
                        '${countryFlag(me?.homeCountry)} ${l10n.compatriots}',
                    selected: _filter == _Filter.compatriots,
                    onTap: () => setState(() => _filter = _Filter.compatriots),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: l10n.allInCity(cityName(me?.cityId)),
                    selected: _filter == _Filter.sameCity,
                    onTap: () => setState(() => _filter = _Filter.sameCity),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: resultsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, st) => Center(
                  child: TextButton(
                    onPressed: () => ref.invalidate(peopleSearchProvider),
                    child: Text(l10n.retry),
                  ),
                ),
                data: (users) {
                  final others = users.where((u) => u.id != me?.id).toList();
                  if (others.isEmpty) {
                    return EmptyState(
                      icon: Icons.search_off_rounded,
                      tone: EmptyStateTone.neutral,
                      title: l10n.searchEmptyTitle,
                      description: l10n.searchEmptyBody,
                    );
                  }
                  final statusesAsync = ref.watch(
                    relationStatusesProvider(others.map((u) => u.id).join(',')),
                  );
                  final statuses = statusesAsync.valueOrNull ?? {};
                  return ListView.builder(
                    itemCount: others.length,
                    itemBuilder: (context, index) {
                      final u = others[index];
                      final status = statuses[u.id] ?? RelationStatus.none;
                      return ListTile(
                        onTap: () => context.push('/users/${u.id}'),
                        leading: UserAvatar(
                          avatarUrl: u.avatarUrl,
                          name: u.displayName,
                        ),
                        title: Text(
                          u.displayName,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          '${countryFlag(u.homeCountry)} · ${cityName(u.cityId)}',
                        ),
                        trailing: _actionFor(u, status, l10n),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget? _actionFor(
    UserListItem user,
    RelationStatus status,
    AppLocalizations l10n,
  ) {
    switch (status) {
      case RelationStatus.accepted:
        return Text(
          l10n.alreadyFriends,
          style: const TextStyle(color: AppColors.textSecondary),
        );
      case RelationStatus.pendingOutgoing:
        return TextButton(
          onPressed: () => _cancelRequest(user),
          child: Text(l10n.requestSent),
        );
      case RelationStatus.pendingIncoming:
        return OutlinedButton(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, 40),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            foregroundColor: AppColors.coral,
            side: const BorderSide(color: AppColors.coral),
          ),
          onPressed: () => runFriendAction(
            ref,
            context,
            user.id,
            () => ref.read(friendsApiProvider).acceptRequest(user.id),
          ),
          child: Text(l10n.acceptRequest),
        );
      case RelationStatus.blockedByMe:
      case RelationStatus.blockedByThem:
        return null;
      case RelationStatus.none:
      case RelationStatus.declined:
        return OutlinedButton(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, 40),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            foregroundColor: AppColors.coral,
            side: const BorderSide(color: AppColors.coral),
          ),
          onPressed: () => _sendRequest(user),
          child: Text(l10n.addFriend),
        );
    }
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.coralTint : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.coral : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: selected ? AppColors.coral : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
