import 'package:flutter/material.dart';
import 'package:walletflow/core/constants/app_constants.dart';
import 'package:walletflow/core/widgets/app_button.dart';
import 'package:walletflow/features/accounts/presentation/controllers/account_controller.dart';
import 'package:walletflow/features/transactions/presentation/controllers/transaction_controller.dart';

class SaveButton extends StatelessWidget {
  const SaveButton({
    super.key,
    required this.transactionController,
    required this.accountController,
  });

  final TransactionController transactionController;
  final AccountController accountController;

  @override
  Widget build(BuildContext context) {
    return AppButton(label: AppStrings.save, onPressed: () {});
  }
}
