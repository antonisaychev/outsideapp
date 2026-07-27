import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';

/// Экран 23 «Auth-gate»: шторка для гостя при попытке действия с записью.
/// [action] — глагольная фраза («добавить в избранное», «добавить сервис»).
Future<void> showAuthGateSheet(BuildContext context, String action) {
  final l10n = AppLocalizations.of(context)!;
  return showModalBottomSheet<void>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.authGateTitle(action),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.authGateSubtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Роутер берём ДО pop — после закрытия шторки её context мёртв
                final router = GoRouter.of(context);
                Navigator.of(context).pop();
                router.push('/register');
              },
              child: Text(l10n.createAccount),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                final router = GoRouter.of(context);
                Navigator.of(context).pop();
                router.push('/login');
              },
              child: Text(l10n.login),
            ),
          ],
        ),
      ),
    ),
  );
}
