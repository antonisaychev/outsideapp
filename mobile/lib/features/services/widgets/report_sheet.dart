import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/services_api.dart';
import '../../../core/widgets/auth_gate_sheet.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/selectable_chip.dart';
import '../../../l10n/app_localizations.dart';

/// Экран 37 «Форма жалобы» для сервиса: причина чипами + комментарий.
/// «Другое» без комментария — недостаточно.
Future<void> showServiceReportSheet(
  BuildContext context,
  WidgetRef ref, {
  required String serviceId,
  required bool isGuest,
}) {
  final l10n = AppLocalizations.of(context)!;
  if (isGuest) {
    return showAuthGateSheet(context, l10n.reportSheetTitle.toLowerCase());
  }
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) => _ReportSheetBody(serviceId: serviceId, ref: ref),
  );
}

class _ReportSheetBody extends StatefulWidget {
  const _ReportSheetBody({required this.serviceId, required this.ref});

  final String serviceId;
  final WidgetRef ref;

  @override
  State<_ReportSheetBody> createState() => _ReportSheetBodyState();
}

class _ReportSheetBodyState extends State<_ReportSheetBody> {
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
      await widget.ref
          .read(servicesApiProvider)
          .report(
            widget.serviceId,
            reasonType: _reason!,
            comment: _commentController.text.trim(),
          );
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.reportSent)));
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
