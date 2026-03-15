import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:walletflow/core/constants/app_constants.dart';
import 'package:walletflow/core/utils/responsive.dart';
import 'package:walletflow/core/widgets/app_button.dart';
import 'package:walletflow/core/widgets/app_text_field.dart';
import 'package:walletflow/core/widgets/confirm_dialog.dart';
import 'package:walletflow/core/widgets/snackbar_helper.dart';
import '../../data/models/loan_model.dart';
import '../controllers/loan_controller.dart';
import '../widgets/account_dropdown.dart';
import '../widgets/payment_confirmation_dialog.dart';

class LoanDialogs {
  static void showAddLoanBottomSheet(
    BuildContext context,
    LoanController controller, {
    LoanModel? loan,
  }) {
    final theme = Theme.of(context);
    final nameController = TextEditingController(text: loan?.personName ?? '');
    final amountController = TextEditingController(
      text: loan?.amount.toString() ?? '',
    );
    final Rx<LoanType> selectedType = (loan?.type ?? LoanType.lent).obs;
    final Rx<String?> selectedAccountId = (loan?.accountId).obs;
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

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
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loan == null ? AppStrings.addLoan : 'Edit Loan',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: context.responsiveHeight(0.03)),
                Obx(
                  () => SegmentedButton<LoanType>(
                    segments: const [
                      ButtonSegment(
                        value: LoanType.lent,
                        label: Text(AppStrings.lent),
                      ),
                      ButtonSegment(
                        value: LoanType.owed,
                        label: Text(AppStrings.owed),
                      ),
                    ],
                    selected: {selectedType.value},
                    onSelectionChanged: (val) => selectedType.value = val.first,
                  ),
                ),
                Obx(
                  () => Container(
                    margin: EdgeInsets.only(
                      top: context.responsiveHeight(0.01),
                    ),
                    padding: EdgeInsets.all(context.responsivePadding * 0.5),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusS,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        SizedBox(width: context.responsivePadding * 0.25),
                        Expanded(
                          child: Text(
                            selectedType.value == LoanType.lent
                                ? 'Lent: You give money to someone (deducted from account)'
                                : 'Owed: You borrow money from someone (added to account)',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: context.responsiveHeight(0.025)),
                AppTextField(
                  controller: nameController,
                  label: 'Person Name',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: context.responsiveHeight(0.02)),
                AppAmountField(controller: amountController, label: 'Amount'),
                SizedBox(height: context.responsiveHeight(0.02)),
                Obx(
                  () => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AccountDropdown(
                        selectedAccountId: selectedAccountId.value,
                        onChanged: (value) => selectedAccountId.value = value,
                        isRequired: true,
                        labelText: 'Select Account *',
                      ),
                      SizedBox(height: context.responsiveHeight(0.04)),
                      AppButton(
                        label: AppStrings.save,
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            if (selectedAccountId.value == null) {
                              SnackbarHelper.warning(
                                'Please select an account',
                                title: 'Account Required',
                              );
                              return;
                            }
                            final amount = double.tryParse(amountController.text);
                            if (amount != null &&
                                amount > 0 &&
                                nameController.text.isNotEmpty) {
                              if (loan == null) {
                                await controller.addLoan(
                                  personName: nameController.text,
                                  amount: amount,
                                  type: selectedType.value,
                                  date: DateTime.now(),
                                  accountId: selectedAccountId.value!,
                                );
                              } else {
                                loan.personName = nameController.text;
                                loan.amount = amount;
                                loan.type = selectedType.value;
                                await controller.updateLoan(loan);
                              }
                              Get.back();
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void showAddMoreBottomSheet(
    BuildContext context,
    LoanController controller,
    LoanModel loan,
    NumberFormat format,
  ) {
    final theme = Theme.of(context);
    final isLent = loan.type == LoanType.lent;
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    final Rx<String?> selectedAccountId = Rx<String?>(loan.accountId);
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

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
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add More ${isLent ? AppStrings.lent : AppStrings.owed}',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: context.responsiveHeight(0.01)),
                Container(
                  padding: EdgeInsets.all(context.responsivePadding * 0.75),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Current Amount:',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        format.format(loan.amount),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isLent
                              ? theme.colorScheme.primary
                              : theme.colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: context.responsiveHeight(0.025)),
                Container(
                  padding: EdgeInsets.all(context.responsivePadding * 0.5),
                  decoration: BoxDecoration(
                    color:
                        (isLent
                                ? theme.colorScheme.primary
                                : theme.colorScheme.error)
                            .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                    border: Border.all(
                      color:
                          (isLent
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.error)
                              .withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isLent ? Icons.arrow_outward : Icons.arrow_downward,
                        size: 16,
                        color: isLent
                            ? theme.colorScheme.primary
                            : theme.colorScheme.error,
                      ),
                      SizedBox(width: context.responsivePadding * 0.25),
                      Expanded(
                        child: Text(
                          isLent
                              ? 'This will add to the amount they owe you. Money will be deducted from account.'
                              : 'This will add to what you owe them. Money will be added to your account.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isLent
                                ? theme.colorScheme.primary
                                : theme.colorScheme.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: context.responsiveHeight(0.025)),
                AppAmountField(
                  controller: amountController,
                  label: 'Additional Amount',
                ),
                SizedBox(height: context.responsiveHeight(0.02)),
                Obx(
                  () => Column(
                    children: [
                      AccountDropdown(
                        selectedAccountId: selectedAccountId.value,
                        onChanged: (value) => selectedAccountId.value = value,
                        isRequired: true,
                        labelText:
                            isLent ? 'Deduct from Account *' : 'Add to Account *',
                      ),
                      SizedBox(height: context.responsiveHeight(0.02)),
                      AppTextField(
                        controller: noteController,
                        label: 'Note (optional)',
                      ),
                      SizedBox(height: context.responsiveHeight(0.04)),
                      AppButton(
                        label: 'Add',
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            if (selectedAccountId.value == null) {
                              SnackbarHelper.warning(
                                'Please select an account',
                                title: 'Account Required',
                              );
                              return;
                            }
                            final amount = double.parse(amountController.text);
                            await controller.addMoreToLoan(
                              loan: loan,
                              additionalAmount: amount,
                              accountId: selectedAccountId.value!,
                              note:
                                  noteController.text.isEmpty
                                      ? null
                                      : noteController.text,
                            );
                            Get.back();
                            SnackbarHelper.success(
                              'Added ${format.format(amount)} to ${loan.personName}\'s loan',
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void showLoanDetails(
    BuildContext context,
    LoanController controller,
    LoanModel loan,
    NumberFormat format,
  ) {
    final theme = Theme.of(context);
    final isLent = loan.type == LoanType.lent;
    final remaining = loan.amount - loan.paidAmount;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loan.personName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total ${isLent ? 'Lent' : 'Owed'} Amount: ${format.format(loan.amount)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Paid: ${format.format(loan.paidAmount)}'),
            Text(
              'Remaining: ${format.format(remaining)}',
              style: TextStyle(
                color: isLent
                    ? theme.colorScheme.primary
                    : theme.colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: context.responsiveHeight(0.01)),
            Text('Date: ${DateFormat('MMMM dd, yyyy').format(loan.date)}'),
            if (!loan.isCompleted && remaining > 0) ...[
              SizedBox(height: context.responsiveHeight(0.02)),
              Container(
                padding: EdgeInsets.all(context.responsivePadding * 0.5),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(
                    alpha: 0.3,
                  ),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    SizedBox(width: context.responsivePadding * 0.25),
                    Expanded(
                      child: Text(
                        'Account: ${controller.getAccountById(loan.accountId)?.name ?? "Unknown"}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (!loan.isCompleted && remaining > 0)
            FilledButton.icon(
              onPressed: () {
                Get.back();
                showAddPaymentDialog(
                  context,
                  controller,
                  loan,
                  format,
                  remaining,
                );
              },
              icon: Icon(
                isLent ? Icons.call_received : Icons.call_made,
                size: 18,
              ),
              label: const Text('Add Payment'),
            ),
          TextButton(
            onPressed: () {
              Get.back();
              showDeleteConfirmation(context, controller, loan);
            },
            child: Text(
              'Delete',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              showAddLoanBottomSheet(context, controller, loan: loan);
            },
            child: const Text('Edit'),
          ),
          FilledButton.tonal(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  static void showAddPaymentDialog(
    BuildContext context,
    LoanController controller,
    LoanModel loan,
    NumberFormat format,
    double remaining,
  ) {
    final theme = Theme.of(context);
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    final Rx<String?> selectedAccountId = Rx<String?>(loan.accountId);
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final isLent = loan.type == LoanType.lent;

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
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLent ? 'Record Payment Received' : 'Record Payment Made',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: context.responsiveHeight(0.01)),
                Text(
                  'Remaining: ${format.format(remaining)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: context.responsiveHeight(0.015)),
                  padding: EdgeInsets.all(context.responsivePadding * 0.5),
                  decoration: BoxDecoration(
                    color:
                        (isLent
                                ? theme.colorScheme.primary
                                : theme.colorScheme.error)
                            .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                    border: Border.all(
                      color:
                          (isLent
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.error)
                              .withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isLent ? Icons.call_received : Icons.call_made,
                        size: 16,
                        color: isLent
                            ? theme.colorScheme.primary
                            : theme.colorScheme.error,
                      ),
                      SizedBox(width: context.responsivePadding * 0.25),
                      Expanded(
                        child: Text(
                          isLent
                              ? 'Payment received: Adds money to your account (income)'
                              : 'Payment made: Deducts money from your account (expense)',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isLent
                                ? theme.colorScheme.primary
                                : theme.colorScheme.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: context.responsiveHeight(0.03)),
                AppAmountField(
                  controller: amountController,
                  label: 'Payment Amount',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return 'Please enter a valid amount';
                    }
                    if (amount > remaining) {
                      return 'Amount exceeds remaining balance';
                    }
                    return null;
                  },
                ),
                SizedBox(height: context.responsiveHeight(0.02)),
                Obx(
                  () => Column(
                    children: [
                      AccountDropdown(
                        selectedAccountId: selectedAccountId.value,
                        onChanged: (value) => selectedAccountId.value = value,
                        isRequired: true,
                        labelText:
                            isLent ? 'Receive to Account *' : 'Pay from Account *',
                      ),
                      SizedBox(height: context.responsiveHeight(0.02)),
                      AppTextField(
                        controller: noteController,
                        label: 'Note (optional)',
                      ),
                      SizedBox(height: context.responsiveHeight(0.04)),
                      AppButton(
                        label: 'Confirm Payment',
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            if (selectedAccountId.value == null) {
                              SnackbarHelper.warning(
                                'Please select an account',
                                title: 'Account Required',
                              );
                              return;
                            }
                            final amount = double.parse(amountController.text);
                            final account = controller.getAccountById(
                              selectedAccountId.value!,
                            );

                            final confirmed = await PaymentConfirmationDialog.show(
                              context: context,
                              amount: amount,
                              accountName: account?.name ?? 'Unknown',
                              isLent: isLent,
                            );

                            if (confirmed == true) {
                              await controller.addPayment(
                                loanId: loan.id,
                                amount: amount,
                                accountId: selectedAccountId.value!,
                                note:
                                    noteController.text.isEmpty
                                        ? null
                                        : noteController.text,
                              );
                              Get.back();
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Future<void> showDeleteConfirmation(
    BuildContext context,
    LoanController controller,
    LoanModel loan,
  ) async {
    final confirmed = await ConfirmDialog.show(
      title: 'Delete Loan',
      message: 'Are you sure you want to delete this loan record?',
      confirmText: 'Delete',
      isDestructive: true,
    );

    if (confirmed == true) {
      await controller.deleteLoan(loan.id);
    }
  }
}
