import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';
import '../../../transactions/data/models/transaction_model.dart';
import '../models/budget_model.dart';

class BudgetRepository {
  final _uuid = const Uuid();

  Box<BudgetModel> get _box => Hive.box<BudgetModel>('budgets');
  Box<TransactionModel> get _transactionBox => Hive.box<TransactionModel>('transactions');

  List<BudgetModel> getAll() {
    return _box.values.toList();
  }

  List<BudgetModel> getByMonth(int month, int year) {
    return _box.values
        .where((b) => b.month == month && b.year == year)
        .toList();
  }

  BudgetModel? getById(String id) {
    try {
      return _box.values.firstWhere((b) => b.id == id);
    } catch (e) {
      return null;
    }
  }

  BudgetModel? getByCategoryAndMonth(String categoryId, int month, int year) {
    try {
      return _box.values.firstWhere(
        (b) => b.categoryId == categoryId && b.month == month && b.year == year,
      );
    } catch (e) {
      return null;
    }
  }

  Future<BudgetModel> create({
    required String categoryId,
    required double amount,
    required int month,
    required int year,
  }) async {
    final now = DateTime.now();
    final budget = BudgetModel(
      id: _uuid.v4(),
      categoryId: categoryId,
      amount: amount,
      month: month,
      year: year,
      createdAt: now,
      updatedAt: now,
    );
    await _box.put(budget.id, budget);
    return budget;
  }

  Future<BudgetModel> update(BudgetModel budget) async {
    budget.updatedAt = DateTime.now();
    budget.isSynced = false;
    await _box.put(budget.id, budget);
    return budget;
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  double getSpentAmount(String categoryId, int month, int year) {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0);
    
    final transactions = _transactionBox.values
        .where((t) => 
            t.type == TransactionType.expense && 
            t.categoryId == categoryId &&
            t.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
            t.date.isBefore(endDate.add(const Duration(days: 1))))
        .toList();
    
    return transactions.fold(0.0, (sum, t) => sum + t.amount);
  }

  List<Map<String, dynamic>> getBudgetsWithProgress(int month, int year) {
    final budgets = getByMonth(month, year);
    return budgets.map((budget) {
      final spent = getSpentAmount(budget.categoryId, month, year);
      final percentage = budget.amount > 0 ? (spent / budget.amount) * 100 : 0.0;
      return {
        'budget': budget,
        'spent': spent,
        'remaining': budget.amount - spent,
        'percentage': percentage,
      };
    }).toList();
  }

  double getTotalBudgetAmount(int month, int year) {
    final budgets = getByMonth(month, year);
    return budgets.fold(0.0, (sum, b) => sum + b.amount);
  }

  double getTotalSpentAmount(int month, int year) {
    final budgets = getByMonth(month, year);
    return budgets.fold(0.0, (sum, b) => sum + getSpentAmount(b.categoryId, month, year));
  }
}
