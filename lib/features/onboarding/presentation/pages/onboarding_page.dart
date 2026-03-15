import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/onboarding_controller.dart';
import 'package:walletflow/core/utils/responsive.dart';
import 'package:walletflow/core/widgets/widgets.dart';
import 'package:walletflow/features/accounts/data/models/account_model.dart';

class OnboardingPage extends GetView<OnboardingController> {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                children: [
                  _buildWelcomeSlide(context),
                  _buildFeaturesSlide(context),
                  _buildAccountSetupSlide(context),
                ],
              ),
            ),
            _buildBottomNavigation(context),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSlide(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(context.responsivePadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.account_balance_wallet_rounded,
              size: 100 * context.responsiveFontSize,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          SizedBox(height: context.responsiveHeight(0.05)),
          Text(
            'WalletFlow',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: context.responsiveHeight(0.015)),
          Text(
            'Simple. Powerful. Personal.',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.secondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: context.responsiveHeight(0.025)),
          Text(
            'Master your money with ease. Track expenses, manage budgets, and stay on top of loans.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSlide(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(context.responsivePadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Track Everything',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          SizedBox(height: context.responsiveHeight(0.04)),
          _buildFeatureItem(
            context,
            Icons.account_balance_rounded,
            'Unified Accounts',
            'View all your bank, cash, and MFS accounts in one place.',
          ),
          SizedBox(height: context.responsiveHeight(0.03)),
          _buildFeatureItem(
            context,
            Icons.pie_chart_rounded,
            'Smart Budgets',
            'Set spending limits and get real-time progress updates.',
          ),
          SizedBox(height: context.responsiveHeight(0.03)),
          _buildFeatureItem(
            context,
            Icons.handshake_rounded,
            'Simple Loans',
            'Record money lent and owed with partial payment tracking.',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
        ),
        SizedBox(width: context.responsiveWidth(0.04)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              Text(description, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountSetupSlide(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(context.responsivePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: context.responsiveHeight(0.05)),
          Text(
            'Set up your first account',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          SizedBox(height: context.responsiveHeight(0.01)),
          Text(
            'Enter details for your primary source of funds to get started.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          SizedBox(height: context.responsiveHeight(0.04)),
          AppTextField(
            controller: controller.accountNameController,
            label: 'Account Name',
            hint: 'e.g., Main Savings, Pocket Cash',
            textInputAction: TextInputAction.next,
          ),
          SizedBox(height: context.responsiveHeight(0.03)),
          Text('Account Type', style: Theme.of(context).textTheme.labelLarge),
          SizedBox(height: context.responsiveHeight(0.01)),
          Obx(
            () => Wrap(
              spacing: 8,
              children: AccountType.values.map((type) {
                return ChoiceChip(
                  label: Text(type.name.capitalizeFirst!),
                  selected: controller.selectedAccountType.value == type,
                  onSelected: (selected) {
                    if (selected) {
                      controller.selectedAccountType.value = type;
                    }
                  },
                );
              }).toList(),
            ),
          ),
          SizedBox(height: context.responsiveHeight(0.03)),
          AppAmountField(
            controller: controller.balanceController,
            label: 'Initial Balance',
          ),
          SizedBox(height: context.responsiveHeight(0.05)),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(context.responsivePadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(
            () => Opacity(
              opacity: controller.currentPage.value > 0 ? 1 : 0,
              child: TextButton(
                onPressed: controller.previousPage,
                child: const Text('Back'),
              ),
            ),
          ),
          Row(
            children: List.generate(
              3,
              (index) => Obx(
                () => AnimatedContainer(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: controller.currentPage.value == index ? 24 : 8,
                  height: 8,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: controller.currentPage.value == index
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
              ),
            ),
          ),
          Obx(
            () => SizedBox(
              width: 140 * context.responsiveFontSize,
              child: AppButton(
                onPressed: controller.nextPage,
                label: controller.currentPage.value == 2
                    ? 'Get Started'
                    : 'Next',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
