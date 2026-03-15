import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:walletflow/core/constants/app_constants.dart';
import 'package:walletflow/core/utils/responsive.dart';
import '../../data/models/loan_model.dart';
import '../controllers/loan_controller.dart';
import '../widgets/loan_summary_card.dart';
import '../widgets/loan_list_item.dart';
import '../widgets/loan_dialogs.dart';
import '../../../../core/widgets/empty_state_widget.dart';

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
            Obx(
              () => LoanSummaryCard(
                totalLent: controller.totalLent.value,
                totalOwed: controller.totalOwed.value,
                netPosition: controller.netPosition.value,
                currencyFormat: currencyFormat,
              ),
            ),
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
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'loans_fab',
          onPressed: () =>
              LoanDialogs.showAddLoanBottomSheet(context, controller),
          label: const Text('Add Loan'),
          icon: const Icon(Icons.add),
        ),
      ),
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
        return _buildEmptyState(context, theme);
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
          return LoanListItem(
            loan: loan,
            controller: controller,
            currencyFormat: format,
            onTap: () =>
                LoanDialogs.showLoanDetails(context, controller, loan, format),
            onAddMore: () => LoanDialogs.showAddMoreBottomSheet(
              context,
              controller,
              loan,
              format,
            ),
          );
        },
      );
    });
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return EmptyStateWidget(
      icon: Icons.handshake_outlined,
      title: AppStrings.noLoans,
      subtitle: 'Keep track of money you lend to or borrow from friends.',
      // actionLabel: 'Add Loan',
      // onAction: () =>
      //     LoanDialogs.showAddLoanBottomSheet(context, Get.find<LoanController>()),
    );
  }
}
