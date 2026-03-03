import 'package:flutter/material.dart';
import 'package:walletflow/core/utils/responsive.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final Color? color;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isOutlined) {
      return OutlinedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? SizedBox(
                width: 16 * context.responsiveFontSize,
                height: 16 * context.responsiveFontSize,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.primary,
                ),
              )
            : icon != null
                ? Icon(icon)
                : const SizedBox.shrink(),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: theme.colorScheme.primary,
          side: BorderSide(color: theme.colorScheme.outline),
          minimumSize: Size(double.infinity, 48 * context.responsiveFontSize),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 24 * context.responsiveFontSize,
            vertical: 16 * context.responsiveFontSize,
          ),
          textStyle: TextStyle(
            fontSize: 14 * context.responsiveFontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return FilledButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? SizedBox(
              width: 16 * context.responsiveFontSize,
              height: 16 * context.responsiveFontSize,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.colorScheme.onPrimary,
              ),
            )
          : icon != null
              ? Icon(icon)
              : const SizedBox.shrink(),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: color ?? theme.colorScheme.primary,
        foregroundColor: color != null 
            ? theme.colorScheme.onPrimary 
            : theme.colorScheme.onPrimary,
        minimumSize: Size(double.infinity, 48 * context.responsiveFontSize),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 24 * context.responsiveFontSize,
          vertical: 16 * context.responsiveFontSize,
        ),
        textStyle: TextStyle(
          fontSize: 14 * context.responsiveFontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
