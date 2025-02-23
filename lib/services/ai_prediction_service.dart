import '../models/transaction.dart';
import 'package:intl/intl.dart';

class AIPredictionService {
  static Map<String, double> predictNextMonthSpending(
      List<Transaction> history) {
    if (history.isEmpty) return {};

    // Group transactions by category
    final categoryTotals = <String, List<double>>{};

    // Calculate monthly totals for each category
    for (var transaction in history) {
      categoryTotals
          .putIfAbsent(transaction.category, () => [])
          .add(transaction.amount);
    }

    // Calculate predictions
    final predictions = <String, double>{};
    for (var entry in categoryTotals.entries) {
      final category = entry.key;
      final amounts = entry.value;

      // Calculate average monthly spending
      final monthlyAverage =
          amounts.fold(0.0, (sum, amount) => sum + amount) / amounts.length;

      // Add trend factor
      final trendFactor = _calculateTrendFactor(amounts);
      final finalPrediction = monthlyAverage * (1 + trendFactor);

      predictions[category] = finalPrediction;
    }

    return predictions;
  }

  static double _calculateTrendFactor(List<double> amounts) {
    if (amounts.length < 2) return 0.0;

    // Calculate the average change between consecutive amounts
    double totalChange = 0;
    for (int i = 1; i < amounts.length; i++) {
      totalChange += (amounts[i] - amounts[i - 1]) / amounts[i - 1];
    }

    // Return a dampened trend factor
    final avgChange = totalChange / (amounts.length - 1);
    return avgChange.clamp(-0.2, 0.2); // Limit extreme predictions
  }

  static List<String> generateInsights(
      List<Transaction> history, Map<String, double> predictions) {
    final insights = <String>[];
    final formatter = NumberFormat.currency(symbol: '\$');

    // Analyze spending velocity
    final now = DateTime.now();
    final thisMonth = history
        .where((t) => t.date.month == now.month && t.date.year == now.year)
        .toList();

    if (thisMonth.isNotEmpty) {
      final spentSoFar = thisMonth.fold(0.0, (sum, t) => sum + t.amount);
      final currentDay = now.day;
      final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
      final projectedTotal = (spentSoFar / currentDay) * daysInMonth;

      insights.add(
          'Based on your current spending pattern, you might spend ${formatter.format(projectedTotal)} this month');
    }

    // Identify categories with significant increases
    for (var entry in predictions.entries) {
      final category = entry.key;
      final predicted = entry.value;
      final currentMonthTotal = thisMonth
          .where((t) => t.category == category)
          .fold(0.0, (sum, t) => sum + t.amount);

      if (predicted > currentMonthTotal * 1.5) {
        insights.add(
            'Your ${category.toLowerCase()} spending might increase next month to ${formatter.format(predicted)}');
      }
    }

    // Add savings-related insights
    final savingsPrediction = predictions['Savings'] ?? 0.0;
    final totalPredicted = predictions.values.fold(0.0, (sum, v) => sum + v);
    if (savingsPrediction < totalPredicted * 0.2) {
      insights.add(
          'Consider increasing your savings to at least ${formatter.format(totalPredicted * 0.2)} next month');
    }

    return insights;
  }
}
