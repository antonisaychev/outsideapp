import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_client.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/session_controller.dart';

/// Экран 31 «Новый пароль».
class NewPasswordScreen extends ConsumerStatefulWidget {
  const NewPasswordScreen({super.key, required this.resetToken});

  final String resetToken;

  @override
  ConsumerState<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends ConsumerState<NewPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref
          .read(sessionControllerProvider.notifier)
          .resetPassword(
            resetToken: widget.resetToken,
            newPassword: _passwordController.text,
          );
      // Явный переход (см. login_screen): redirect перехватит онбординг/блок
      if (mounted) context.go('/home');
    } on ApiException catch (e) {
      setState(
        () => _error = e.error == 'RESET_TOKEN_INVALID'
            ? AppLocalizations.of(context)!.errorCodeExpired
            : AppLocalizations.of(context)!.genericError,
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final formValid =
        isValidNewPassword(_passwordController.text) &&
        _confirmController.text == _passwordController.text;
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.newPasswordTitle,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _passwordController,
                obscureText: true,
                obscuringCharacter: '●',
                inputFormatters: [asciiPasswordInputFilter],
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: l10n.newPasswordHint,
                  helperText: l10n.errorPasswordLatin,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _confirmController,
                obscureText: true,
                obscuringCharacter: '●',
                inputFormatters: [asciiPasswordInputFilter],
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: l10n.passwordConfirmHint,
                  errorText:
                      _confirmController.text.isNotEmpty &&
                          _confirmController.text != _passwordController.text
                      ? l10n.errorPasswordMismatch
                      : null,
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                ),
              ],
              const SizedBox(height: 24),
              PrimaryButton(
                label: l10n.saveAndLogin,
                loading: _submitting,
                onPressed: formValid ? _submit : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
