import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_repository.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});
  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _isRegistering = false;
  bool _busy = false;
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      final repository = ref.read(authRepositoryProvider);
      if (_isRegistering) {
        await repository.createAccount(_email.text, _password.text);
      } else {
        await repository.signIn(_email.text, _password.text);
      }
    } on FirebaseAuthException catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message ?? 'Could not authenticate. Please try again.')),
      );
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$error')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Form(
                  key: _formKey,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(color: const Color(0xFF176B58), borderRadius: BorderRadius.circular(22)),
                      child: const Icon(Icons.badge_outlined, color: Colors.white, size: 34),
                    ),
                    const SizedBox(height: 30),
                    Text(_isRegistering ? 'Create your account' : 'Welcome back',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    Text('Your work life, all in one place.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.black54)),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Work email', prefixIcon: Icon(Icons.email_outlined), border: OutlineInputBorder()),
                      validator: (value) => value == null || !value.contains('@') ? 'Enter a valid email address' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _password,
                      obscureText: _obscure,
                      decoration: InputDecoration(labelText: 'Password', prefixIcon: const Icon(Icons.lock_outline), border: const OutlineInputBorder(), suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined), onPressed: () => setState(() => _obscure = !_obscure))),
                      validator: (value) => value == null || value.length < 6 ? 'Use at least 6 characters' : null,
                    ),
                    const SizedBox(height: 22),
                    FilledButton(
                      onPressed: _busy ? null : _submit,
                      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(54), backgroundColor: const Color(0xFF176B58)),
                      child: _busy ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text(_isRegistering ? 'Create account' : 'Sign in'),
                    ),
                    TextButton(
                      onPressed: _busy ? null : () => setState(() => _isRegistering = !_isRegistering),
                      child: Text(_isRegistering ? 'Already registered? Sign in' : 'New here? Create an account'),
                    ),
                  ]),
                ),
              ),
            ),
          ),
        ),
      );
}
