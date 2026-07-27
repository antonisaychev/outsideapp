import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../../l10n/app_localizations.dart';

/// Условия использования / Политика конфиденциальности (тексты из assets).
class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key, required this.doc});

  /// 'terms' | 'privacy'
  final String doc;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final title = doc == 'privacy' ? l10n.privacyTitle : l10n.termsTitle;
    final asset = doc == 'privacy'
        ? 'assets/legal/privacy_ru.md'
        : 'assets/legal/terms_ru.md';
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: FutureBuilder<String>(
          future: rootBundle.loadString(asset),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            // Markdown показываем как простой текст, убрав разметку заголовков
            final text = snapshot.data!
                .replaceAll(RegExp(r'^#+\s*', multiLine: true), '')
                .replaceAll(RegExp(r'\*\*'), '');
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Text(
                text,
                style: const TextStyle(fontSize: 15, height: 1.5),
              ),
            );
          },
        ),
      ),
    );
  }
}
