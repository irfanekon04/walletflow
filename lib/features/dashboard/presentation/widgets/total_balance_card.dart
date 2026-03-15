import 'package:flutter/material.dart';
import 'package:walletflow/core/constants/app_constants.dart';
import 'package:walletflow/core/utils/responsive.dart';

class TotalBalanceCard extends StatelessWidget {
  const TotalBalanceCard({
    super.key,
    required this.balance,
  });

  final String balance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.primaryContainer,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(context.responsivePadding * 1.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.totalBalance,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onPrimaryContainer.withValues(
                  alpha: 0.7,
                ),
                fontSize: 14 * context.responsiveFontSize,
              ),
            ),
            SizedBox(height: context.responsiveHeight(0.01)),
            Text(
              balance,
              style: theme.textTheme.displayLarge?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontSize: 32 * context.responsiveFontSize,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
