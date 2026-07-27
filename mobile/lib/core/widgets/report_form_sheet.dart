import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../api/api_client.dart';
import 'primary_button.dart';
import 'selectable_chip.dart';

/// Экран 37 «Форма жалобы» (общая для сервисов и пользователей):
/// причина чипами + комментарий; «Другое» без комментария — недостаточно.
/// [onSubmit] получает (reasonType, comment) и выполняет запрос.
Future<void> showReportFormSheet(
  BuildContext context, {
  required Future<void> Function(String reasonType, String comment) onSubmit,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) => _ReportFormBody(onSubmit: onSubmit),
  );
}

class _ReportFormBody extends StatefulWidget {
  const _ReportFormBody({required this.onSubmit});

  final Future<void> Function(String reasonType, String comment) onSubmit;

  @override
  State<_ReportFormBody> createState() => _ReportFormBodyState();
}

class _ReportFormBodyState extends State<_ReportFormBody> {
  String? _reason;
  final _commentController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  bool get _valid =>
      _reason != null &&
      (_reason != 'other' || _commentController.text.trim().isNotEmpty);

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _submitting = true);
    try {
      await widget.onSubmit(_reason!, _commentController.text.trim());
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.reportSent)));
    } on ApiException {
      // Ошибка сервера не должна проглатываться молча (QA_NOTES №26)
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.genericError)));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final reasons = {
      'spam': l10n.reportReasonSpam,
      'fraud': l10n.reportReasonFraud,
      'abuse': l10n.reportReasonAbuse,
      'other': l10n.reportReasonOther,
    };
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.reportSheetTitle,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final entry in reasons.entries)
                SelectableChip(
                  selected: _reason == entry.key,
                  onTap: () => setState(() => _reason = entry.key),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  child: Text(entry.value),
                ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _commentController,
            maxLines: 3,
            maxLength: 300,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: l10n.reportCommentHint,
              helperText:
                  _reason == 'other' && _commentController.text.trim().isEmpty
                  ? l10n.reportCommentRequired
                  : null,
            ),
          ),
          const SizedBox(height: 8),
          PrimaryButton(
            label: l10n.reportSubmit,
            loading: _submitting,
            onPressed: _valid ? _submit : null,
          ),
        ],
      ),
    );
  }
}
