import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:walletflow/app/routes/app_routes.dart';
import '../../../../core/database/database_service.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/loading_indicator.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    
    // Check if onboarding is completed
    final bool onboardingCompleted = 
        DatabaseService.settings.get('onboarding_completed', defaultValue: false);

    if (onboardingCompleted) {
      Get.offAllNamed(Routes.home);
    } else {
      Get.offAllNamed(Routes.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet,
              size: 80 * context.responsiveFontSize,
              color: Colors.white,
            ),
            SizedBox(height: context.responsiveHeight(0.03)),
            Text(
              'WalletFlow',
              style: TextStyle(
                fontSize: 32 * context.responsiveFontSize,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: context.responsiveHeight(0.04)),
            const LoadingIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
