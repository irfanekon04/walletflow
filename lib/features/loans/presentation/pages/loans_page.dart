import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/snackbar_helper.dart';
import '../../data/models/loan_model.dart';
import '../controllers/loan_controller.dart';
import '../widgets/account_dropdown.dart';
import '../widgets/payment_confirmation_dialog.dart';

class LoansPage extends StatelessWidget {
  const LoansPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LoanController>();
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppStrings.loans, style: theme.textTheme.titleLarge),
          bottom: TabBar(
            onTap: (index) => controller.selectedTab.value = index,
            tabs: const [
              Tab(text: AppStrings.lent),
              Tab(text: AppStrings.owed),
            ],
          ),
        ),
        body: Column(
          children: [
            _buildLoanSummary(context, controller, currencyFormat),
            Expanded(
              child: TabBarView(
                children: [
                  _buildLoansList(
                    context,
                    controller,
                    LoanType.lent,
                    currencyFormat,
                  ),
                  _buildLoansList(
                    context,
                    controller,
                    LoanType.owed,
                    currencyFormat,
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.large(
          heroTag: 'loans_fab',
          onPressed: () => _showAddLoanBottomSheet(context, controller),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildLoanSummary(
    BuildContext context,
    LoanController controller,
    NumberFormat format,
  ) {
    final theme = Theme.of(context);
    return Obx(
      () => Container(
        margin: EdgeInsets.all(context.responsivePadding),
        padding: EdgeInsets.all(context.responsivePadding * 1.25),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSummaryItem(
              context,
              AppStrings.lent,
              controller.totalLent.value,
              format,
              theme.colorScheme.primary,
            ),
            Container(
              width: 1,
              height: 40,
              color: theme.colorScheme.outlineVariant,
            ),
            _buildSummaryItem(
              context,
              AppStrings.owed,
              controller.totalOwed.value,
              format,
              theme.colorScheme.error,
            ),
            Container(
              width: 1,
              height: 40,
              color: theme.colorScheme.outlineVariant,
            ),
            _buildSummaryItem(
              context,
              'Net',
              controller.netPosition.value,
              format,
              controller.netPosition.value >= 0
                  ? theme.colorScheme.primary
                  : theme.colorScheme.error,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String label,
    double amount,
    NumberFormat format,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 4 * context.responsiveFontSize),
        Text(
          format.format(amount),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildLoansList(
    BuildContext context,
    LoanController controller,
    LoanType type,
    NumberFormat format,
  ) {
    final theme = Theme.of(context);
    return Obx(() {
      final loans = type == LoanType.lent
          ? controller.lentLoans
          : controller.owedLoans;

      if (loans.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.handshake_outlined,
                size: 64 * context.responsiveFontSize,
                color: theme.colorScheme.outlineVariant,
              ),
              SizedBox(height: context.responsiveHeight(0.02)),
              Text(
                AppStrings.noLoans,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.only(
          top: AppDimensions.paddingS,
          left: context.responsivePadding,
          right: context.responsivePadding,
          bottom: 120,
        ),
        itemCount: loans.length,
        itemBuilder: (context, index) {
          final loan = loans[index];
          final remaining = loan.amount - loan.paidAmount;
          final isLent = loan.type == LoanType.lent;

          return Card(
            margin: EdgeInsets.only(bottom: context.responsiveHeight(0.015)),
            color: theme.colorScheme.surfaceContainerLow,
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(
                horizontal: context.responsivePadding,
                vertical: context.responsivePadding * 0.5,
              ),
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      (isLent
                              ? theme.colorScheme.primary
                              : theme.colorScheme.error)
                          .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  isLent ? Icons.arrow_outward : Icons.arrow_downward,
                  color: isLent
                      ? theme.colorScheme.primary
                      : theme.colorScheme.error,
                  size: 20 * context.responsiveFontSize,
                ),
              ),
              title: Text(
                loan.personName,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Remaining: ${format.format(remaining)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    controller.getAccountById(loan.accountId)?.name ??
                        'Unknown Account',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        format.format(loan.amount),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isLent
                              ? theme.colorScheme.primary
                              : theme.colorScheme.error,
                        ),
                      ),
                      Text(
                        isLent ? AppStrings.lent : AppStrings.owed,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.add,
                        size: 20,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                      onPressed: () => _showAddMoreBottomSheet(
                        context,
                        controller,
                        loan,
                        format,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
              onTap: () => _showLoanDetails(context, controller, loan, format),
            ),
          );
        },
      );
    });
  }

  void _showAddLoanBottomSheet(
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
                  () => AccountDropdown(
                    selectedAccountId: selectedAccountId.value,
                    onChanged: (value) => selectedAccountId.value = value,
                    isRequired: true,
                    labelText: 'Select Account *',
                  ),
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
        ),
      ),
    );
  }

  void _showAddMoreBottomSheet(
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
                  () => AccountDropdown(
                    selectedAccountId: selectedAccountId.value,
                    onChanged: (value) => selectedAccountId.value = value,
                    isRequired: true,
                    labelText: isLent
                        ? 'Deduct from Account *'
                        : 'Add to Account *',
                  ),
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
                        note: noteController.text.isEmpty
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
        ),
      ),
    );
  }

  void _showLoanDetails(
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
                _showAddPaymentDialog(
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
              _showDeleteConfirmation(context, controller, loan);
            },
            child: Text(
              'Delete',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _showAddLoanBottomSheet(context, controller, loan: loan);
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

  void _showAddPaymentDialog(
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
                  () => AccountDropdown(
                    selectedAccountId: selectedAccountId.value,
                    onChanged: (value) => selectedAccountId.value = value,
                    isRequired: true,
                    labelText: isLent
                        ? 'Receive to Account *'
                        : 'Pay from Account *',
                  ),
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
                          note: noteController.text.isEmpty
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
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(
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
