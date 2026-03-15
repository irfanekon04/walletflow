import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'app/theme/app_theme.dart';
import 'core/database/database_service.dart';
import 'app/bindings/initial_binding.dart';
import 'features/settings/presentation/controllers/settings_controller.dart';
import 'features/transactions/data/repositories/category_repository.dart';

import 'app/routes/app_pages.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('Warning: .env file not found, using default values');
  }

  // Initialize Database
  await DatabaseService.init();

  // Initialize Default Categories
  final categoryRepo = CategoryRepository();
  await categoryRepo.initDefaultCategories();

  // Initialize SettingsController before runApp to access theme
  Get.put(SettingsController(), permanent: true);

  runApp(const WalletFlowApp());
}

class WalletFlowApp extends StatelessWidget {
  const WalletFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsController = Get.find<SettingsController>();

    return Obx(() {
      // Access values here to ensure Obx registers them
      final useDynamic = settingsController.useDynamicColor.value;
      final themeMode = settingsController.themeMode.value;

      return DynamicColorBuilder(
        builder: (lightDynamic, darkDynamic) {
          return GetMaterialApp(
            title: 'WalletFlow',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme(useDynamic ? lightDynamic : null),
            darkTheme: AppTheme.darkTheme(useDynamic ? darkDynamic : null),
            themeMode: themeMode,
            initialBinding: InitialBinding(),
            initialRoute: AppPages.initial,
            getPages: AppPages.routes,
            defaultTransition: Transition.cupertino,
            transitionDuration: const Duration(milliseconds: 400),
          );
        },
      );
    });
  }
}
