import 'package:flutter/material.dart';
import 'package:walletflow/core/constants/app_constants.dart';
import 'package:walletflow/core/utils/responsive.dart';

class IncomeExpenseSummary extends StatelessWidget {
  const IncomeExpenseSummary({
    super.key,
    required this.income,
    required this.expense,
  });

  final String income;
  final String expense;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Card(
            color: theme.colorScheme.surfaceContainerLow,
            child: Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.arrow_downward,
                        color: theme.colorScheme.primary,
                        size: 18.sp,
                      ),
                      4.w.horizontalSpacer,
                      Text(
                        AppStrings.income,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                  8.h.verticalSpacer,
                  Text(
                    income,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 22.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        12.w.horizontalSpacer,
        Expanded(
          child: Card(
            color: theme.colorScheme.surfaceContainerLow,
            child: Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.arrow_upward,
                        color: theme.colorScheme.error,
                        size: 18.sp,
                      ),
                      4.w.horizontalSpacer,
                      Text(
                        AppStrings.expense,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                  8.h.verticalSpacer,
                  Text(
                    expense,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.bold,
                      fontSize: 22.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
