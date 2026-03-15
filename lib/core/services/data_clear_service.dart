import 'package:get/get.dart';
// import 'package:hive/hive.dart';
import '../database/database_service.dart';
import '../widgets/snackbar_helper.dart';
import 'auth_service.dart';
import 'supabase_service.dart';
import 'sync_service.dart';
// import '../../features/accounts/data/models/account_model.dart';
// import '../../features/transactions/data/models/transaction_model.dart';
import '../../features/transactions/data/models/category_model.dart';
// import '../../features/budgets/data/models/budget_model.dart';
// import '../../features/loans/data/models/loan_model.dart';
// import '../../features/loans/data/models/loan_payment_model.dart';

class DataClearService {
  Future<void> clearAllLocalData() async {
    try {
      // Clear all Hive boxes
      await DatabaseService.accounts.clear();
      await DatabaseService.transactions.clear();
      await DatabaseService.categories.clear();
      await DatabaseService.budgets.clear();
      await DatabaseService.loans.clear();
      await DatabaseService.loanPayments.clear();
      await DatabaseService.settings.clear();

      // Re-initialize default categories
      final categoryRepo = _getCategoryRepository();
      await categoryRepo.initDefaultCategories();

      SnackbarHelper.success('All local data has been cleared', title: 'Success');
    } catch (e) {
      SnackbarHelper.error('Failed to clear data: $e', title: 'Error');
    }
  }

  Future<void> clearAllDataIncludingCloud() async {
    try {
      // Clear cloud data first if user is logged in
      final authService = Get.find<AuthService>();
      if (authService.isLoggedIn) {
        // Sign out from Supabase
        try {
          final supabaseService = Get.find<SupabaseService>();
          await supabaseService.signOut();
        } catch (e) {
          // Ignore if Supabase is not initialized
        }

        // Sign out from Firebase
        await authService.logout();

        // Disable sync
        try {
          final syncService = Get.find<SyncService>();
          await syncService.disableSync();
        } catch (e) {
          // Ignore if SyncService is not initialized
        }
      }

      // Clear local data
      await clearAllLocalData();

      SnackbarHelper.success('All data has been cleared', title: 'Success');
    } catch (e) {
      SnackbarHelper.error('Failed to clear data: $e', title: 'Error');
    }
  }

  Future<void> clearAccounts() async {
    await DatabaseService.accounts.clear();
  }

  Future<void> clearTransactions() async {
    await DatabaseService.transactions.clear();
  }

  Future<void> clearBudgets() async {
    await DatabaseService.budgets.clear();
  }

  Future<void> clearLoans() async {
    await DatabaseService.loans.clear();
    await DatabaseService.loanPayments.clear();
  }

  Future<void> clearCategories() async {
    await DatabaseService.categories.clear();
    final categoryRepo = _getCategoryRepository();
    await categoryRepo.initDefaultCategories();
  }

  Future<void> clearSettings() async {
    await DatabaseService.settings.clear();
  }

  _CategoryRepository _getCategoryRepository() {
    return _CategoryRepository();
  }
}

class _CategoryRepository {
  Future<void> initDefaultCategories() async {
    // Check if categories already exist
    if (DatabaseService.categories.isNotEmpty) return;

    // Default expense categories
    final expenseCategories = [
      {'name': 'Food', 'icon': 'restaurant', 'color': '#FF9800'},
      {'name': 'Transport', 'icon': 'directions_car', 'color': '#2196F3'},
      {'name': 'Shopping', 'icon': 'shopping_bag', 'color': '#E91E63'},
      {'name': 'Bills', 'icon': 'receipt_long', 'color': '#9C27B0'},
      {'name': 'Entertainment', 'icon': 'movie', 'color': '#00BCD4'},
      {'name': 'Health', 'icon': 'medical_services', 'color': '#4CAF50'},
      {'name': 'Education', 'icon': 'school', 'color': '#FF5722'},
      {'name': 'Others', 'icon': 'more_horiz', 'color': '#607D8B'},
    ];

    // Default income categories
    final incomeCategories = [
      {'name': 'Salary', 'icon': 'work', 'color': '#4CAF50'},
      {'name': 'Freelance', 'icon': 'computer', 'color': '#2196F3'},
      {'name': 'Business', 'icon': 'business', 'color': '#9C27B0'},
      {'name': 'Investment', 'icon': 'trending_up', 'color': '#00BCD4'},
      {'name': 'Gift', 'icon': 'card_giftcard', 'color': '#E91E63'},
      {'name': 'Others', 'icon': 'more_horiz', 'color': '#607D8B'},
    ];

    final now = DateTime.now();

    for (final cat in expenseCategories) {
      final category = CategoryModel(
        id: _generateId(),
        name: cat['name']!,
        type: CategoryType.expense,
        icon: cat['icon']!,
        color: cat['color']!,
        isDefault: true,
        createdAt: now,
      );
      await DatabaseService.categories.put(category.id, category);
    }

    for (final cat in incomeCategories) {
      final category = CategoryModel(
        id: _generateId(),
        name: cat['name']!,
        type: CategoryType.income,
        icon: cat['icon']!,
        color: cat['color']!,
        isDefault: true,
        createdAt: now,
      );
      await DatabaseService.categories.put(category.id, category);
    }
  }

  String _generateId() {
    return DateTime.now().microsecondsSinceEpoch.toString() +
        (DateTime.now().millisecond % 1000).toString();
  }
}
