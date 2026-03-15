import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/splash_controller.dart';

class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final onPrimary = theme.colorScheme.onPrimary;

    return Scaffold(
      backgroundColor: primaryColor,
      body: Center(
        child: Obx(() => AnimatedOpacity(
          duration: const Duration(milliseconds: 800),
          opacity: controller.opacity.value,
          curve: Curves.easeOut,
          child: AnimatedScale(
            duration: const Duration(milliseconds: 800),
            scale: controller.scale.value,
            curve: Curves.easeOutBack,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(24.r),
                  decoration: BoxDecoration(
                    color: onPrimary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.account_balance_wallet,
                    size: 80.sp,
                    color: onPrimary,
                  ),
                ),
                32.h.verticalSpacer,
                Text(
                  'WalletFlow',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontSize: 36.sp,
                    fontWeight: FontWeight.w800,
                    color: onPrimary,
                    letterSpacing: 1.2,
                  ),
                ),
                12.h.verticalSpacer,
                Text(
                  'Master your money',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: onPrimary.withValues(alpha: 0.8),
                    letterSpacing: 0.5,
                  ),
                ),
                48.h.verticalSpacer,
                LoadingIndicator(color: onPrimary),
              ],
            ),
          ),
        )),
      ),
    );
  }
}
