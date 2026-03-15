import 'package:get/get.dart';
import '../../../../features/transactions/data/models/transaction_model.dart';
import '../../../../features/transactions/data/repositories/transaction_repository.dart';

class ReportsController extends GetxController {
  final TransactionRepository _transactionRepo = TransactionRepository();

  // Observable data for the charts
  final RxMap<String, double> categorySpending = <String, double>{}.obs;
  final RxList<MonthlyTrend> monthlyTrends = <MonthlyTrend>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadReportData();
  }

  void loadReportData() {
    isLoading.value = true;
    final allTransactions = _transactionRepo.getAll();
    
    _computeCategorySpending(allTransactions);
    _computeMonthlyTrends(allTransactions);
    
    isLoading.value = false;
  }

  void _computeCategorySpending(List<TransactionModel> transactions) {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    
    final currentMonthExpenses = transactions.where((t) => 
      t.type == TransactionType.expense && 
      t.date.isAfter(firstDayOfMonth.subtract(const Duration(seconds: 1)))
    );

    final Map<String, double> spending = {};
    for (var tx in currentMonthExpenses) {
      final categoryId = tx.categoryId ?? 'Uncategorized';
      spending[categoryId] = (spending[categoryId] ?? 0.0) + tx.amount;
    }
    
    categorySpending.value = spending;
  }

  void _computeMonthlyTrends(List<TransactionModel> transactions) {
    final List<MonthlyTrend> trends = [];
    final now = DateTime.now();

    // Last 6 months
    for (int i = 5; i >= 0; i--) {
      final monthDate = DateTime(now.year, now.month - i, 1);
      final monthName = _getMonthName(monthDate.month);
      
      final monthTransactions = transactions.where((t) => 
        t.date.year == monthDate.year && t.date.month == monthDate.month
      );

      double income = 0;
      double expense = 0;

      for (var tx in monthTransactions) {
        if (tx.type == TransactionType.income) {
          income += tx.amount;
        } else if (tx.type == TransactionType.expense) {
          expense += tx.amount;
        }
      }

      trends.add(MonthlyTrend(
        monthName: monthName,
        income: income,
        expense: expense,
      ));
    }

    monthlyTrends.value = trends;
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}

class MonthlyTrend {
  final String monthName;
  final double income;
  final double expense;

  MonthlyTrend({
    required this.monthName,
    required this.income,
    required this.expense,
  });
}
