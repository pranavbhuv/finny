import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/spending_service.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.savings),
            title: const Text('Monthly Savings Goal'),
            subtitle: const Text('Set your target savings amount'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Implement savings goal setting
            },
          ),
        ),
        // ... rest of the settings items
      ],
    );
  }
}
