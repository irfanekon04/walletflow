import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/responsive.dart';
import '../../data/models/loan_model.dart';
import '../controllers/loan_controller.dart';

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
        padding: EdgeInsets.all(context.responsivePadding),
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
              subtitle: Text(
                'Remaining: ${format.format(remaining)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              trailing: Column(
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
            SizedBox(height: context.responsiveHeight(0.025)),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Person Name'),
            ),
            SizedBox(height: context.responsiveHeight(0.02)),
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: theme.textTheme.headlineMedium,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                labelText: 'Amount',
                prefixText: '\$ ',
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.3,
                ),
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
                      nameController.text.isNotEmpty) {
                    if (loan == null) {
                      await controller.addLoan(
                        personName: nameController.text,
                        amount: amount,
                        type: selectedType.value,
                        date: DateTime.now(),
                      );
                    } else {
                      loan.personName = nameController.text;
                      loan.amount = amount;
                      loan.type = selectedType.value;
                      await controller.updateLoan(loan);
                    }
                    Get.back();
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

  void _showLoanDetails(
    BuildContext context,
    LoanController controller,
    LoanModel loan,
    NumberFormat format,
  ) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loan.personName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Amount: ${format.format(loan.amount)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Paid: ${format.format(loan.paidAmount)}'),
            Text(
              'Remaining: ${format.format(loan.amount - loan.paidAmount)}',
              style: TextStyle(
                color: loan.type == LoanType.lent
                    ? theme.colorScheme.primary
                    : theme.colorScheme.error,
              ),
            ),
            SizedBox(height: context.responsiveHeight(0.01)),
            Text('Date: ${DateFormat('MMMM dd, yyyy').format(loan.date)}'),
          ],
        ),
        actions: [
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

  void _showDeleteConfirmation(
    BuildContext context,
    LoanController controller,
    LoanModel loan,
  ) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Loan'),
        content: const Text(
          'Are you sure you want to delete this loan record?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              await controller.deleteLoan(loan.id);
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
}
