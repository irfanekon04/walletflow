import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/reports_controller.dart';
import '../../../../features/transactions/presentation/controllers/transaction_controller.dart';
import '../../../../core/constants/app_constants.dart';

class CategorySpendingChart extends StatelessWidget {
  const CategorySpendingChart({super.key});

  @override
  Widget build(BuildContext context) {
    final reportsController = Get.find<ReportsController>();
    final txController = Get.find<TransactionController>();
    final theme = Theme.of(context);

    return Obx(() {
      final spendingMap = reportsController.categorySpending;
      if (spendingMap.isEmpty) {
        return const Center(child: Text('No data for this month'));
      }

      final List<PieChartSectionData> sections = [];
      final List<Widget> legends = [];

      spendingMap.forEach((categoryId, amount) {
        final category = txController.categories.firstWhereOrNull((c) => c.id == categoryId);
        final color = category != null ? AppColors.fromHex(category.color) : Colors.grey;
        final name = category?.name ?? 'Other';

        sections.add(PieChartSectionData(
          color: color,
          value: amount,
          title: '${((amount / spendingMap.values.fold(0, (sum, v) => sum + v)) * 100).toStringAsFixed(0)}%',
          radius: 50,
          titleStyle: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ));

        legends.add(_LegendItem(color: color, name: name, amount: amount));
      });

      return Column(
        children: [
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 40,
                sectionsSpace: 2,
              ),
              swapAnimationDuration: const Duration(milliseconds: 800),
              swapAnimationCurve: Curves.easeInOutCirc,
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: legends,
          ),
        ],
      );
    });
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String name;
  final double amount;

  const _LegendItem({
    required this.color,
    required this.name,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          '$name: \$${amount.toStringAsFixed(0)}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
