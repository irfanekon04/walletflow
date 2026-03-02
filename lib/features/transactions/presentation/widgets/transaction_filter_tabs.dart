import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/responsive.dart';
import '../../data/models/transaction_model.dart';

class TransactionFilterTabs extends StatelessWidget {
  final TransactionType? selectedType;
  final Function(TransactionType?) onTypeSelected;

  const TransactionFilterTabs({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = context.screenWidth;
    
    final isCompact = screenWidth < 360;
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(
        horizontal: context.responsivePadding,
        vertical: AppDimensions.paddingS,
      ),
      child: Row(
        children: [
          _buildChip(
            context: context,
            label: 'All',
            isSelected: selectedType == null,
            onSelected: () => onTypeSelected(null),
            colorScheme: colorScheme,
            isCompact: isCompact,
          ),
          SizedBox(width: isCompact ? 6 : 8),
          _buildChip(
            context: context,
            label: AppStrings.income,
            isSelected: selectedType == TransactionType.income,
            onSelected: () => onTypeSelected(TransactionType.income),
            colorScheme: colorScheme,
            color: AppColors.incomeGreen,
            isCompact: isCompact,
          ),
          SizedBox(width: isCompact ? 6 : 8),
          _buildChip(
            context: context,
            label: AppStrings.expense,
            isSelected: selectedType == TransactionType.expense,
            onSelected: () => onTypeSelected(TransactionType.expense),
            colorScheme: colorScheme,
            color: AppColors.expenseRed,
            isCompact: isCompact,
          ),
          SizedBox(width: isCompact ? 6 : 8),
          _buildChip(
            context: context,
            label: AppStrings.transfer,
            isSelected: selectedType == TransactionType.transfer,
            onSelected: () => onTypeSelected(TransactionType.transfer),
            colorScheme: colorScheme,
            color: colorScheme.tertiary,
            isCompact: isCompact,
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
    required ColorScheme colorScheme,
    Color? color,
    required bool isCompact,
  }) {
    final chipColor = color ?? colorScheme.primary;
    
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: isCompact ? 12 : 14,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected ? Colors.white : chipColor,
        ),
      ),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      selectedColor: chipColor,
      backgroundColor: chipColor.withValues(alpha: 0.1),
      checkmarkColor: Colors.white,
      showCheckmark: false,
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 12,
        vertical: isCompact ? 4 : 8,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        side: BorderSide(
          color: isSelected ? chipColor : chipColor.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}
