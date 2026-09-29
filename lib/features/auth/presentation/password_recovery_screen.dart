import 'package:flutter/material.dart';
import 'package:messenger_client/messenger_client.dart';
import 'package:mobile_messenger/core/validation/auth_validators.dart';
import 'package:mobile_messenger/features/auth/presentation/auth_scope.dart';
import 'package:mobile_messenger/features/auth/presentation/widgets/auth_form_widgets.dart';

/// Official Email IDP password recovery, in three local steps.
class PasswordRecoveryScreen extends StatefulWidget {
  /// Creates a [PasswordRecoveryScreen].
  const PasswordRecoveryScreen({super.key});

  @override
  State<PasswordRecoveryScreen> createState() => _PasswordRecoveryScreenState();
}

class _PasswordRecoveryScreenState extends State<PasswordRecoveryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  var _step = 0;
  var _autovalidate = AutovalidateMode.disabled;
  UuidValue? _requestId;
  String? _finishToken;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.clear();
    _confirmController.clear();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _autovalidate = AutovalidateMode.onUserInteraction);
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final auth = AuthScope.of(context);
    switch (_step) {
      case 0:
        final requestId = await auth.startPasswordReset(
          email: _emailController.text,
        );
        if (requestId == null || !mounted) {
          return;
        }
        setState(() {
          _requestId = requestId;
          _step = 1;
          _autovalidate = AutovalidateMode.disabled;
        });
      case 1:
        final requestId = _requestId;
        if (requestId == null) {
          return;
        }
        final token = await auth.verifyPasswordReset(
          passwordResetRequestId: requestId,
          verificationCode: _codeController.text,
        );
        if (token == null || !mounted) {
          return;
        }
        setState(() {
          _finishToken = token;
          _step = 2;
          _autovalidate = AutovalidateMode.disabled;
        });
      case 2:
        final token = _finishToken;
        if (token == null) {
          return;
        }
        final completed = await auth.finishPasswordReset(
          finishPasswordResetToken: token,
          email: _emailController.text,
          newPassword: _passwordController.text,
        );
        _passwordController.clear();
        _confirmController.clear();
        if (completed && mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthScope.of(context);
    final error = auth.state.errorMessage;

    return Scaffold(
      appBar: AppBar(title: const Text('Reset password')),
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
                    Text(
                      switch (_step) {
                        0 => 'Enter the email for your account. If it is '
                            'registered, we will send a verification code.',
                        1 => 'Enter the verification code sent to your email.',
                        _ => 'Choose a new password.',
                      },
                    ),
                    const SizedBox(height: 24),
                    if (error != null) ...[
                      AuthErrorBanner(message: error),
                      const SizedBox(height: 16),
                    ],
                    if (_step == 0)
                      AuthTextField(
                        controller: _emailController,
                        label: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        validator: (value) =>
                            AuthValidators.emailError(value ?? ''),
                      )
                    else if (_step == 1)
                      AuthTextField(
                        controller: _codeController,
                        label: 'Verification code',
                        validator: (value) {
                          if ((value ?? '').trim().isEmpty) {
                            return 'Enter the verification code.';
                          }
                          return null;
                        },
                      )
                    else ...[
                      AuthTextField(
                        controller: _passwordController,
                        label: 'New password',
                        obscureText: true,
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
                        validator: (value) =>
                            AuthValidators.passwordConfirmationError(
                              _passwordController.text,
                              value ?? '',
                            ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    AuthSubmitButton(
                      label: switch (_step) {
                        0 => 'Send code',
                        1 => 'Verify code',
                        _ => 'Reset password',
                      },
                      isBusy: auth.state.isBusy,
                      onPressed: _submit,
                    ),
                    if (_step == 1) ...[
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: auth.state.isBusy
                            ? null
                            : () async {
                                final requestId = await auth.startPasswordReset(
                                  email: _emailController.text,
                                );
                                if (requestId != null && mounted) {
                                  setState(() => _requestId = requestId);
                                }
                              },
                        child: const Text('Resend code'),
                      ),
                    ],
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
