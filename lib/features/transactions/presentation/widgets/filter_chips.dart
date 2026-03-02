import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:walletflow/core/constants/app_constants.dart';
import 'package:walletflow/core/utils/responsive.dart';
import 'package:walletflow/features/transactions/data/models/transaction_model.dart';
import 'package:walletflow/features/transactions/presentation/controllers/transaction_controller.dart';

class FilterChips extends StatelessWidget {
  const FilterChips({
    super.key,
    required this.context,
    required this.controller,
  });

  final BuildContext context;
  final TransactionController controller;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Obx(
        () => Row(
          children: [
            FilterChip(
              label: const Text('All'),
              selected: controller.filterType.value == null,
              onSelected: (_) => controller.filterType.value = null,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            SizedBox(width: context.responsiveWidth(0.02)),
            FilterChip(
              label: const Text(AppStrings.income),
              selected: controller.filterType.value == TransactionType.income,
              onSelected: (_) =>
                  controller.filterType.value = TransactionType.income,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            SizedBox(width: context.responsiveWidth(0.02)),
            FilterChip(
              label: const Text(AppStrings.expense),
              selected: controller.filterType.value == TransactionType.expense,
              onSelected: (_) =>
                  controller.filterType.value = TransactionType.expense,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            SizedBox(width: context.responsiveWidth(0.02)),
            FilterChip(
              label: const Text(AppStrings.transfer),
              selected: controller.filterType.value == TransactionType.transfer,
              onSelected: (_) =>
                  controller.filterType.value = TransactionType.transfer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
