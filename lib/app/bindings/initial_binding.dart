import 'package:get/get.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/supabase_service.dart';
import '../../core/services/sync_service.dart';
import '../../features/accounts/presentation/controllers/account_controller.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/budgets/presentation/controllers/budget_controller.dart';
import '../../features/loans/presentation/controllers/loan_controller.dart';
import '../../features/transactions/presentation/controllers/category_controller.dart';
import '../../features/transactions/presentation/controllers/transaction_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Services
    Get.put(SupabaseService());
    Get.put(AuthService());
    Get.put(SyncService());

    // Controllers
    Get.lazyPut(() => AccountController(), fenix: true);
    Get.lazyPut(() => CategoryController(), fenix: true);
    Get.lazyPut(() => TransactionController(), fenix: true);
    Get.lazyPut(() => BudgetController(), fenix: true);
    Get.lazyPut(() => LoanController(), fenix: true);
    Get.lazyPut(() => AuthController(), fenix: true);
  }
}
