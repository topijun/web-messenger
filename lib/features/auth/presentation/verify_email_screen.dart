import 'package:flutter/material.dart';
import 'package:mobile_messenger/features/auth/presentation/auth_scope.dart';
import 'package:mobile_messenger/features/auth/presentation/widgets/auth_form_widgets.dart';

/// Email verification step for the Messenger registration contract.
class VerifyEmailScreen extends StatefulWidget {
  /// Creates a [VerifyEmailScreen].
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  var _autovalidate = AutovalidateMode.disabled;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _leave() {
    AuthScope.of(context).cancelRegistration();
    Navigator.of(context).pop();
  }

  Future<void> _submit() async {
    setState(() => _autovalidate = AutovalidateMode.onUserInteraction);
    if (!_formKey.currentState!.validate()) {
      return;
    }
    await AuthScope.of(context).verifyRegistration(
      verificationCode: _codeController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthScope.of(context);
    final email = auth.state.pendingEmail ?? 'your email';
    final error = auth.state.errorMessage;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _leave();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Verify email'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _leave,
          ),
        ),
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
                        'Enter the verification code sent to $email.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 24),
                      if (error != null) ...[
                        AuthErrorBanner(message: error),
                        const SizedBox(height: 16),
                      ],
                      AuthTextField(
                        controller: _codeController,
                        label: 'Verification code',
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.done,
                        validator: (value) {
                          if ((value ?? '').trim().isEmpty) {
                            return 'Enter the verification code.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      AuthSubmitButton(
                        label: 'Verify and create account',
                        isBusy: auth.state.isBusy,
                        onPressed: _submit,
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: auth.state.isBusy
                            ? null
                            : () => AuthScope.of(context).resendRegistrationCode(),
                        child: const Text('Resend code'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
