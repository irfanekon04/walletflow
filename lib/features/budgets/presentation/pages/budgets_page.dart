import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:walletflow/core/constants/app_constants.dart';
import 'package:walletflow/core/utils/responsive.dart';
import '../../../transactions/presentation/controllers/transaction_controller.dart';
import '../controllers/budget_controller.dart';
import '../widgets/budget_list_item.dart';
import '../widgets/budget_dialogs.dart';
import '../../../../core/widgets/empty_state_widget.dart';

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
            onPressed: () => BudgetDialogs.showMonthPicker(context, controller),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.budgets.isEmpty) {
          return _buildEmptyState(context, theme);
        }

        return ListView.builder(
          padding: EdgeInsets.only(
            top: AppDimensions.paddingS,
            left: context.responsivePadding,
            right: context.responsivePadding,
            bottom: 120,
          ),
          itemCount: controller.budgets.length,
          itemBuilder: (context, index) {
            final budget = controller.budgets[index];
            final category = Get.find<TransactionController>().getCategoryById(
              budget.categoryId,
            );

            return BudgetListItem(
              budget: budget,
              category: category,
              currencyFormat: currencyFormat,
              onEdit: () => BudgetDialogs.showAddBudgetBottomSheet(
                context,
                controller,
                budget: budget,
              ),
              onDelete: () => BudgetDialogs.showDeleteConfirmation(
                context,
                controller,
                budget,
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'budgets_fab',
        onPressed: () =>
            BudgetDialogs.showAddBudgetBottomSheet(context, controller),
        label: const Text('Add Budget'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return EmptyStateWidget(
      icon: Icons.pie_chart_outline,
      title: AppStrings.noBudgets,
      subtitle: 'Set monthly limits for your categories to save more.',
      // actionLabel: 'Create Budget',
      // onAction: () => BudgetDialogs.showAddBudgetBottomSheet(
      //   context,
      //   Get.find<BudgetController>(),
      // ),
    );
  }
}
