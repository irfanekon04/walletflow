import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/routes/app_pages.dart';
import '../../core/utils/responsive.dart';

class ErrorPage extends StatelessWidget {
  final FlutterErrorDetails details;

  const ErrorPage({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(24.r),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 48.r,
                  color: theme.colorScheme.error,
                ),
              ),
              24.h.verticalSpacer,
              Text(
                'Oops! Something went wrong',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              12.h.verticalSpacer,
              Text(
                'The app encountered an unexpected error. Please restart to continue.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              32.h.verticalSpacer,
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => Get.offAllNamed(AppPages.initial),
                  style: FilledButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.r),
                  ),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Restart App'),
                ),
              ),
              16.h.verticalSpacer,
              TextButton(
                onPressed: () {
                  if (details.exceptionAsString().isNotEmpty) {
                    Get.snackbar(
                      'Error Details',
                      details.exceptionAsString(),
                      duration: const Duration(seconds: 8),
                      snackPosition: SnackPosition.BOTTOM,
                      margin: EdgeInsets.all(16.r),
                    );
                  }
                },
                child: const Text('Show Error Details'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
