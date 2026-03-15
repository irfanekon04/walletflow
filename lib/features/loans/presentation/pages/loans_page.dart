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
            Obx(() => LoanSummaryCard(
              totalLent: controller.totalLent.value,
              totalOwed: controller.totalOwed.value,
              netPosition: controller.netPosition.value,
              currencyFormat: currencyFormat,
            )),
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
        floatingActionButton: FloatingActionButton.large(
          heroTag: 'loans_fab',
          onPressed: () => LoanDialogs.showAddLoanBottomSheet(context, controller),
          child: const Icon(Icons.add),
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
      final loans = type == LoanType.lent ? controller.lentLoans : controller.owedLoans;

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
            onTap: () => LoanDialogs.showLoanDetails(context, controller, loan, format),
            onAddMore: () => LoanDialogs.showAddMoreBottomSheet(context, controller, loan, format),
          );
        },
      );
    });
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
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
}
