import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app/theme/app_theme.dart';
import 'app/pages/home_page.dart';
import 'core/database/database_service.dart';
import 'core/services/auth_service.dart';
import 'core/services/supabase_service.dart';
import 'core/services/sync_service.dart';
import 'firebase_options.dart';
import 'features/transactions/data/repositories/category_repository.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';
import 'features/accounts/presentation/controllers/account_controller.dart';
import 'features/transactions/presentation/controllers/transaction_controller.dart';
import 'features/budgets/presentation/controllers/budget_controller.dart';
import 'features/loans/presentation/controllers/loan_controller.dart';
import 'features/splash/presentation/pages/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('Warning: .env file not found, using default values');
  }

  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }

  // Initialize Database
  await DatabaseService.init();

  // Initialize Default Categories
  final categoryRepo = CategoryRepository();
  await categoryRepo.initDefaultCategories();

  // Initialize Services
  await Get.putAsync(() => AuthService().init());
  await Get.putAsync(() => SupabaseService().init());
  await Get.putAsync(() => SyncService().init());

  // Initialize Controllers
  Get.put(AccountController(), permanent: true);
  Get.put(TransactionController(), permanent: true);
  Get.put(BudgetController(), permanent: true);
  Get.put(LoanController(), permanent: true);
  Get.put(AuthController(), permanent: true);

  runApp(const WalletFlowApp());
}

class WalletFlowApp extends StatelessWidget {
  const WalletFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'WalletFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: const SplashScreen(),
      getPages: [
        GetPage(name: '/login', page: () => const LoginPage()),
        GetPage(name: '/home', page: () => const HomePage()),
      ],
    );
  }
}
