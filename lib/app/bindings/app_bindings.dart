import 'package:get/get.dart';
import '../../features/accounts/presentation/controllers/account_controller.dart';
import '../../features/transactions/presentation/controllers/transaction_controller.dart';
import '../../features/budgets/presentation/controllers/budget_controller.dart';
import '../../features/loans/presentation/controllers/loan_controller.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(AccountController(), permanent: true);
    Get.put(TransactionController(), permanent: true);
    Get.put(BudgetController(), permanent: true);
    Get.put(LoanController(), permanent: true);
  }
}
