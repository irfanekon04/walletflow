import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'auth_service.dart';
import 'supabase_service.dart';
import '../../features/accounts/data/models/account_model.dart';
import '../../features/transactions/data/models/transaction_model.dart';
import '../../features/transactions/data/models/category_model.dart';
import '../../features/budgets/data/models/budget_model.dart';
import '../../features/loans/data/models/loan_model.dart';

class SyncService extends GetxService {
  final AuthService _authService = Get.find<AuthService>();
  final SupabaseService _supabaseService = Get.find<SupabaseService>();
  
  final RxBool isSyncing = false.obs;
  final RxBool isEnabled = false.obs;
  final RxString lastSyncTime = ''.obs;
  final RxInt pendingChanges = 0.obs;
  
  Box get _settingsBox => Hive.box('settings');

  static const String _syncEnabledKey = 'sync_enabled';
  static const String _lastSyncKey = 'last_sync';

  Future<SyncService> init() async {
    isEnabled.value = _settingsBox.get(_syncEnabledKey, defaultValue: false);
    lastSyncTime.value = _settingsBox.get(_lastSyncKey, defaultValue: '');
    return this;
  }

  bool get isSyncEnabled => isEnabled.value;

  Future<void> enableSync() async {
    if (!_authService.isLoggedIn) {
      Get.snackbar(
        'Sign In Required',
        'Please sign in to enable cloud backup',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    
    isEnabled.value = true;
    await _settingsBox.put(_syncEnabledKey, true);
    
    await syncAllData();
  }

  Future<void> disableSync() async {
    isEnabled.value = false;
    await _settingsBox.put(_syncEnabledKey, false);
  }

  Future<void> syncAllData() async {
    if (!isEnabled.value || !_authService.isLoggedIn) return;
    
    isSyncing.value = true;
    try {
      final userId = _authService.userId;
      if (userId == null) return;

      await _syncAccounts(userId);
      await _syncTransactions(userId);
      await _syncCategories(userId);
      await _syncBudgets(userId);
      await _syncLoans(userId);

      final now = DateTime.now().toIso8601String();
      lastSyncTime.value = now;
      await _settingsBox.put(_lastSyncKey, now);
      pendingChanges.value = 0;
      
      Get.snackbar(
        'Sync Complete',
        'All data has been backed up to cloud',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Sync Failed',
        'Unable to sync data. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSyncing.value = false;
    }
  }

  Future<void> _syncAccounts(String userId) async {
    final accountsBox = Hive.box<AccountModel>('accounts');
    final unsyncedAccounts = accountsBox.values.where((a) => !a.isSynced).toList();
    
    for (final account in unsyncedAccounts) {
      try {
        await _supabaseService.createAccount(userId, account.toJson());
        account.isSynced = true;
        await accountsBox.put(account.id, account);
      } catch (e) {
        // Skip if already exists
      }
    }
  }

  Future<void> _syncTransactions(String userId) async {
    final transactionsBox = Hive.box<TransactionModel>('transactions');
    final unsyncedTransactions = transactionsBox.values.where((t) => !t.isSynced).toList();
    
    for (final transaction in unsyncedTransactions) {
      try {
        await _supabaseService.createTransaction(userId, transaction.toJson());
        transaction.isSynced = true;
        await transactionsBox.put(transaction.id, transaction);
      } catch (e) {
        // Skip if already exists
      }
    }
  }

  Future<void> _syncCategories(String userId) async {
    final categoriesBox = Hive.box<CategoryModel>('categories');
    final customCategories = categoriesBox.values.where((c) => !c.isDefault).toList();
    
    for (final category in customCategories) {
      try {
        await _supabaseService.createCategory(userId, category.toJson());
      } catch (e) {
        // Skip if already exists
      }
    }
  }

  Future<void> _syncBudgets(String userId) async {
    final budgetsBox = Hive.box<BudgetModel>('budgets');
    final now = DateTime.now();
    final unsyncedBudgets = budgetsBox.values.where((b) => !b.isSynced).toList();
    
    for (final budget in unsyncedBudgets) {
      try {
        await _supabaseService.createBudget(userId, budget.toJson());
        budget.isSynced = true;
        await budgetsBox.put(budget.id, budget);
      } catch (e) {
        // Skip if already exists
      }
    }
  }

  Future<void> _syncLoans(String userId) async {
    final loansBox = Hive.box<LoanModel>('loans');
    final unsyncedLoans = loansBox.values.where((l) => !l.isSynced).toList();
    
    for (final loan in unsyncedLoans) {
      try {
        await _supabaseService.createLoan(userId, loan.toJson());
        loan.isSynced = true;
        await loansBox.put(loan.id, loan);
      } catch (e) {
        // Skip if already exists
      }
    }
  }

  Future<void> markPendingChange() async {
    if (isEnabled.value) {
      pendingChanges.value++;
    }
  }

  Future<void> restoreFromCloud() async {
    if (!isEnabled.value || !_authService.isLoggedIn) return;
    
    isSyncing.value = true;
    try {
      final userId = _authService.userId;
      if (userId == null) return;

      // Restore accounts
      final cloudAccounts = await _supabaseService.getAccounts(userId);
      final accountsBox = Hive.box<AccountModel>('accounts');
      for (final accountData in cloudAccounts) {
        final account = AccountModel.fromJson(accountData);
        account.isSynced = true;
        await accountsBox.put(account.id, account);
      }

      // Restore transactions
      final cloudTransactions = await _supabaseService.getTransactions(userId);
      final transactionsBox = Hive.box<TransactionModel>('transactions');
      for (final transactionData in cloudTransactions) {
        final transaction = TransactionModel.fromJson(transactionData);
        transaction.isSynced = true;
        await transactionsBox.put(transaction.id, transaction);
      }

      // Restore budgets
      final now = DateTime.now();
      final cloudBudgets = await _supabaseService.getBudgets(userId, now.month, now.year);
      final budgetsBox = Hive.box<BudgetModel>('budgets');
      for (final budgetData in cloudBudgets) {
        final budget = BudgetModel.fromJson(budgetData);
        budget.isSynced = true;
        await budgetsBox.put(budget.id, budget);
      }

      // Restore loans
      final cloudLoans = await _supabaseService.getLoans(userId);
      final loansBox = Hive.box<LoanModel>('loans');
      for (final loanData in cloudLoans) {
        final loan = LoanModel.fromJson(loanData);
        loan.isSynced = true;
        await loansBox.put(loan.id, loan);
      }

      Get.snackbar(
        'Restore Complete',
        'Data has been restored from cloud',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Restore Failed',
        'Unable to restore data from cloud',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSyncing.value = false;
    }
  }
}
