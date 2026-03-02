import 'package:flutter/material.dart';

class AmountField extends StatelessWidget {
  const AmountField({
    super.key,
    required TextEditingController amountController,
    required this.theme,
  }) : _amountController = amountController;

  final TextEditingController _amountController;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _amountController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: theme.textTheme.headlineMedium,
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        labelText: 'Amount',
        prefixText: '\$ ',
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.3,
        ),
      ),
    );
  }
}
