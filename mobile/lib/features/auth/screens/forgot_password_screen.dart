import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/auth_api.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../l10n/app_localizations.dart';

final _emailRe = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    final email = _emailController.text.trim().toLowerCase();
    try {
      // Всегда «успех», даже если email не найден — не раскрываем существование аккаунта
      await ref.read(authApiProvider).forgot(email: email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.codeSentNotice)),
      );
      context.go('/verify-reset?email=${Uri.encodeComponent(email)}');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final formValid = _emailRe.hasMatch(_emailController.text.trim());
    return Scaffold(
      appBar: AppBar(title: Text(l10n.forgotPasswordTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(labelText: l10n.emailLabel),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: l10n.sendCode,
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
