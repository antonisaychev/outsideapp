import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_client.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/session_controller.dart';

/// Экран 02 «Вход».
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _submitting = false;
  String? _formError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _submitting = true;
      _formError = null;
    });
    final email = _emailController.text.trim().toLowerCase();
    debugPrint('[login] submit for $email');
    try {
      await ref
          .read(sessionControllerProvider.notifier)
          .login(email: email, password: _passwordController.text);
      debugPrint('[login] success');
      // роутер сам переведёт дальше по смене статуса сессии (включая BLOCKED)
    } on ApiException catch (e) {
      debugPrint('[login] ApiException: $e');
      String message;
      switch (e.error) {
        case 'EMAIL_NOT_VERIFIED':
          if (mounted) {
            context.push('/verify?email=${Uri.encodeComponent(email)}');
          }
          return;
        case 'TRY_LATER':
          final seconds = (e.extra?['retry_in_sec'] as num?)?.toInt() ?? 60;
          message = l10n.errorTryLater(seconds);
          break;
        default:
          message = l10n.errorInvalidCredentials;
      }
      setState(() => _formError = message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final formValid =
        _emailController.text.trim().isNotEmpty &&
        _passwordController.text.isNotEmpty;
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.loginTitle,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(hintText: l10n.emailLabel),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                obscuringCharacter: '●',
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(hintText: l10n.passwordHint),
              ),
              if (_formError != null) ...[
                const SizedBox(height: 12),
                Text(
                  _formError!,
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                ),
              ],
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  onPressed: () => context.push('/forgot'),
                  child: Text(l10n.forgotPassword),
                ),
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                label: l10n.login,
                loading: _submitting,
                onPressed: formValid ? _submit : null,
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    foregroundColor: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color,
                  ),
                  onPressed: () => context.go('/register'),
                  child: Text(l10n.noAccountCreate),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
