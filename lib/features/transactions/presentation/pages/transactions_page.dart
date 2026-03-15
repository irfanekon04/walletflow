import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:walletflow/features/transactions/presentation/dialogs.dart/transaction_dialogs.dart';
import 'package:walletflow/features/transactions/presentation/widgets/transaction_page_body.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../accounts/presentation/controllers/account_controller.dart';
import '../controllers/transaction_controller.dart';

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TransactionController>();
    final accountController = Get.find<AccountController>();
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.transactions, style: theme.textTheme.titleLarge),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_outlined),
            onPressed: () => TransactionDialogs.showFilterBottomSheet(
              context,
              controller,
              accountController,
            ),
          ),
        ],
      ),
      body: TransactionPageBody(
        controller: controller,
        theme: theme,
        accountController: accountController,
        currencyFormat: currencyFormat,
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'transactions_fab',
        onPressed: () =>
            TransactionDialogs.showAddTransactionBottomSheet(context),
        label: const Text('Add Transaction'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
