import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/spending_service.dart';

class SetGoalDialog extends StatefulWidget {
  const SetGoalDialog({super.key});

  @override
  State<SetGoalDialog> createState() => _SetGoalDialogState();
}

class _SetGoalDialogState extends State<SetGoalDialog> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = context.read<SpendingService>().monthlyGoal.toString();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Set Monthly Savings Goal'),
      content: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          prefixText: '\$',
          hintText: 'Enter target amount',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final amount = double.tryParse(_controller.text);
            if (amount != null && amount > 0) {
              context.read<SpendingService>().setMonthlyGoal(amount);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
