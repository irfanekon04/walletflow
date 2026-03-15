import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:walletflow/core/constants/app_constants.dart';
import 'package:walletflow/core/utils/responsive.dart';
import 'package:walletflow/core/widgets/app_button.dart';
import 'package:walletflow/core/widgets/app_dropdown.dart';
import 'package:walletflow/core/widgets/app_text_field.dart';
import 'package:walletflow/core/widgets/confirm_dialog.dart';
import '../../../transactions/presentation/controllers/transaction_controller.dart';
import '../../data/models/budget_model.dart';
import '../controllers/budget_controller.dart';

class BudgetDialogs {
  static void showMonthPicker(BuildContext context, BudgetController controller) {
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
                  child: AppDropdown<int>(
                    value: controller.selectedMonth.value,
                    label: 'Month',
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
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AppDropdown<int>(
                    value: controller.selectedYear.value,
                    label: 'Year',
                    items: List.generate(
                      5,
                      (index) => DateTime.now().year - 2 + index,
                    ).map(
                      (y) => DropdownMenuItem(
                        value: y,
                        child: Text(
                          y.toString(),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ).toList(),
                    onChanged: (val) => controller.selectedYear.value = val!,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            AppButton(
              label: 'Confirm',
              onPressed: () {
                controller.loadBudgets();
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }

  static void showAddBudgetBottomSheet(
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
              () => AppDropdown<String>(
                value: selectedCategoryId.value.isEmpty
                    ? null
                    : selectedCategoryId.value,
                label: 'Category',
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
              ),
            ),
            SizedBox(height: context.responsiveHeight(0.02)),
            AppAmountField(controller: amountController, label: 'Limit Amount'),
            SizedBox(height: context.responsiveHeight(0.04)),
            AppButton(
              label: AppStrings.save,
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
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> showDeleteConfirmation(
    BuildContext context,
    BudgetController controller,
    BudgetModel budget,
  ) async {
    final confirmed = await ConfirmDialog.show(
      title: AppStrings.deleteBudget,
      message: 'Are you sure you want to delete this budget?',
      confirmText: 'Delete',
      isDestructive: true,
    );

    if (confirmed == true) {
      await controller.deleteBudget(budget.id);
    }
  }
}
