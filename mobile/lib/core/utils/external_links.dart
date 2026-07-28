import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';

/// Открывает внешнюю ссылку в браузере или в приложении карт.
///
/// Адрес в карточке вводит человек, поэтому схемы там может не быть
/// («maps.app.goo.gl/...»). Без неё launchUrl молча ничего не делает —
/// дописываем https:// сами и сообщаем, если открыть всё же не вышло.
Future<void> openExternalUrl(BuildContext context, String? rawUrl) async {
  final l10n = AppLocalizations.of(context)!;
  final input = rawUrl?.trim() ?? '';
  if (input.isEmpty) return;

  final normalized = input.contains('://') ? input : 'https://$input';
  final uri = Uri.tryParse(normalized);

  var opened = false;
  if (uri != null && uri.host.isNotEmpty) {
    try {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      opened = false;
    }
  }
  if (!opened && context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.linkOpenFailed)));
  }
}
