import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:walletflow/core/database/database_service.dart';
import 'package:walletflow/app/routes/app_routes.dart';
import 'package:walletflow/features/accounts/presentation/controllers/account_controller.dart';
import 'package:walletflow/features/accounts/data/models/account_model.dart';
import 'package:walletflow/core/widgets/snackbar_helper.dart';

class OnboardingController extends GetxController {
  final pageController = PageController();
  final RxInt currentPage = 0.obs;

  // Account Setup Form fields
  final accountNameController = TextEditingController();
  final Rx<AccountType> selectedAccountType = AccountType.cash.obs;
  final balanceController = TextEditingController();

  final AccountController _accountController = Get.find<AccountController>();

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void nextPage() {
    if (currentPage.value < 2) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      completeOnboarding();
    }
  }

  void previousPage() {
    if (currentPage.value > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> completeOnboarding() async {
    if (accountNameController.text.trim().isEmpty) {
      SnackbarHelper.info(
        "Please enter an account name to get started.",
        title: "Required",
      );
      return;
    }

    final double balance = double.tryParse(balanceController.text) ?? 0.0;

    // Create the initial account
    await _accountController.addAccount(
      name: accountNameController.text.trim(),
      type: selectedAccountType.value,
      balance: balance,
    );

    // Mark onboarding as completed
    await DatabaseService.settings.put('onboarding_completed', true);

    // Navigate to Home
    Get.offAllNamed(Routes.home);
  }

  @override
  void onClose() {
    pageController.dispose();
    accountNameController.dispose();
    balanceController.dispose();
    super.onClose();
  }
}
