import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';
import '../models/loan_model.dart';
import '../models/loan_payment_model.dart';
import '../../../accounts/data/models/account_model.dart';

class LoanRepository {
  final _uuid = const Uuid();

  Box<LoanModel> get _loanBox => Hive.box<LoanModel>('loans');
  Box<LoanPaymentModel> get _paymentBox => Hive.box<LoanPaymentModel>('loan_payments');
  Box<AccountModel> get _accountBox => Hive.box<AccountModel>('accounts');

  List<LoanModel> getAll() {
    return _loanBox.values.toList();
  }

  List<LoanModel> getByType(LoanType type) {
    return _loanBox.values
        .where((l) => l.type == type && !l.isCompleted)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  List<LoanModel> getCompleted() {
    return _loanBox.values
        .where((l) => l.isCompleted)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  LoanModel? getById(String id) {
    try {
      return _loanBox.values.firstWhere((l) => l.id == id);
    } catch (e) {
      return null;
    }
  }

  AccountModel? getAccountById(String id) {
    try {
      return _accountBox.values.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<LoanModel> create({
    required LoanType type,
    required String personName,
    required double amount,
    required DateTime date,
    required String accountId,
    String? note,
  }) async {
    final now = DateTime.now();
    final loan = LoanModel(
      id: _uuid.v4(),
      type: type,
      personName: personName,
      originalAmount: amount,
      remainingAmount: amount,
      date: date,
      note: note,
      createdAt: now,
      updatedAt: now,
      accountId: accountId,
    );
    await _loanBox.put(loan.id, loan);
    return loan;
  }

  Future<LoanModel> update(LoanModel loan) async {
    loan.updatedAt = DateTime.now();
    loan.isSynced = false;
    await _loanBox.put(loan.id, loan);
    return loan;
  }

  Future<void> delete(String id) async {
    await _loanBox.delete(id);
    final payments = _paymentBox.values.where((p) => p.loanId == id).toList();
    for (final payment in payments) {
      await _paymentBox.delete(payment.id);
    }
  }

  Future<void> addPayment({
    required String loanId,
    required double amount,
    required String accountId,
    String? note,
  }) async {
    final loan = getById(loanId);
    if (loan != null) {
      final payment = LoanPaymentModel(
        id: _uuid.v4(),
        loanId: loanId,
        amount: amount,
        date: DateTime.now(),
        note: note,
        createdAt: DateTime.now(),
        accountId: accountId,
      );
      await _paymentBox.put(payment.id, payment);

      loan.remainingAmount -= amount;
      if (loan.remainingAmount <= 0) {
        loan.remainingAmount = 0;
        loan.isCompleted = true;
      }
      loan.updatedAt = DateTime.now();
      loan.isSynced = false;
      await _loanBox.put(loan.id, loan);
    }
  }

  List<LoanPaymentModel> getPayments(String loanId) {
    return _paymentBox.values
        .where((p) => p.loanId == loanId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  double getTotalLent() {
    return _loanBox.values
        .where((l) => l.type == LoanType.lent && !l.isCompleted)
        .fold(0.0, (sum, l) => sum + l.remainingAmount);
  }

  double getTotalOwed() {
    return _loanBox.values
        .where((l) => l.type == LoanType.owed && !l.isCompleted)
        .fold(0.0, (sum, l) => sum + l.remainingAmount);
  }

  double getNetPosition() {
    return getTotalLent() - getTotalOwed();
  }

  Future<void> markAsCompleted(String id) async {
    final loan = getById(id);
    if (loan != null) {
      loan.isCompleted = true;
      loan.remainingAmount = 0;
      loan.updatedAt = DateTime.now();
      loan.isSynced = false;
      await _loanBox.put(loan.id, loan);
    }
  }

  Future<void> addMore({
    required String loanId,
    required double additionalAmount,
    required String accountId,
  }) async {
    final loan = getById(loanId);
    if (loan != null) {
      loan.originalAmount += additionalAmount;
      loan.remainingAmount += additionalAmount;
      loan.updatedAt = DateTime.now();
      loan.isSynced = false;
      await _loanBox.put(loan.id, loan);
    }
  }
}
