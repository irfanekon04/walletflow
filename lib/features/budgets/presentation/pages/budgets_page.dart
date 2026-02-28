import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/responsive.dart';
import '../../../transactions/presentation/controllers/transaction_controller.dart';
import '../../data/models/budget_model.dart';
import '../controllers/budget_controller.dart';

class BudgetsPage extends StatelessWidget {
  const BudgetsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BudgetController>();
    final transactionController = Get.find<TransactionController>();
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.budgets),
      ),
      body: Column(
        children: [
          _buildMonthSelector(context, controller),
          _buildBudgetSummary(context, controller, currencyFormat),
          Expanded(
            child: Obx(() {
              if (controller.budgets.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.pie_chart, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: AppDimensions.paddingM),
                      Text(
                        AppStrings.noBudgets,
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: EdgeInsets.all(context.responsivePadding),
                itemCount: controller.budgetsWithProgress.length,
                itemBuilder: (context, index) {
                  final item = controller.budgetsWithProgress[index];
                  final budget = item['budget'] as BudgetModel;
                  final spent = item['spent'] as double;
                  final percentage = item['percentage'] as double;
                  final category = transactionController.getCategoryById(budget.categoryId);
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
                    child: Padding(
                      padding: EdgeInsets.all(AppDimensions.paddingM),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                category?.name ?? 'Unknown',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16 * context.responsiveFontSize,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => controller.deleteBudget(budget.id),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppDimensions.paddingS),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${currencyFormat.format(spent)} / ${currencyFormat.format(budget.amount)}'),
                              Text('${percentage.toStringAsFixed(1)}%'),
                            ],
                          ),
                          const SizedBox(height: AppDimensions.paddingS),
                          LinearProgressIndicator(
                            value: percentage / 100,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              percentage > 100
                                  ? AppColors.expenseRed
                                  : percentage > 80
                                      ? AppColors.warningOrange
                                      : AppColors.incomeGreen,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.paddingXS),
                          Text(
                            percentage > 100
                                ? 'Over by ${currencyFormat.format(spent - budget.amount)}'
                                : 'Remaining: ${currencyFormat.format(budget.amount - spent)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: percentage > 100 ? AppColors.expenseRed : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBudgetBottomSheet(context, controller, transactionController),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMonthSelector(BuildContext context, BudgetController controller) {
    return Obx(() => Container(
      padding: EdgeInsets.all(AppDimensions.paddingM),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: controller.previousMonth,
          ),
          Text(
            '${controller.getMonthName(controller.selectedMonth.value)} ${controller.selectedYear.value}',
            style: TextStyle(
              fontSize: 18 * context.responsiveFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: controller.nextMonth,
          ),
        ],
      ),
    ));
  }

  Widget _buildBudgetSummary(BuildContext context, BudgetController controller, NumberFormat format) {
    return Obx(() => Container(
      margin: EdgeInsets.symmetric(horizontal: context.responsivePadding),
      padding: EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total Budget', style: TextStyle(color: Colors.grey[600])),
              Text(
                format.format(controller.totalBudget.value),
                style: TextStyle(fontSize: 20 * context.responsiveFontSize, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Spent', style: TextStyle(color: Colors.grey[600])),
              Text(
                format.format(controller.totalSpent.value),
                style: TextStyle(
                  fontSize: 20 * context.responsiveFontSize,
                  fontWeight: FontWeight.bold,
                  color: controller.totalSpent.value > controller.totalBudget.value
                      ? AppColors.expenseRed
                      : AppColors.incomeGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    ));
  }

  void _showAddBudgetBottomSheet(BuildContext context, BudgetController controller, TransactionController transactionController) {
    final amountController = TextEditingController();
    final RxString selectedCategoryId = ''.obs;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          left: AppDimensions.paddingM,
          right: AppDimensions.paddingM,
          top: AppDimensions.paddingM,
          bottom: MediaQuery.of(context).viewInsets.bottom + AppDimensions.paddingM,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.addBudget, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: AppDimensions.paddingM),
            Obx(() => DropdownButtonFormField<String>(
              value: selectedCategoryId.value.isEmpty ? null : selectedCategoryId.value,
              decoration: const InputDecoration(labelText: 'Category'),
              items: transactionController.expenseCategories.map((cat) => DropdownMenuItem(
                value: cat.id,
                child: Text(cat.name),
              )).toList(),
              onChanged: (value) => selectedCategoryId.value = value ?? '',
            )),
            const SizedBox(height: AppDimensions.paddingM),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Budget Amount',
                prefixText: '\$ ',
              ),
            ),
            const SizedBox(height: AppDimensions.paddingL),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final amount = double.tryParse(amountController.text);
                  if (amount != null && amount > 0 && selectedCategoryId.value.isNotEmpty) {
                    await controller.addBudget(
                      categoryId: selectedCategoryId.value,
                      amount: amount,
                    );
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                child: const Text(AppStrings.save),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
