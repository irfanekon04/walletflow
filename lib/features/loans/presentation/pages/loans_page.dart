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
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.loans),
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
                  _buildLoansList(context, controller, LoanType.lent, currencyFormat),
                  _buildLoansList(context, controller, LoanType.owed, currencyFormat),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddLoanBottomSheet(context, controller),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildLoanSummary(BuildContext context, LoanController controller, NumberFormat format) {
    return Obx(() => Container(
      margin: EdgeInsets.all(AppDimensions.paddingM),
      padding: EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text(AppStrings.lent, style: TextStyle(color: Colors.grey[600])),
              Text(
                format.format(controller.totalLent.value),
                style: TextStyle(
                  fontSize: 18 * context.responsiveFontSize,
                  fontWeight: FontWeight.bold,
                  color: AppColors.incomeGreen,
                ),
              ),
            ],
          ),
          Container(width: 1, height: 40, color: Colors.grey[300]),
          Column(
            children: [
              Text(AppStrings.owed, style: TextStyle(color: Colors.grey[600])),
              Text(
                format.format(controller.totalOwed.value),
                style: TextStyle(
                  fontSize: 18 * context.responsiveFontSize,
                  fontWeight: FontWeight.bold,
                  color: AppColors.expenseRed,
                ),
              ),
            ],
          ),
          Container(width: 1, height: 40, color: Colors.grey[300]),
          Column(
            children: [
              Text('Net', style: TextStyle(color: Colors.grey[600])),
              Text(
                format.format(controller.netPosition.value),
                style: TextStyle(
                  fontSize: 18 * context.responsiveFontSize,
                  fontWeight: FontWeight.bold,
                  color: controller.netPosition.value >= 0 ? AppColors.incomeGreen : AppColors.expenseRed,
                ),
              ),
            ],
          ),
        ],
      ),
    ));
  }

  Widget _buildLoansList(BuildContext context, LoanController controller, LoanType type, NumberFormat format) {
    final loans = type == LoanType.lent ? controller.lentLoans : controller.owedLoans;
    
    if (loans.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.handshake, size: 64, color: Colors.grey[400]),
            const SizedBox(height: AppDimensions.paddingM),
            Text(
              AppStrings.noLoans,
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
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
                      loan.personName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16 * context.responsiveFontSize,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () => _showAddPaymentBottomSheet(context, controller, loan),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _confirmDelete(context, controller, loan),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.paddingS),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Remaining', style: TextStyle(color: Colors.grey[600])),
                    Text(
                      format.format(loan.remainingAmount),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: type == LoanType.lent ? AppColors.incomeGreen : AppColors.expenseRed,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.paddingXS),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Original', style: TextStyle(color: Colors.grey[600])),
                    Text(format.format(loan.originalAmount)),
                  ],
                ),
                const SizedBox(height: AppDimensions.paddingXS),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Date', style: TextStyle(color: Colors.grey[600])),
                    Text(DateFormat('MMM dd, yyyy').format(loan.date)),
                  ],
                ),
                if (loan.note != null && loan.note!.isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.paddingXS),
                  Text('Note: ${loan.note}', style: TextStyle(color: Colors.grey[600])),
                ],
                if (!loan.isCompleted) ...[
                  const SizedBox(height: AppDimensions.paddingM),
                  LinearProgressIndicator(
                    value: (loan.originalAmount - loan.remainingAmount) / loan.originalAmount,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.incomeGreen),
                  ),
                ] else ...[
                  const SizedBox(height: AppDimensions.paddingS),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: AppDimensions.paddingS, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.incomeGreen.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                    ),
                    child: const Text('Completed', style: TextStyle(color: AppColors.incomeGreen)),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddLoanBottomSheet(BuildContext context, LoanController controller) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    final Rx<LoanType> selectedType = LoanType.lent.obs;

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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppStrings.addLoan, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: AppDimensions.paddingM),
              Obx(() => Row(
                children: [
                  Expanded(child: ChoiceChip(
                    label: const Text(AppStrings.lent),
                    selected: selectedType.value == LoanType.lent,
                    onSelected: (_) => selectedType.value = LoanType.lent,
                  )),
                  const SizedBox(width: 8),
                  Expanded(child: ChoiceChip(
                    label: const Text(AppStrings.owed),
                    selected: selectedType.value == LoanType.owed,
                    onSelected: (_) => selectedType.value = LoanType.owed,
                  )),
                ],
              )),
              const SizedBox(height: AppDimensions.paddingM),
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: selectedType.value == LoanType.lent ? 'Borrower Name' : 'Lender Name'),
              ),
              const SizedBox(height: AppDimensions.paddingM),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount', prefixText: '\$ '),
              ),
              const SizedBox(height: AppDimensions.paddingM),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(labelText: 'Note (optional)'),
              ),
              const SizedBox(height: AppDimensions.paddingL),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    final amount = double.tryParse(amountController.text);
                    if (amount != null && amount > 0 && nameController.text.isNotEmpty) {
                      await controller.addLoan(
                        type: selectedType.value,
                        personName: nameController.text,
                        amount: amount,
                        date: DateTime.now(),
                        note: noteController.text.isEmpty ? null : noteController.text,
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
      ),
    );
  }

  void _showAddPaymentBottomSheet(BuildContext context, LoanController controller, LoanModel loan) {
    final amountController = TextEditingController();
    final noteController = TextEditingController();

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
            const Text('Add Payment', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: AppDimensions.paddingM),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount',
                prefixText: '\$ ',
                hintText: 'Max: \$${loan.remainingAmount}',
              ),
            ),
            const SizedBox(height: AppDimensions.paddingM),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(labelText: 'Note (optional)'),
            ),
            const SizedBox(height: AppDimensions.paddingL),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  final amount = double.tryParse(amountController.text);
                  if (amount != null && amount > 0 && amount <= loan.remainingAmount) {
                    await controller.addPayment(
                      loan.id,
                      amount,
                      note: noteController.text.isEmpty ? null : noteController.text,
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

  void _confirmDelete(BuildContext context, LoanController controller, LoanModel loan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Loan'),
        content: Text('Are you sure you want to delete this ${loan.type == LoanType.lent ? "borrower" : "lender"}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () {
              controller.deleteLoan(loan.id);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.expenseRed),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }
}
