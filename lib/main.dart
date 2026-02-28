import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/theme/app_theme.dart';
import 'app/bindings/app_bindings.dart';
import 'app/pages/home_page.dart';
import 'core/database/database_service.dart';
import 'features/transactions/data/repositories/category_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await DatabaseService.init();
  
  final categoryRepo = CategoryRepository();
  await categoryRepo.initDefaultCategories();
  
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
      initialBinding: AppBindings(),
      home: const HomePage(),
    );
  }
}
