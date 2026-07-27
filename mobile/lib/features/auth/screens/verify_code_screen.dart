import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/auth_api.dart';
import '../../../core/widgets/code_input_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/session_controller.dart';

enum VerifyPurpose { register, reset }

/// Экран 29/30 «Подтвердите почту» / «Код для сброса» — общая логика ячеек.
class VerifyCodeScreen extends ConsumerStatefulWidget {
  const VerifyCodeScreen({
    super.key,
    required this.email,
    required this.purpose,
  });

  final String email;
  final VerifyPurpose purpose;

  @override
  ConsumerState<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends ConsumerState<VerifyCodeScreen> {
  // Зеркалит порог попыток на сервере (backend/src/utils/codes.js: attempts >= 5)
  static const _maxAttempts = 5;

  final _codeFieldKey = GlobalKey<CodeInputFieldState>();
  String _code = '';
  bool _hasError = false;
  String? _errorText;
  bool _submitting = false;
  int _wrongAttempts = 0;
  int _resendSecondsLeft = 60;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _resendSecondsLeft = 60;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSecondsLeft <= 1) {
        timer.cancel();
        setState(() => _resendSecondsLeft = 0);
      } else {
        setState(() => _resendSecondsLeft -= 1);
      }
    });
  }

  String get _timerText {
    final m = _resendSecondsLeft ~/ 60;
    final s = (_resendSecondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _submit(String code) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _submitting = true;
      _hasError = false;
      _errorText = null;
    });
    try {
      if (widget.purpose == VerifyPurpose.register) {
        await ref
            .read(sessionControllerProvider.notifier)
            .verifyCode(email: widget.email, code: code);
        // дальше роутер сам уведёт на онбординг по смене статуса сессии
      } else {
        final resetToken = await ref
            .read(authApiProvider)
            .verifyReset(email: widget.email, code: code);
        if (!mounted) return;
        context.push(
          '/reset-password?resetToken=${Uri.encodeComponent(resetToken)}',
        );
      }
    } on ApiException catch (e) {
      String message;
      switch (e.error) {
        case 'LOCKED':
          message = l10n.errorCodeLocked;
          break;
        case 'EXPIRED':
        case 'NOT_FOUND':
          message = l10n.errorCodeExpired;
          break;
        default:
          _wrongAttempts += 1;
          final left = (_maxAttempts - _wrongAttempts).clamp(0, _maxAttempts);
          message = l10n.errorCodeWrong(left);
      }
      setState(() {
        _hasError = true;
        _errorText = message;
        _code = '';
      });
      _codeFieldKey.currentState?.clear();
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _resend() async {
    if (widget.purpose == VerifyPurpose.register) {
      await ref
          .read(sessionControllerProvider.notifier)
          .resendCode(widget.email);
    } else {
      await ref.read(authApiProvider).forgot(email: widget.email);
    }
    _wrongAttempts = 0;
    _startResendTimer();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.verifyEmailTitle,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.verifyEmailSubtitle(widget.email),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              CodeInputField(
                key: _codeFieldKey,
                hasError: _hasError,
                onChanged: (code) => setState(() => _code = code),
                onCompleted: _submit,
              ),
              if (_errorText != null) ...[
                const SizedBox(height: 12),
                Text(
                  _errorText!,
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                ),
              ],
              const SizedBox(height: 16),
              _resendSecondsLeft > 0
                  ? Text(
                      l10n.resendCodeTimer(_timerText),
                      style: Theme.of(context).textTheme.bodyMedium,
                    )
                  : Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        onPressed: _resend,
                        child: Text(l10n.resendCode),
                      ),
                    ),
              const SizedBox(height: 16),
              PrimaryButton(
                label: l10n.confirm,
                loading: _submitting,
                onPressed: _code.length == 6 ? () => _submit(_code) : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
