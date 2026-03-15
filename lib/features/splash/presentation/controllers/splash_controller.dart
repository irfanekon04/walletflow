import 'package:get/get.dart';
import '../../../../core/database/database_service.dart';
import '../../../../app/routes/app_routes.dart';

class SplashController extends GetxController {
  final RxDouble opacity = 0.0.obs;
  final RxDouble scale = 0.8.obs;

  @override
  void onInit() {
    super.onInit();
    _startAnimation();
    _checkAuth();
  }

  void _startAnimation() {
    Future.delayed(const Duration(milliseconds: 100), () {
      opacity.value = 1.0;
      scale.value = 1.0;
    });
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(milliseconds: 2000));
    
    // Check if onboarding is completed
    final bool onboardingCompleted = 
        DatabaseService.settings.get('onboarding_completed', defaultValue: false);

    if (onboardingCompleted) {
      Get.offAllNamed(Routes.home);
    } else {
      Get.offAllNamed(Routes.onboarding);
    }
  }
}
