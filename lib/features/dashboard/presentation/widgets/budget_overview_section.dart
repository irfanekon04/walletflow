import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:walletflow/core/constants/app_constants.dart';
import 'package:walletflow/core/utils/responsive.dart';
import 'package:walletflow/features/budgets/presentation/controllers/budget_controller.dart';

class BudgetOverviewSection extends StatelessWidget {
  const BudgetOverviewSection({
    super.key,
    required this.context,
    required this.controller,
    required this.format,
  });

  final BuildContext context;
  final BudgetController controller;
  final NumberFormat format;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Budget Overview',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (controller.budgets.isEmpty) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    AppStrings.noBudgets,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            );
          }
          final percent = controller.totalBudget.value > 0
              ? controller.totalSpent.value / controller.totalBudget.value
              : 0.0;
          final isOver =
              controller.totalSpent.value > controller.totalBudget.value;

          return Card(
            color: theme.colorScheme.surfaceContainerLow,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${controller.getMonthName(controller.selectedMonth.value)} ${controller.selectedYear.value}',
                        style: theme.textTheme.labelLarge,
                      ),
                      Text(
                        '${format.format(controller.totalSpent.value)} / ${format.format(controller.totalBudget.value)}',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: isOver
                              ? theme.colorScheme.error
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: percent.clamp(0.0, 1.0),
                      minHeight: 8 * context.responsiveFontSize,
                      backgroundColor: theme.colorScheme.onSurface.withValues(
                        alpha: .3,
                      ),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isOver
                            ? theme.colorScheme.error
                            : theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
