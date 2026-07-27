import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/users_api.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/session_controller.dart';

final _usernameRe = RegExp(r'^[a-z_]{3,30}$');
final _emailRe = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

enum _UsernameStatus { idle, checking, available, taken, invalid }

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _usernameController = TextEditingController();

  _UsernameStatus _usernameStatus = _UsernameStatus.idle;
  String? _emailError;
  String? _passwordError;
  bool _submitting = false;
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  bool get _formValid =>
      _emailRe.hasMatch(_emailController.text) &&
      _passwordController.text.length >= 8 &&
      _confirmController.text == _passwordController.text &&
      _usernameStatus == _UsernameStatus.available;

  void _onUsernameChanged(String value) {
    _debounce?.cancel();
    final username = value.trim().toLowerCase();
    if (!_usernameRe.hasMatch(username)) {
      setState(() => _usernameStatus = _UsernameStatus.invalid);
      return;
    }
    setState(() => _usernameStatus = _UsernameStatus.checking);
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      final available = await ref
          .read(usersApiProvider)
          .checkUsername(username);
      if (!mounted || _usernameController.text.trim().toLowerCase() != username) {
        return;
      }
      setState(
        () => _usernameStatus = available
            ? _UsernameStatus.available
            : _UsernameStatus.taken,
      );
    });
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _submitting = true;
      _emailError = null;
      _passwordError = null;
    });
    final email = _emailController.text.trim().toLowerCase();
    try {
      await ref
          .read(sessionControllerProvider.notifier)
          .register(
            email: email,
            password: _passwordController.text,
            username: _usernameController.text.trim().toLowerCase(),
          );
      if (!mounted) return;
      context.go('/verify?email=${Uri.encodeComponent(email)}');
    } on ApiException catch (e) {
      setState(() {
        _emailError = e.fieldError('email') == 'EMAIL_TAKEN'
            ? l10n.errorEmailTaken
            : null;
        _passwordError = e.fieldError('password') != null
            ? l10n.errorPasswordTooShort
            : null;
      });
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.registerTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: l10n.emailLabel,
                  errorText: _emailError,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: l10n.passwordLabel,
                  errorText: _passwordError,
                ),
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
              const SizedBox(height: 16),
              TextField(
                controller: _usernameController,
                onChanged: _onUsernameChanged,
                decoration: InputDecoration(
                  labelText: l10n.usernameLabel,
                  prefixText: '@',
                  helperText: l10n.usernameHint,
                  suffixIcon: _usernameSuffixIcon(),
                  errorText: _usernameStatus == _UsernameStatus.invalid
                      ? l10n.errorUsernameInvalid
                      : _usernameStatus == _UsernameStatus.taken
                      ? l10n.usernameTaken
                      : null,
                ),
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                label: l10n.createAccount,
                loading: _submitting,
                onPressed: _formValid ? _submit : null,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.go('/login'),
                child: Text(l10n.alreadyHaveAccount),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget? _usernameSuffixIcon() {
    switch (_usernameStatus) {
      case _UsernameStatus.checking:
        return const Padding(
          padding: EdgeInsets.all(14),
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      case _UsernameStatus.available:
        return const Icon(Icons.check_circle, color: Colors.green);
      case _UsernameStatus.taken:
      case _UsernameStatus.invalid:
        return const Icon(Icons.error, color: Colors.red);
      case _UsernameStatus.idle:
        return null;
    }
  }
}
