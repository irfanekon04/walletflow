import 'package:get/get.dart';
import '../../data/models/budget_model.dart';
import '../../data/repositories/budget_repository.dart';

class BudgetController extends GetxController {
  final BudgetRepository _repository = BudgetRepository();

  final RxList<BudgetModel> budgets = <BudgetModel>[].obs;
  final RxList<Map<String, dynamic>> budgetsWithProgress =
      <Map<String, dynamic>>[].obs;
  final RxInt selectedMonth = DateTime.now().month.obs;
  final RxInt selectedYear = DateTime.now().year.obs;
  final RxDouble totalBudget = 0.0.obs;
  final RxDouble totalSpent = 0.0.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadBudgets();
  }

  void loadBudgets() {
    isLoading.value = true;
    final list = _repository.getByMonth(
      selectedMonth.value,
      selectedYear.value,
    );
    for (var budget in list) {
      budget.spent = _repository.getSpentAmount(
        budget.categoryId,
        selectedMonth.value,
        selectedYear.value,
      );
    }
    budgets.value = list;
    budgetsWithProgress.value = _repository.getBudgetsWithProgress(
      selectedMonth.value,
      selectedYear.value,
    );
    totalBudget.value = _repository.getTotalBudgetAmount(
      selectedMonth.value,
      selectedYear.value,
    );
    totalSpent.value = _repository.getTotalSpentAmount(
      selectedMonth.value,
      selectedYear.value,
    );
    isLoading.value = false;
  }

  void changeMonth(int month, int year) {
    selectedMonth.value = month;
    selectedYear.value = year;
    loadBudgets();
  }

  void nextMonth() {
    if (selectedMonth.value == 12) {
      selectedMonth.value = 1;
      selectedYear.value += 1;
    } else {
      selectedMonth.value += 1;
    }
    loadBudgets();
  }

  void previousMonth() {
    if (selectedMonth.value == 1) {
      selectedMonth.value = 12;
      selectedYear.value -= 1;
    } else {
      selectedMonth.value -= 1;
    }
    loadBudgets();
  }

  Future<void> addBudget({
    required String categoryId,
    required double amount,
    int? month,
    int? year,
  }) async {
    await _repository.create(
      categoryId: categoryId,
      amount: amount,
      month: month ?? selectedMonth.value,
      year: year ?? selectedYear.value,
    );
    loadBudgets();
  }

  Future<void> updateBudget(BudgetModel budget) async {
    await _repository.update(budget);
    loadBudgets();
  }

  Future<void> deleteBudget(String id) async {
    await _repository.delete(id);
    loadBudgets();
  }

  BudgetModel? getBudgetById(String id) {
    return _repository.getById(id);
  }

  double getSpentForCategory(String categoryId) {
    return _repository.getSpentAmount(
      categoryId,
      selectedMonth.value,
      selectedYear.value,
    );
  }

  String getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }
}
