import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/session_controller.dart';

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
      // роутер сам переведёт на онбординг/главный экран по смене статуса сессии
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
        _passwordController.text.length >= 8 &&
        _confirmController.text == _passwordController.text;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.newPasswordTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _passwordController,
                obscureText: true,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(labelText: l10n.passwordLabel),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _confirmController,
                obscureText: true,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: l10n.passwordConfirmLabel,
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
