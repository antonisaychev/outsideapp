import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/users_api.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../l10n/app_localizations.dart';

/// Экран 33 «Смена пароля».
class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  String? _currentError;
  bool _submitting = false;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  bool get _valid =>
      _currentController.text.isNotEmpty &&
      isValidNewPassword(_newController.text) &&
      _confirmController.text == _newController.text;

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _submitting = true;
      _currentError = null;
    });
    try {
      await ref
          .read(usersApiProvider)
          .changePassword(
            currentPassword: _currentController.text,
            newPassword: _newController.text,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.saved)));
      context.pop();
    } on ApiException catch (e) {
      setState(() {
        _currentError = e.fieldError('current_password') != null
            ? l10n.wrongPassword
            : null;
      });
      if (_currentError == null && mounted) {
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
    return Scaffold(
      appBar: AppBar(title: Text(l10n.changePassword)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _currentController,
                obscureText: true,
                obscuringCharacter: '●',
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: l10n.currentPasswordHint,
                  errorText: _currentError,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _newController,
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
                          _confirmController.text != _newController.text
                      ? l10n.errorPasswordMismatch
                      : null,
                ),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: l10n.save,
                loading: _submitting,
                onPressed: _valid ? _submit : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
