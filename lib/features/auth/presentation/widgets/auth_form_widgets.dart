import 'package:flutter/material.dart';
import 'package:mobile_messenger/core/validation/auth_validators.dart';

/// Shared text field styling for authentication screens.
class AuthTextField extends StatelessWidget {
  /// Creates an [AuthTextField].
  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    this.keyboardType,
    this.obscureText = false,
    this.autofillHints,
    this.validator,
    this.onChanged,
    this.textInputAction,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Iterable<String>? autofillHints;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      autofillHints: autofillHints,
      validator: validator,
      onChanged: onChanged,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

/// Primary action button used on authentication screens.
class AuthSubmitButton extends StatelessWidget {
  /// Creates an [AuthSubmitButton].
  const AuthSubmitButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isBusy = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: isBusy ? null : onPressed,
      child: isBusy
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(label),
    );
  }
}

/// Live password-strength checklist matching the assignment rules.
class PasswordStrengthMeter extends StatelessWidget {
  /// Creates a [PasswordStrengthMeter].
  const PasswordStrengthMeter({super.key, required this.password});

  final String password;

  @override
  Widget build(BuildContext context) {
    final strength = PasswordStrength.from(password);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RuleRow(met: strength.hasMinLength, label: 'At least 8 characters'),
        _RuleRow(met: strength.hasLowercase, label: 'One lowercase letter'),
        _RuleRow(met: strength.hasUppercase, label: 'One uppercase letter'),
        _RuleRow(met: strength.hasDigit, label: 'One digit'),
        _RuleRow(met: strength.hasSpecial, label: 'One special character'),
      ],
    );
  }
}

class _RuleRow extends StatelessWidget {
  const _RuleRow({required this.met, required this.label});

  final bool met;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = met
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 8),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

/// Banner for mapped authentication errors.
class AuthErrorBanner extends StatelessWidget {
  /// Creates an [AuthErrorBanner].
  const AuthErrorBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.errorContainer,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
