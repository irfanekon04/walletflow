import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:walletflow/core/utils/responsive.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final Color? confirmColor;
  final bool isDestructive;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.confirmColor,
    this.isDestructive = false,
  });

  static Future<bool?> show({
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    Color? confirmColor,
    bool isDestructive = false,
  }) {
    return Get.dialog<bool>(
      ConfirmDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        confirmColor: confirmColor,
        isDestructive: isDestructive,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(
        title,
        style: TextStyle(fontSize: 20 * context.responsiveFontSize),
      ),
      content: Text(
        message,
        style: TextStyle(fontSize: 14 * context.responsiveFontSize),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: Text(
            cancelText,
            style: TextStyle(fontSize: 14 * context.responsiveFontSize),
          ),
        ),
        TextButton(
          onPressed: () => Get.back(result: true),
          style: TextButton.styleFrom(
            foregroundColor: confirmColor ?? 
              (isDestructive ? theme.colorScheme.error : theme.colorScheme.primary),
          ),
          child: Text(
            confirmText,
            style: TextStyle(fontSize: 14 * context.responsiveFontSize),
          ),
        ),
      ],
    );
  }
}
