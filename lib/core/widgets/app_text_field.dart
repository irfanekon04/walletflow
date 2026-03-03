import 'package:flutter/material.dart';
import 'package:walletflow/core/utils/responsive.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? errorText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int maxLines;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;

  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.focusNode,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      maxLines: maxLines,
      maxLength: maxLength,
      readOnly: readOnly,
      focusNode: focusNode,
      validator: validator,
      onChanged: onChanged,
      onTap: onTap,
      style: TextStyle(fontSize: 16 * context.responsiveFontSize),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: errorText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 20 * context.responsiveFontSize,
          vertical: 18 * context.responsiveFontSize,
        ),
        labelStyle: TextStyle(fontSize: 14 * context.responsiveFontSize),
        hintStyle: TextStyle(fontSize: 14 * context.responsiveFontSize),
      ),
    );
  }
}

class AppAmountField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final bool enabled;

  const AppAmountField({
    super.key,
    this.controller,
    this.label = 'Amount',
    this.errorText,
    this.onChanged,
    this.validator,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: TextInputAction.done,
      style: TextStyle(fontSize: 16 * context.responsiveFontSize),
      validator: validator ?? (value) {
        if (value == null || value.isEmpty) {
          return 'Amount is required';
        }
        final amount = double.tryParse(value);
        if (amount == null) {
          return 'Please enter a valid number';
        }
        if (amount <= 0) {
          return 'Amount must be greater than 0';
        }
        return null;
      },
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixText: '\$ ',
        errorText: errorText,
        filled: true,
        fillColor: enabled 
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 20 * context.responsiveFontSize,
          vertical: 18 * context.responsiveFontSize,
        ),
        labelStyle: TextStyle(fontSize: 14 * context.responsiveFontSize),
      ),
    );
  }
}
