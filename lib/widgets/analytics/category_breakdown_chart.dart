import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../services/spending_service.dart';

class CategoryBreakdownChart extends StatelessWidget {
  const CategoryBreakdownChart({super.key});

  @override
  Widget build(BuildContext context) {
    final spendingService = context.watch<SpendingService>();
    final categoryTotals = spendingService.categoryTotals;
    final total =
        categoryTotals.values.fold(0.0, (sum, amount) => sum + amount);

    return SizedBox(
      height: 300,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: PieChart(
                  PieChartData(
                    sections: categoryTotals.entries.map((entry) {
                      final percentage =
                          total > 0 ? (entry.value / total * 100) : 0.0;
                      return PieChartSectionData(
                        value: entry.value,
                        title: '${percentage.toStringAsFixed(1)}%',
                        radius: 100,
                        color: _getCategoryColor(entry.key),
                        titleStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    }).toList(),
                    sectionsSpace: 2,
                    centerSpaceRadius: 0,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Categories',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      ...categoryTotals.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: _getCategoryColor(entry.key),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      entry.key,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    Text(
                                      '\$${entry.value.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'savings':
        return Colors.green;
      case 'rent':
        return Colors.blue;
      case 'food':
        return Colors.orange;
      case 'entertainment':
        return Colors.purple;
      case 'subscriptions':
        return Colors.red;
      case 'debt payments':
        return Colors.brown;
      case 'travel':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}
