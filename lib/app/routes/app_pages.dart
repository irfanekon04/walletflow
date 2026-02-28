import 'package:get/get.dart';
import '../pages/home_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import 'app_routes.dart';

class AppPages {
  static const initial = Routes.splash;

  static final routes = [
    GetPage(name: Routes.splash, page: () => const SplashScreen()),
    GetPage(name: Routes.login, page: () => const LoginPage()),
    GetPage(name: Routes.home, page: () => const HomePage()),
  ];
}
