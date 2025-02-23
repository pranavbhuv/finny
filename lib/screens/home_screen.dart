import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/spending_service.dart';
import '../widgets/savings_chart.dart';
import '../widgets/transaction_list.dart';
import '../widgets/add_transaction_dialog.dart';
import '../widgets/ai_insights_panel.dart';
import 'package:file_picker/file_picker.dart';
import '../widgets/spending_insights.dart';
import '../widgets/analytics_view.dart';
import '../widgets/settings_view.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(
            'MoneyMirror',
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          centerTitle: true,
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(
                Icons.upload_file,
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () => _showImportDialog(context),
            ),
            IconButton(
              icon: Icon(
                Icons.person,
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () {
                // TODO: Implement profile selection
              },
            ),
          ],
          bottom: TabBar(
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor:
                Theme.of(context).colorScheme.onSurfaceVariant,
            indicatorColor: Theme.of(context).colorScheme.primary,
            tabs: const [
              Tab(
                icon: Icon(Icons.insights),
                text: 'Overview',
              ),
              Tab(
                icon: Icon(Icons.trending_up),
                text: 'Analytics',
              ),
              Tab(
                icon: Icon(Icons.account_balance_wallet),
                text: 'Transactions',
              ),
              Tab(
                icon: Icon(Icons.settings),
                text: 'Settings',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildOverviewTab(context),
            _buildAnalyticsTab(context),
            _buildTransactionsTab(context),
            _buildSettingsTab(context),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).colorScheme.primary,
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => const AddTransactionDialog(),
            );
          },
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context) {
    return Consumer<SpendingService>(
      builder: (context, spendingService, child) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.insights,
                          color: Theme.of(context).colorScheme.primary,
                          size: 28,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Financial Insights',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Spending Analysis',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const SavingsChart(),
              const SpendingInsights(),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceVariant
                      .withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const AIInsightsPanel(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnalyticsTab(BuildContext context) {
    return const AnalyticsView();
  }

  Widget _buildTransactionsTab(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: TransactionList(),
    );
  }

  Widget _buildSettingsTab(BuildContext context) {
    return const SettingsView();
  }

  void _showImportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ImportCSVDialog(),
    );
  }
}

class ImportCSVDialog extends StatefulWidget {
  const ImportCSVDialog({super.key});

  @override
  State<ImportCSVDialog> createState() => _ImportCSVDialogState();
}

class _ImportCSVDialogState extends State<ImportCSVDialog> {
  String? _selectedFileName;
  String? _fileContent;
  bool _isLoading = false;

  Future<void> _pickFile() async {
    try {
      setState(() => _isLoading = true);

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        allowMultiple: false,
      );

      if (result != null) {
        final file = result.files.first;
        setState(() {
          _selectedFileName = file.name;
          _fileContent = String.fromCharCodes(file.bytes!);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking file: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _importCsv(BuildContext context) async {
    if (_fileContent == null) return;

    try {
      setState(() => _isLoading = true);
      await context.read<SpendingService>().importFromCsv(_fileContent!);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transactions imported successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error importing CSV: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Import Transactions'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sample CSV Format:',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'Required format:\n'
              'date,amount,category[,description]\n\n'
              'Example:\n'
              '2024-03-01,1500.00,Rent,Monthly rent\n'
              '2024-03-02,200.00,Food\n' // Example without description
              '2024-03-03,50.00,Entertainment,Movie night',
              style: TextStyle(fontFamily: 'monospace'),
            ),
          ),
          const SizedBox(height: 16),
          if (_selectedFileName != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'Selected file: $_selectedFileName',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ElevatedButton(
            onPressed: _isLoading ? null : _pickFile,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_selectedFileName == null
                    ? Icons.upload_file
                    : Icons.change_circle),
                const SizedBox(width: 8),
                Text(_selectedFileName == null ? 'Choose File' : 'Change File'),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isLoading || _fileContent == null
              ? null
              : () => _importCsv(context),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Import'),
        ),
      ],
    );
  }
}
