import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';
import '../models/transaction_model.dart';

class TransactionRepository {
  final _uuid = const Uuid();

  Box<TransactionModel> get _box => Hive.box<TransactionModel>('transactions');

  List<TransactionModel> getAll() {
    final transactions = _box.values.toList();
    transactions.sort((a, b) => b.date.compareTo(a.date));
    return transactions;
  }

  List<TransactionModel> getByAccount(String accountId) {
    return _box.values
        .where((t) => t.accountId == accountId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  List<TransactionModel> getByDateRange(DateTime start, DateTime end) {
    return _box.values
        .where((t) => t.date.isAfter(start.subtract(const Duration(days: 1))) && 
                     t.date.isBefore(end.add(const Duration(days: 1))))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  List<TransactionModel> getByCategory(String categoryId) {
    return _box.values
        .where((t) => t.categoryId == categoryId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  List<TransactionModel> getByType(TransactionType type) {
    return _box.values
        .where((t) => t.type == type)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  TransactionModel? getById(String id) {
    try {
      return _box.values.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<TransactionModel> create({
    required String accountId,
    required TransactionType type,
    required double amount,
    String? categoryId,
    String? note,
    required DateTime date,
    String? toAccountId,
  }) async {
    final now = DateTime.now();
    final transaction = TransactionModel(
      id: _uuid.v4(),
      accountId: accountId,
      type: type,
      amount: amount,
      categoryId: categoryId,
      note: note,
      date: date,
      toAccountId: toAccountId,
      createdAt: now,
      updatedAt: now,
    );
    await _box.put(transaction.id, transaction);
    return transaction;
  }

  Future<TransactionModel> update(TransactionModel transaction) async {
    transaction.updatedAt = DateTime.now();
    transaction.isSynced = false;
    await _box.put(transaction.id, transaction);
    return transaction;
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  double getTotalIncome({DateTime? start, DateTime? end}) {
    var transactions = _box.values.where((t) => t.type == TransactionType.income);
    
    if (start != null && end != null) {
      transactions = transactions.where((t) => 
        t.date.isAfter(start.subtract(const Duration(days: 1))) && 
        t.date.isBefore(end.add(const Duration(days: 1))));
    }
    
    return transactions.fold(0.0, (sum, t) => sum + t.amount);
  }

  double getTotalExpense({DateTime? start, DateTime? end}) {
    var transactions = _box.values.where((t) => t.type == TransactionType.expense);
    
    if (start != null && end != null) {
      transactions = transactions.where((t) => 
        t.date.isAfter(start.subtract(const Duration(days: 1))) && 
        t.date.isBefore(end.add(const Duration(days: 1))));
    }
    
    return transactions.fold(0.0, (sum, t) => sum + t.amount);
  }

  List<TransactionModel> getRecentTransactions({int limit = 5}) {
    final transactions = getAll();
    return transactions.take(limit).toList();
  }

  Map<String, List<TransactionModel>> getGroupedByDate() {
    final transactions = getAll();
    final Map<String, List<TransactionModel>> grouped = {};
    
    for (final transaction in transactions) {
      final dateKey = _formatDate(transaction.date);
      grouped.putIfAbsent(dateKey, () => []);
      grouped[dateKey]!.add(transaction);
    }
    
    return grouped;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final transactionDate = DateTime(date.year, date.month, date.day);

    if (transactionDate == today) {
      return 'Today';
    } else if (transactionDate == yesterday) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
