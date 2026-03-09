import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SnackbarHelper {
  static void show({
    required String message,
    String? title,
    SnackbarType type = SnackbarType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (type) {
      case SnackbarType.success:
        backgroundColor = Colors.green;
        textColor = Colors.white;
        icon = Icons.check_circle;
        break;
      case SnackbarType.error:
        backgroundColor = Colors.red;
        textColor = Colors.white;
        icon = Icons.error;
        break;
      case SnackbarType.warning:
        backgroundColor = Colors.orange;
        textColor = Colors.white;
        icon = Icons.warning;
        break;
      case SnackbarType.info:
        backgroundColor = Colors.blue;
        textColor = Colors.white;
        icon = Icons.info;
        break;
    }

    Get.snackbar(
      title ?? '',
      message,
      backgroundColor: backgroundColor,
      colorText: textColor,
      icon: Icon(icon, color: textColor),
      duration: duration,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  static void success(String message, {String? title}) {
    show(message: message, title: title, type: SnackbarType.success);
  }

  static void error(String message, {String? title}) {
    show(message: message, title: title, type: SnackbarType.error);
  }

  static void warning(String message, {String? title}) {
    show(message: message, title: title, type: SnackbarType.warning);
  }

  static void info(String message, {String? title}) {
    show(message: message, title: title, type: SnackbarType.info);
  }
}

enum SnackbarType { success, error, warning, info }
