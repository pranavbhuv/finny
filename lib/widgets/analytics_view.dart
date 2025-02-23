import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/spending_service.dart';
import 'analytics/spending_trend_chart.dart';
import 'analytics/category_breakdown_chart.dart';
import 'analytics/spending_goals_chart.dart';

class AnalyticsView extends StatelessWidget {
  const AnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Spending Trends',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          const SpendingTrendChart(),
          const SizedBox(height: 24),
          Text(
            'Category Breakdown',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          const CategoryBreakdownChart(),
          const SizedBox(height: 24),
          Text(
            'Spending Goals',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          const SpendingGoalsChart(),
        ],
      ),
    );
  }
}
