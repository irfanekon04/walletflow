import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/category_model.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../data/repositories/category_repository.dart';
import '../../../accounts/presentation/controllers/account_controller.dart';

class TransactionController extends GetxController {
  final TransactionRepository _transactionRepo = TransactionRepository();
  final CategoryRepository _categoryRepo = CategoryRepository();
  
  final RxList<TransactionModel> transactions = <TransactionModel>[].obs;
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxList<CategoryModel> expenseCategories = <CategoryModel>[].obs;
  final RxList<CategoryModel> incomeCategories = <CategoryModel>[].obs;
  final RxDouble totalIncome = 0.0.obs;
  final RxDouble totalExpense = 0.0.obs;
  final RxBool isLoading = false.obs;
  
  final Rx<TransactionType?> filterType = Rx<TransactionType?>(null);
  final RxString filterAccountId = ''.obs;
  final RxString filterCategoryId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
    loadTransactions();
  }

  void loadCategories() {
    categories.value = _categoryRepo.getAll();
    expenseCategories.value = _categoryRepo.getByType(CategoryType.expense);
    incomeCategories.value = _categoryRepo.getByType(CategoryType.income);
  }

  void loadTransactions() {
    isLoading.value = true;
    transactions.value = _transactionRepo.getAll();
    
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    
    totalIncome.value = _transactionRepo.getTotalIncome(
      start: startOfMonth,
      end: endOfMonth,
    );
    totalExpense.value = _transactionRepo.getTotalExpense(
      start: startOfMonth,
      end: endOfMonth,
    );
    isLoading.value = false;
  }

  Future<void> addTransaction({
    required String accountId,
    required TransactionType type,
    required double amount,
    String? categoryId,
    String? note,
    required DateTime date,
    String? toAccountId,
  }) async {
    await _transactionRepo.create(
      accountId: accountId,
      type: type,
      amount: amount,
      categoryId: categoryId,
      note: note,
      date: date,
      toAccountId: toAccountId,
    );
    
    final accountController = Get.find<AccountController>();
    
    if (type == TransactionType.expense) {
      await accountController.updateBalance(accountId, amount, isAdd: false);
    } else if (type == TransactionType.income) {
      await accountController.updateBalance(accountId, amount, isAdd: true);
    } else if (type == TransactionType.transfer && toAccountId != null) {
      await accountController.updateBalance(accountId, amount, isAdd: false);
      await accountController.updateBalance(toAccountId, amount, isAdd: true);
    }
    
    loadTransactions();
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    await _transactionRepo.update(transaction);
    loadTransactions();
  }

  Future<void> deleteTransaction(String id) async {
    await _transactionRepo.delete(id);
    loadTransactions();
  }

  Future<void> addTransfer({
    required String fromAccountId,
    required String toAccountId,
    required double amount,
    String? note,
    required DateTime date,
  }) async {
    if (fromAccountId == toAccountId) {
      throw Exception('Cannot transfer to the same account');
    }

    await _transactionRepo.create(
      accountId: fromAccountId,
      type: TransactionType.transfer,
      amount: amount,
      note: note,
      date: date,
      toAccountId: toAccountId,
    );
    
    final accountController = Get.find<AccountController>();
    await accountController.updateBalance(fromAccountId, amount, isAdd: false);
    await accountController.updateBalance(toAccountId, amount, isAdd: true);
    
    loadTransactions();
  }

  Future<void> updateTransfer({
    required TransactionModel transaction,
    required String newFromAccountId,
    required String newToAccountId,
    required double newAmount,
    String? newNote,
    required DateTime newDate,
  }) async {
    if (newFromAccountId == newToAccountId) {
      throw Exception('Cannot transfer to the same account');
    }

    final oldFromAccountId = transaction.accountId;
    final oldToAccountId = transaction.toAccountId;
    final oldAmount = transaction.amount;

    final accountController = Get.find<AccountController>();
    
    if (oldToAccountId != null) {
      await accountController.updateBalance(oldFromAccountId, oldAmount, isAdd: true);
      await accountController.updateBalance(oldToAccountId, oldAmount, isAdd: false);
    }

    await accountController.updateBalance(newFromAccountId, newAmount, isAdd: false);
    await accountController.updateBalance(newToAccountId, newAmount, isAdd: true);

    transaction.accountId = newFromAccountId;
    transaction.toAccountId = newToAccountId;
    transaction.amount = newAmount;
    transaction.note = newNote;
    transaction.date = newDate;
    
    await _transactionRepo.update(transaction);
    loadTransactions();
  }

  Future<void> updateTransactionWithTypeChange({
    required TransactionModel transaction,
    required TransactionType newType,
    required String newAccountId,
    required String? newToAccountId,
    required double newAmount,
    String? newCategoryId,
    String? newNote,
    required DateTime newDate,
  }) async {
    final accountController = Get.find<AccountController>();
    
    final oldType = transaction.type;
    final oldAccountId = transaction.accountId;
    final oldToAccountId = transaction.toAccountId;
    final oldAmount = transaction.amount;
    
    // Reverse old transaction effects
    if (oldType == TransactionType.expense) {
      await accountController.updateBalance(oldAccountId, oldAmount, isAdd: true);
    } else if (oldType == TransactionType.income) {
      await accountController.updateBalance(oldAccountId, oldAmount, isAdd: false);
    } else if (oldType == TransactionType.transfer && oldToAccountId != null) {
      await accountController.updateBalance(oldAccountId, oldAmount, isAdd: true);
      await accountController.updateBalance(oldToAccountId, oldAmount, isAdd: false);
    }
    
    // Apply new transaction effects
    if (newType == TransactionType.expense) {
      await accountController.updateBalance(newAccountId, newAmount, isAdd: false);
    } else if (newType == TransactionType.income) {
      await accountController.updateBalance(newAccountId, newAmount, isAdd: true);
    } else if (newType == TransactionType.transfer && newToAccountId != null) {
      await accountController.updateBalance(newAccountId, newAmount, isAdd: false);
      await accountController.updateBalance(newToAccountId, newAmount, isAdd: true);
    }
    
    // Update transaction
    transaction.type = newType;
    transaction.accountId = newAccountId;
    transaction.toAccountId = newToAccountId;
    transaction.amount = newAmount;
    transaction.categoryId = newCategoryId;
    transaction.note = newNote;
    transaction.date = newDate;
    
    await _transactionRepo.update(transaction);
    loadTransactions();
  }

  TransactionModel? getTransactionById(String id) {
    return _transactionRepo.getById(id);
  }

  CategoryModel? getCategoryById(String id) {
    return _categoryRepo.getById(id);
  }

  List<TransactionModel> getRecentTransactions({int limit = 5}) {
    return _transactionRepo.getRecentTransactions(limit: limit);
  }

  Map<String, List<TransactionModel>> getGroupedTransactions() {
    return _transactionRepo.getGroupedByDate();
  }

  List<TransactionModel> getFilteredTransactions() {
    var filtered = transactions.toList();
    
    if (filterType.value != null) {
      filtered = filtered.where((t) => t.type == filterType.value).toList();
    }
    
    if (filterAccountId.isNotEmpty) {
      filtered = filtered.where((t) => t.accountId == filterAccountId.value).toList();
    }
    
    if (filterCategoryId.isNotEmpty) {
      filtered = filtered.where((t) => t.categoryId == filterCategoryId.value).toList();
    }
    
    return filtered;
  }

  void clearFilters() {
    filterType.value = null;
    filterAccountId.value = '';
    filterCategoryId.value = '';
  }


  Future<void> deleteTransactionAndAdjustBalance(TransactionModel tx) async {
    await deleteTransaction(tx.id);

    final accountController = Get.find<AccountController>();

    if (tx.type == TransactionType.expense) {
      await accountController.updateBalance(
        tx.accountId,
        tx.amount,
        isAdd: true,
      );
    } else if (tx.type == TransactionType.income) {
      await accountController.updateBalance(
        tx.accountId,
        tx.amount,
        isAdd: false,
      );
    } else if (tx.type == TransactionType.transfer && tx.toAccountId != null) {
      await accountController.updateBalance(
        tx.accountId,
        tx.amount,
        isAdd: true,
      );
      await accountController.updateBalance(
        tx.toAccountId!,
        tx.amount,
        isAdd: false,
      );
    }

    accountController.loadAccounts();
  }


  IconData getCategoryIcon(String icon) {
    switch (icon) {
      case 'restaurant':
        return Icons.restaurant_outlined;
      case 'directions_car':
        return Icons.directions_car_outlined;
      case 'shopping_bag':
        return Icons.shopping_bag_outlined;
      case 'receipt_long':
        return Icons.receipt_long_outlined;
      case 'movie':
        return Icons.movie_outlined;
      case 'medical_services':
        return Icons.medical_services_outlined;
      case 'school':
        return Icons.school_outlined;
      case 'work':
        return Icons.work_outline;
      default:
        return Icons.category_outlined;
    }
  }
}
