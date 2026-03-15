import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/reports_controller.dart';
import '../../../../core/constants/app_constants.dart';

class MonthlyTrendChart extends StatelessWidget {
  const MonthlyTrendChart({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ReportsController>();
    final theme = Theme.of(context);

    return Obx(() {
      final trends = controller.monthlyTrends;
      if (trends.isEmpty) return const SizedBox.shrink();

      return SizedBox(
        height: 250,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: _getMaxY(trends),
            barTouchData: BarTouchData(enabled: true),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() >= 0 && value.toInt() < trends.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          trends[value.toInt()].monthName,
                          style: theme.textTheme.bodySmall,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            barGroups: trends.asMap().entries.map((entry) {
              final index = entry.key;
              final trend = entry.value;
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: trend.income,
                    color: AppColors.incomeGreen,
                    width: 12,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  BarChartRodData(
                    toY: trend.expense,
                    color: AppColors.expenseRed,
                    width: 12,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              );
            }).toList(),
          ),
          swapAnimationDuration: const Duration(milliseconds: 600),
          swapAnimationCurve: Curves.linear,
        ),
      );
    });
  }

  double _getMaxY(List<MonthlyTrend> trends) {
    double max = 0;
    for (var trend in trends) {
      if (trend.income > max) max = trend.income;
      if (trend.expense > max) max = trend.expense;
    }
    return max * 1.2; // Add 20% buffer
  }
}
