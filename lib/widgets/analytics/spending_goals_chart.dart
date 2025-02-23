import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/spending_service.dart';
import 'package:intl/intl.dart';
import '../set_goal_dialog.dart';

class SpendingGoalsChart extends StatelessWidget {
  const SpendingGoalsChart({super.key});

  @override
  Widget build(BuildContext context) {
    final spendingService = context.watch<SpendingService>();
    final transactions = spendingService.transactions;
    final formatter = NumberFormat.currency(symbol: '\$');
    final monthlyGoal = spendingService.monthlyGoal;
    final totalSpent = transactions.fold(0.0, (sum, t) => sum + t.amount);
    final savingsTotal = transactions
        .where((t) => t.category == 'Savings')
        .fold(0.0, (sum, t) => sum + t.amount);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Goals',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => const SetGoalDialog(),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildGoalProgress(
              context,
              'Monthly Savings',
              savingsTotal,
              monthlyGoal,
              Colors.green,
            ),
            const SizedBox(height: 16),
            _buildGoalProgress(
              context,
              'Total Spending',
              totalSpent,
              monthlyGoal * 5, // Example budget limit
              Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalProgress(BuildContext context, String label, double current,
      double goal, Color color) {
    final progress = (current / goal).clamp(0.0, 1.0);
    final formatter = NumberFormat.currency(symbol: '\$');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.titleMedium),
            Text(
              '${formatter.format(current)} / ${formatter.format(goal)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 4),
        Text(
          '${(progress * 100).toStringAsFixed(1)}%',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
