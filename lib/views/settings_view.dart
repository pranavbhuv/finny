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
        Card(
          child: ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Categories'),
            subtitle: const Text('Manage spending categories'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Implement category management
            },
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Backup & Restore'),
            subtitle: const Text('Manage your data'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Implement backup/restore
            },
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            subtitle: const Text('Configure alerts and reminders'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Implement notifications
            },
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.color_lens),
            title: const Text('Theme'),
            subtitle: const Text('Customize app appearance'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Implement theme settings
            },
          ),
        ),
      ],
    );
  }
}
