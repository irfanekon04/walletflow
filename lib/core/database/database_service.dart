import 'package:hive_flutter/hive_flutter.dart';
import '../../features/accounts/data/models/account_model.dart';
import '../../features/transactions/data/models/transaction_model.dart';
import '../../features/transactions/data/models/category_model.dart';
import '../../features/budgets/data/models/budget_model.dart';
import '../../features/loans/data/models/loan_model.dart';
import '../../features/loans/data/models/loan_payment_model.dart';

class DatabaseService {
  static const String accountsBox = 'accounts';
  static const String transactionsBox = 'transactions';
  static const String categoriesBox = 'categories';
  static const String budgetsBox = 'budgets';
  static const String loansBox = 'loans';
  static const String loanPaymentsBox = 'loan_payments';
  static const String settingsBox = 'settings';

  static Future<void> init() async {
    await Hive.initFlutter();
    
    Hive.registerAdapter(AccountTypeAdapter());
    Hive.registerAdapter(AccountModelAdapter());
    Hive.registerAdapter(TransactionTypeAdapter());
    Hive.registerAdapter(TransactionModelAdapter());
    Hive.registerAdapter(CategoryTypeAdapter());
    Hive.registerAdapter(CategoryModelAdapter());
    Hive.registerAdapter(BudgetModelAdapter());
    Hive.registerAdapter(LoanTypeAdapter());
    Hive.registerAdapter(LoanModelAdapter());
    Hive.registerAdapter(LoanPaymentModelAdapter());

    await Hive.openBox<AccountModel>(accountsBox);
    await Hive.openBox<TransactionModel>(transactionsBox);
    await Hive.openBox<CategoryModel>(categoriesBox);
    await Hive.openBox<BudgetModel>(budgetsBox);
    await Hive.openBox<LoanModel>(loansBox);
    await Hive.openBox<LoanPaymentModel>(loanPaymentsBox);
    await Hive.openBox(settingsBox);
  }

  static Box<AccountModel> get accounts => Hive.box<AccountModel>(accountsBox);
  static Box<TransactionModel> get transactions => Hive.box<TransactionModel>(transactionsBox);
  static Box<CategoryModel> get categories => Hive.box<CategoryModel>(categoriesBox);
  static Box<BudgetModel> get budgets => Hive.box<BudgetModel>(budgetsBox);
  static Box<LoanModel> get loans => Hive.box<LoanModel>(loansBox);
  static Box<LoanPaymentModel> get loanPayments => Hive.box<LoanPaymentModel>(loanPaymentsBox);
  static Box get settings => Hive.box(settingsBox);

  static Future<void> close() async {
    await Hive.close();
  }
}
