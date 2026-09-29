import 'package:flutter/material.dart';
import 'package:mobile_messenger/core/validation/auth_validators.dart';
import 'package:mobile_messenger/features/auth/presentation/auth_scope.dart';
import 'package:mobile_messenger/features/auth/presentation/verify_email_screen.dart';
import 'package:mobile_messenger/features/auth/presentation/widgets/auth_form_widgets.dart';

/// Collects email, username, and password for Messenger registration.
class RegisterScreen extends StatefulWidget {
  /// Creates a [RegisterScreen].
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  var _autovalidate = AutovalidateMode.disabled;

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _autovalidate = AutovalidateMode.onUserInteraction);
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final started = await AuthScope.of(context).startRegistration(
      email: _emailController.text,
      username: _usernameController.text,
      password: _passwordController.text,
    );
    _passwordController.clear();
    _confirmController.clear();
    if (!started || !mounted) {
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const VerifyEmailScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthScope.of(context);
    final error = auth.state.errorMessage;

    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                autovalidateMode: _autovalidate,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (error != null) ...[
                      AuthErrorBanner(message: error),
                      const SizedBox(height: 16),
                    ],
                    AuthTextField(
                      controller: _emailController,
                      label: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      textInputAction: TextInputAction.next,
                      validator: (value) =>
                          AuthValidators.emailError(value ?? ''),
                    ),
                    const SizedBox(height: 16),
                    AuthTextField(
                      controller: _usernameController,
                      label: 'Username',
                      autofillHints: const [AutofillHints.username],
                      textInputAction: TextInputAction.next,
                      validator: (value) =>
                          AuthValidators.usernameError(value ?? ''),
                    ),
                    const SizedBox(height: 16),
                    AuthTextField(
                      controller: _passwordController,
                      label: 'Password',
                      obscureText: true,
                      autofillHints: const [AutofillHints.newPassword],
                      textInputAction: TextInputAction.next,
                      onChanged: (_) => setState(() {}),
                      validator: (value) =>
                          AuthValidators.passwordError(value ?? ''),
                    ),
                    const SizedBox(height: 12),
                    PasswordStrengthMeter(password: _passwordController.text),
                    const SizedBox(height: 16),
                    AuthTextField(
                      controller: _confirmController,
                      label: 'Confirm password',
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      validator: (value) =>
                          AuthValidators.passwordConfirmationError(
                            _passwordController.text,
                            value ?? '',
                          ),
                    ),
                    const SizedBox(height: 24),
                    AuthSubmitButton(
                      label: 'Create account',
                      isBusy: auth.state.isBusy,
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
