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
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.budgets, style: theme.textTheme.titleLarge),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined),
            onPressed: () => _showMonthPicker(context, controller),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.budgets.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.pie_chart_outline,
                  size: 64 * context.responsiveFontSize,
                  color: theme.colorScheme.outlineVariant,
                ),
                SizedBox(height: context.responsiveHeight(0.02)),
                Text(
                  AppStrings.noBudgets,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(context.responsivePadding),
          itemCount: controller.budgets.length,
          itemBuilder: (context, index) {
            final budget = controller.budgets[index];
            final category = Get.find<TransactionController>().getCategoryById(
              budget.categoryId,
            );
            final spent = budget.spent;
            final limit = budget.amount;
            final percent = limit > 0 ? spent / limit : 0.0;
            final isOver = spent > limit;

            final color = category != null
                ? Color(
                    int.parse(
                      category.color.replaceFirst('#', 'FF'),
                      radix: 16,
                    ),
                  )
                : theme.colorScheme.secondary;

            return Card(
              margin: EdgeInsets.only(bottom: context.responsiveHeight(0.02)),
              color: theme.colorScheme.surfaceContainerLow,
              child: Padding(
                padding: EdgeInsets.all(context.responsivePadding * 1.25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(
                            context.responsivePadding * 0.6,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getCategoryIcon(category?.icon ?? 'category'),
                            color: color,
                            size: 20 * context.responsiveFontSize,
                          ),
                        ),
                        SizedBox(width: context.responsiveWidth(0.03)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                category?.name ?? 'Category',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${currencyFormat.format(spent)} of ${currencyFormat.format(limit)}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isOver
                                      ? theme.colorScheme.error
                                      : theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${(percent * 100).toStringAsFixed(0)}%',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isOver
                                ? theme.colorScheme.error
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: context.responsiveHeight(0.02)),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: percent.clamp(0.0, 1.0),
                        minHeight: 10 * context.responsiveFontSize,
                        backgroundColor: theme.colorScheme.onSurface.withValues(
                          alpha: 0.3,
                        ),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isOver
                              ? theme.colorScheme.error
                              : theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    SizedBox(height: context.responsiveHeight(0.015)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isOver
                              ? 'Exceeded by ${currencyFormat.format(spent - limit)}'
                              : 'Remaining: ${currencyFormat.format(limit - spent)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isOver
                                ? theme.colorScheme.error
                                : theme.colorScheme.primary,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton.filledTonal(
                              icon: Icon(
                                Icons.edit_outlined,
                                size: 18 * context.responsiveFontSize,
                              ),
                              onPressed: () => _showAddBudgetBottomSheet(
                                context,
                                controller,
                                budget: budget,
                              ),
                            ),
                            SizedBox(width: context.responsiveWidth(0.02)),
                            IconButton.filledTonal(
                              icon: Icon(
                                Icons.delete_outline,
                                size: 18 * context.responsiveFontSize,
                              ),
                              onPressed: () => _showDeleteConfirmation(
                                context,
                                controller,
                                budget,
                              ),
                              style: IconButton.styleFrom(
                                foregroundColor: theme.colorScheme.error,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton.large(
        heroTag: 'budgets_fab',
        onPressed: () => _showAddBudgetBottomSheet(context, controller),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showMonthPicker(BuildContext context, BudgetController controller) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Select Date', style: theme.textTheme.titleLarge),
            SizedBox(height: context.responsiveHeight(0.03)),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: controller.selectedMonth.value,
                    decoration: const InputDecoration(labelText: 'Month'),
                    items: List.generate(12, (index) => index + 1)
                        .map(
                          (m) => DropdownMenuItem(
                            value: m,
                            child: Text(
                              controller.getMonthName(m),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) => controller.selectedMonth.value = val!,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: controller.selectedYear.value,
                    decoration: const InputDecoration(labelText: 'Year'),
                    items:
                        List.generate(
                              5,
                              (index) => DateTime.now().year - 2 + index,
                            )
                            .map(
                              (y) => DropdownMenuItem(
                                value: y,
                                child: Text(
                                  y.toString(),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                    onChanged: (val) => controller.selectedYear.value = val!,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: () {
                  controller.loadBudgets();
                  Get.back();
                },
                child: const Text('Confirm'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddBudgetBottomSheet(
    BuildContext context,
    BudgetController controller, {
    BudgetModel? budget,
  }) {
    final theme = Theme.of(context);
    final amountController = TextEditingController(
      text: budget?.amount.toString() ?? '',
    );
    final RxString selectedCategoryId = (budget?.categoryId ?? '').obs;
    final transactionController = Get.find<TransactionController>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              budget == null ? AppStrings.addBudget : 'Edit Budget',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: context.responsiveHeight(0.03)),
            Obx(
              () => DropdownButtonFormField<String>(
                initialValue: selectedCategoryId.value.isEmpty
                    ? null
                    : selectedCategoryId.value,
                decoration: const InputDecoration(labelText: 'Category'),
                items: transactionController.expenseCategories
                    .map(
                      (cat) => DropdownMenuItem(
                        value: cat.id,
                        child: Text(
                          cat.name,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: budget != null
                    ? null
                    : (val) => selectedCategoryId.value = val ?? '',
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            SizedBox(height: context.responsiveHeight(0.02)),
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: theme.textTheme.headlineMedium,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                labelText: 'Limit Amount',
                prefixText: '\$ ',
              ),
            ),
            SizedBox(height: context.responsiveHeight(0.04)),
            SizedBox(
              width: double.infinity,
              height: 56 * context.responsiveFontSize,
              child: FilledButton(
                onPressed: () async {
                  final amount = double.tryParse(amountController.text);
                  if (amount != null &&
                      amount > 0 &&
                      selectedCategoryId.value.isNotEmpty) {
                    if (budget == null) {
                      await controller.addBudget(
                        categoryId: selectedCategoryId.value,
                        amount: amount,
                        month: controller.selectedMonth.value,
                        year: controller.selectedYear.value,
                      );
                    } else {
                      budget.amount = amount;
                      await controller.updateBudget(budget);
                    }
                    if (context.mounted) Get.back();
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

  void _showDeleteConfirmation(
    BuildContext context,
    BudgetController controller,
    BudgetModel budget,
  ) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.deleteBudget),
        content: const Text('Are you sure you want to delete this budget?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              await controller.deleteBudget(budget.id);
              Get.back();
            },
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String icon) {
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
