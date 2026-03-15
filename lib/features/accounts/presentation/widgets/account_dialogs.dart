import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/utils/responsive.dart';
import '../../data/models/account_model.dart';
import '../controllers/account_controller.dart';

class AccountDialogs {
  static void showAddAccountBottomSheet(
    BuildContext context,
    AccountController controller,
  ) {
    final theme = Theme.of(context);
    final nameController = TextEditingController();
    final balanceController = TextEditingController(text: '0');
    final creditLimitController = TextEditingController();
    final Rx<AccountType> selectedType = AccountType.cash.obs;

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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.addAccount,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Obx(
                () => SegmentedButton<AccountType>(
                  segments: AccountType.values
                      .map(
                        (type) => ButtonSegment(
                          value: type,
                          label: Text(
                            type.name.toUpperCase(),
                            style: TextStyle(fontSize: 10.sp),
                          ),
                        ),
                      )
                      .toList(),
                  selected: {selectedType.value},
                  onSelectionChanged: (val) => selectedType.value = val.first,
                ),
              ),
              24.h.verticalSpacer,
              AppTextField(
                controller: nameController,
                label: 'Account Name',
                prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
              ),
              16.h.verticalSpacer,
              AppAmountField(
                controller: balanceController,
                label: 'Initial Balance',
              ),
              16.h.verticalSpacer,
              Obx(() {
                if (selectedType.value == AccountType.card) {
                  return AppAmountField(
                    controller: creditLimitController,
                    label: 'Credit Limit',
                  );
                }
                return const SizedBox.shrink();
              }),
              32.h.verticalSpacer,
              AppButton(
                label: AppStrings.save,
                onPressed: () async {
                  if (nameController.text.isNotEmpty) {
                    final balance =
                        double.tryParse(balanceController.text) ?? 0;
                    final creditLimit = double.tryParse(
                      creditLimitController.text,
                    );
                    await controller.addAccount(
                      name: nameController.text,
                      type: selectedType.value,
                      balance: balance,
                      creditLimit: creditLimit,
                    );
                    Get.back();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void showEditAccountBottomSheet(
    BuildContext context,
    AccountController controller,
    AccountModel account,
  ) {
    final theme = Theme.of(context);
    final nameController = TextEditingController(text: account.name);
    final creditLimitController = TextEditingController(
      text: account.creditLimit?.toString() ?? '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 20.r,
          right: 20.r,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Account',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              24.h.verticalSpacer,
              AppTextField(
                controller: nameController,
                label: 'Account Name',
                prefixIcon: const Icon(Icons.edit_outlined),
              ),
              16.h.verticalSpacer,
              if (account.type == AccountType.card)
                AppAmountField(
                  controller: creditLimitController,
                  label: 'Credit Limit',
                ),
              32.h.verticalSpacer,
              AppButton(
                label: AppStrings.save,
                onPressed: () async {
                  if (nameController.text.isNotEmpty) {
                    final updated = account.copyWith(
                      name: nameController.text,
                      creditLimit: double.tryParse(creditLimitController.text),
                    );
                    await controller.updateAccount(updated);
                    Get.back();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> confirmDeleteAccount(
    BuildContext context,
    AccountController controller,
    AccountModel account,
  ) async {
    final confirmed = await ConfirmDialog.show(
      title: 'Delete Account',
      message: 'Are you sure you want to delete "${account.name}"?',
      confirmText: AppStrings.delete,
      isDestructive: true,
    );

    if (confirmed == true) {
      controller.deleteAccount(account.id);
    }
  }

  static IconData getAccountIcon(AccountType type) {
    switch (type) {
      case AccountType.cash:
        return Icons.account_balance_wallet_outlined;
      case AccountType.bank:
        return Icons.account_balance_outlined;
      case AccountType.mfs:
        return Icons.phone_android_outlined;
      case AccountType.card:
        return Icons.credit_card_outlined;
    }
  }
}
