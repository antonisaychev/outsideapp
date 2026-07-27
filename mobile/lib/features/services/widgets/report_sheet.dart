import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/services_api.dart';
import '../../../core/widgets/auth_gate_sheet.dart';
import '../../../core/widgets/report_form_sheet.dart';
import '../../../l10n/app_localizations.dart';

/// Жалоба на сервис — обёртка над общей формой 37.
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
  return showReportFormSheet(
    context,
    onSubmit: (reason, comment) => ref
        .read(servicesApiProvider)
        .report(serviceId, reasonType: reason, comment: comment),
  );
}
