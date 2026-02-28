import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'app/theme/app_theme.dart';
import 'core/database/database_service.dart';
import 'core/services/auth_service.dart';
import 'core/services/supabase_service.dart';
import 'core/services/sync_service.dart';
import 'features/transactions/data/repositories/category_repository.dart';
import 'features/accounts/presentation/controllers/account_controller.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';
import 'features/transactions/presentation/controllers/transaction_controller.dart';
import 'features/budgets/presentation/controllers/budget_controller.dart';
import 'features/loans/presentation/controllers/loan_controller.dart';
import 'features/settings/presentation/controllers/settings_controller.dart';

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

  // Initialize Services (order matters: Supabase -> Auth -> Sync)
  // await Get.putAsync(() => SupabaseService().init());
  // await Get.putAsync(() => AuthService().init());
  // await Get.putAsync(() => SyncService().init());

  // Put dummy services for dependency injection if needed
  Get.put(SupabaseService());
  Get.put(AuthService());
  Get.put(SyncService());

  // Initialize Controllers
  Get.put(AccountController(), permanent: true);
  Get.put(TransactionController(), permanent: true);
  Get.put(BudgetController(), permanent: true);
  Get.put(LoanController(), permanent: true);
  Get.put(AuthController(), permanent: true);
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
            initialRoute: AppPages.initial,
            getPages: AppPages.routes,
          );
        },
      );
    });
  }
}
