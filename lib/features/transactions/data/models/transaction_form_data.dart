import 'package:walletflow/features/transactions/data/models/transaction_model.dart';

class TransactionFormData {
  final TransactionType type;
  final String accountId;
  final String? toAccountId;
  final double amount;
  final String? categoryId;
  final String? note;
  final DateTime date;

  TransactionFormData({
    required this.type,
    required this.accountId,
    this.toAccountId,
    required this.amount,
    this.categoryId,
    this.note,
    required this.date,
  });
}
