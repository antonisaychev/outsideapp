import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/friends_api.dart';
import '../../../core/utils/localized_names.dart';
import '../../../core/api/users_api.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/auth_gate_sheet.dart';
import '../../../core/widgets/report_form_sheet.dart';
import '../../../core/widgets/photo_strip.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/data/countries.dart';
import '../../auth/providers/session_controller.dart';
import '../../chats/providers/chats_providers.dart';
import '../providers/friends_providers.dart';

/// Экраны 13/35 «Профиль чужой / Профиль друга» — кнопки по статусу отношений.
class UserProfileScreen extends ConsumerStatefulWidget {
  const UserProfileScreen({super.key, required this.userId});

  final String userId;

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  bool get _isGuest =>
      ref.read(sessionControllerProvider).status != SessionStatus.ready;

  Future<void> _copyLink(String username) async {
    final l10n = AppLocalizations.of(context)!;
    await Clipboard.setData(
      ClipboardData(text: 'https://outside.ink/@$username'),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.linkCopied)));
  }

  Future<void> _moreSheet() async {
    final l10n = AppLocalizations.of(context)!;
    if (_isGuest) {
      return showAuthGateSheet(context, l10n.reportSheetTitle.toLowerCase());
    }
    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.flag_outlined),
              title: Text(l10n.reportSheetTitle),
              onTap: () {
                Navigator.of(sheetContext).pop();
                showReportFormSheet(
                  context,
                  onSubmit: (reason, comment) => ref
                      .read(peopleApiProvider)
                      .report(
                        widget.userId,
                        reasonType: reason,
                        comment: comment,
                      ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.block, color: AppColors.error),
              title: Text(
                l10n.blockUser,
                style: const TextStyle(color: AppColors.error),
              ),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _confirmBlock();
              },
            ),
            ListTile(
              title: Center(child: Text(l10n.cancel)),
              onTap: () => Navigator.of(sheetContext).pop(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmBlock() async {
    final l10n = AppLocalizations.of(context)!;
    final profile = ref.read(publicProfileProvider(widget.userId)).valueOrNull;
    final name = profile?.displayName ?? '';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.blockUserTitle(name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              l10n.blockUser,
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
        widget.userId,
        () => ref.read(friendsApiProvider).blockUser(widget.userId),
      );
      if (mounted) context.pop();
    }
  }

  Future<void> _friendsSheet() async {
    final l10n = AppLocalizations.of(context)!;
    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.person_remove_outlined,
                color: AppColors.error,
              ),
              title: Text(
                l10n.removeFriend,
                style: const TextStyle(color: AppColors.error),
              ),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _confirmRemove();
              },
            ),
            ListTile(
              title: Center(child: Text(l10n.cancel)),
              onTap: () => Navigator.of(sheetContext).pop(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmRemove() async {
    final l10n = AppLocalizations.of(context)!;
    final profile = ref.read(publicProfileProvider(widget.userId)).valueOrNull;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.removeFriendTitle(profile?.displayName ?? '')),
        content: Text(l10n.removeFriendWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              l10n.removeFriendConfirm,
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
        widget.userId,
        () => ref.read(friendsApiProvider).removeFriend(widget.userId),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final profileAsync = ref.watch(publicProfileProvider(widget.userId));
    final statusAsync = _isGuest
        ? const AsyncValue.data(RelationStatus.none)
        : ref.watch(relationStatusProvider(widget.userId));
    final cities = ref.watch(citiesProvider).valueOrNull ?? [];

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

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(icon: const Icon(Icons.more_horiz), onPressed: _moreSheet),
        ],
      ),
      body: SafeArea(
        child: profileAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, st) => Center(
            child: TextButton(
              onPressed: () =>
                  ref.invalidate(publicProfileProvider(widget.userId)),
              child: Text(l10n.retry),
            ),
          ),
          data: (profile) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: UserAvatar(
                    avatarUrl: profile.avatarUrl,
                    name: profile.displayName,
                    radius: 52,
                  ),
                ),
                if (profile.photos.length > 1) ...[
                  const SizedBox(height: 16),
                  PhotoStrip(photos: profile.photos),
                ],
                const SizedBox(height: 16),
                Text(
                  profile.displayName,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () => _copyLink(profile.username),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '@${profile.username}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.copy,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${countryFlag(profile.homeCountry)} → ${cityName(profile.cityId)}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _Counter(
                      value: profile.friendsCount,
                      label: l10n.countFriends,
                    ),
                    const SizedBox(width: 40),
                    _Counter(
                      value: profile.servicesCount,
                      label: l10n.countRecommendations,
                    ),
                  ],
                ),
                if (profile.bio != null && profile.bio!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(profile.bio!, textAlign: TextAlign.center),
                ],
                const SizedBox(height: 24),
                statusAsync.when(
                  loading: () => const SizedBox(
                    height: 56,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (err, st) => const SizedBox.shrink(),
                  data: (status) => _buildActions(status, l10n),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActions(RelationStatus status, AppLocalizations l10n) {
    if (_isGuest) {
      return ElevatedButton(
        onPressed: () =>
            showAuthGateSheet(context, l10n.authGateActionAddFriend),
        child: Text(l10n.addFriend),
      );
    }
    switch (status) {
      case RelationStatus.accepted:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () => openChatWith(context, ref, widget.userId),
              child: Text(l10n.writeMessage),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _friendsSheet,
              child: Text(l10n.alreadyFriends),
            ),
          ],
        );
      case RelationStatus.pendingOutgoing:
        return OutlinedButton(
          onPressed: () => runFriendAction(
            ref,
            context,
            widget.userId,
            () => ref.read(friendsApiProvider).cancelRequest(widget.userId),
          ),
          child: Text(l10n.requestSent),
        );
      case RelationStatus.pendingIncoming:
        return Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => runFriendAction(
                  ref,
                  context,
                  widget.userId,
                  () =>
                      ref.read(friendsApiProvider).acceptRequest(widget.userId),
                ),
                child: Text(l10n.acceptRequest),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () => runFriendAction(
                  ref,
                  context,
                  widget.userId,
                  () => ref
                      .read(friendsApiProvider)
                      .declineRequest(widget.userId),
                ),
                child: Text(l10n.declineRequest),
              ),
            ),
          ],
        );
      case RelationStatus.blockedByMe:
        return OutlinedButton(
          onPressed: () => runFriendAction(
            ref,
            context,
            widget.userId,
            () => ref.read(friendsApiProvider).unblockUser(widget.userId),
          ),
          child: Text(l10n.unblockUser),
        );
      case RelationStatus.blockedByThem:
        return const SizedBox.shrink();
      case RelationStatus.none:
      case RelationStatus.declined:
        return ElevatedButton(
          onPressed: () => runFriendAction(
            ref,
            context,
            widget.userId,
            () => ref.read(friendsApiProvider).sendRequest(widget.userId),
          ),
          child: Text(l10n.addFriend),
        );
    }
  }
}

class _Counter extends StatelessWidget {
  const _Counter({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$value',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
