import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../services/spending_service.dart';

class SavingsChart extends StatefulWidget {
  const SavingsChart({super.key});

  @override
  State<SavingsChart> createState() => _SavingsChartState();
}

class _SavingsChartState extends State<SavingsChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final spendingService = context.watch<SpendingService>();
    final categoryTotals = spendingService.categoryTotals;
    final total =
        categoryTotals.values.fold(0.0, (sum, amount) => sum + amount);

    // Show placeholder if no data
    if (categoryTotals.isEmpty) {
      return Container(
        height: 400,
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'No Spending Data',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Import transactions or add them manually',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                ),
                const SizedBox(height: 24),
                Icon(
                  Icons.pie_chart_outline,
                  size: 64,
                  color: Colors.grey.shade300,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final sections = categoryTotals.entries.map((entry) {
      final isTouched =
          categoryTotals.keys.toList().indexOf(entry.key) == touchedIndex;
      final fontSize = isTouched ? 20.0 : 16.0;
      final radius = isTouched ? 110.0 : 100.0;
      final percentage = total > 0 ? (entry.value / total * 100) : 0.0;

      return PieChartSectionData(
        color: _getCategoryColor(entry.key),
        value: entry.value,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: const [Shadow(color: Colors.black, blurRadius: 2)],
        ),
      );
    }).toList();

    return Container(
      height: 400,
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                'Spending Distribution',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Total: \$${total.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Row(
                  children: [
                    if (sections.isNotEmpty)
                      Expanded(
                        flex: 2,
                        child: PieChart(
                          PieChartData(
                            pieTouchData: PieTouchData(
                              touchCallback:
                                  (FlTouchEvent event, pieTouchResponse) {
                                setState(() {
                                  if (!event.isInterestedForInteractions ||
                                      pieTouchResponse == null ||
                                      pieTouchResponse.touchedSection == null) {
                                    touchedIndex = -1;
                                    return;
                                  }
                                  touchedIndex = pieTouchResponse
                                      .touchedSection!.touchedSectionIndex;
                                });
                              },
                            ),
                            borderData: FlBorderData(show: false),
                            sectionsSpace: 2,
                            centerSpaceRadius: 0,
                            sections: sections,
                          ),
                        ),
                      ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: categoryTotals.entries.map((entry) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: _getCategoryColor(entry.key),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      entry.key,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: touchedIndex ==
                                                categoryTotals.keys
                                                    .toList()
                                                    .indexOf(entry.key)
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                            : Colors.black87,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '\$${entry.value.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (spendingService.monthlyGoal > 0) ...[
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: spendingService.totalSavings /
                      spendingService.monthlyGoal,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                  minHeight: 8,
                ),
                const SizedBox(height: 8),
                Text(
                  'Savings Goal Progress: ${((spendingService.totalSavings / spendingService.monthlyGoal) * 100).toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
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
