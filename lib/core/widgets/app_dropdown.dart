import 'package:flutter/material.dart';
import 'package:walletflow/core/utils/responsive.dart';

class AppDropdown<T> extends StatelessWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? label;
  final String? hint;
  final String? errorText;
  final String? Function(T?)? validator;
  final Widget? prefixIcon;
  final bool isExpanded;

  const AppDropdown({
    super.key,
    this.value,
    required this.items,
    this.onChanged,
    this.label,
    this.hint,
    this.errorText,
    this.validator,
    this.prefixIcon,
    this.isExpanded = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DropdownButtonFormField<T>(
      initialValue: value,
      items: items,
      onChanged: onChanged,
      validator: validator,
      isExpanded: isExpanded,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: errorText,
        prefixIcon: prefixIcon,
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 20 * context.responsiveFontSize,
          vertical: 18 * context.responsiveFontSize,
        ),
        labelStyle: TextStyle(fontSize: 14 * context.responsiveFontSize),
      ),
    );
  }
}
