import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/spending_service.dart';
import 'package:intl/intl.dart';

class SpendingInsights extends StatelessWidget {
  const SpendingInsights({super.key});

  @override
  Widget build(BuildContext context) {
    final spendingService = context.watch<SpendingService>();
    final transactions = spendingService.transactions;
    final categoryTotals = spendingService.categoryTotals;
    final formatter = NumberFormat.currency(symbol: '\$');

    if (transactions.isEmpty) {
      return const SizedBox.shrink();
    }

    // Calculate insights
    final totalSpent =
        categoryTotals.values.fold(0.0, (sum, amount) => sum + amount);
    final avgPerDay = totalSpent / 30; // Assuming monthly view
    final topCategory =
        categoryTotals.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    final savingsRate = (categoryTotals['Savings'] ?? 0.0) / totalSpent * 100;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monthly Insights',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _buildInsightCard(
            context,
            'Total Spent',
            formatter.format(totalSpent),
            Icons.account_balance_wallet,
          ),
          _buildInsightCard(
            context,
            'Daily Average',
            formatter.format(avgPerDay),
            Icons.calendar_today,
          ),
          _buildInsightCard(
            context,
            'Top Category',
            topCategory,
            Icons.category,
          ),
          _buildInsightCard(
            context,
            'Savings Rate',
            '${savingsRate.toStringAsFixed(1)}%',
            Icons.savings,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        trailing: Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
      ),
    );
  }
}
