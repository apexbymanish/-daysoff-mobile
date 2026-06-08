import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/auth_controller.dart';
import '../../theme/colors.dart';

/// Combined login / register screen. Toggles between the two modes.
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  bool _register = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _email.text.trim();
    final password = _password.text;
    if (email.isEmpty || password.length < 8) {
      setState(() => _error = 'Enter an email and a password of 8+ characters.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final ctrl = ref.read(authControllerProvider.notifier);
      if (_register) {
        await ctrl.register(
            email: email,
            password: password,
            displayName: _name.text.trim().isEmpty ? null : _name.text.trim());
      } else {
        await ctrl.login(email: email, password: password);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        setState(() => _error = _register
            ? 'Could not create the account. The email may already be in use.'
            : 'Invalid email or password.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_register ? 'Create account' : 'Sign in')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              _register ? 'Create your daysoff account' : 'Welcome back',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            const Text(
              'Sync your saved breaks across devices.',
              style: TextStyle(color: DaysoffColors.neutral700),
            ),
            const SizedBox(height: 24),
            if (_register) ...[
              TextField(
                key: const Key('auth_name'),
                controller: _name,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Name (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
            ],
            TextField(
              key: const Key('auth_email'),
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('auth_password'),
              controller: _password,
              obscureText: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _busy ? null : _submit(),
              decoration: const InputDecoration(
                labelText: 'Password (8+ characters)',
                border: OutlineInputBorder(),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: DaysoffColors.danger)),
            ],
            const SizedBox(height: 20),
            FilledButton(
              key: const Key('auth_submit'),
              onPressed: _busy ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: DaysoffColors.brandTeal,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _busy
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(_register ? 'Create account' : 'Sign in'),
            ),
            const SizedBox(height: 12),
            TextButton(
              key: const Key('auth_toggle'),
              onPressed: _busy
                  ? null
                  : () => setState(() {
                        _register = !_register;
                        _error = null;
                      }),
              child: Text(_register
                  ? 'Have an account? Sign in'
                  : "New here? Create an account"),
            ),
          ],
        ),
      ),
    );
  }
}
