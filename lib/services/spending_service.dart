import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction.dart';
import '../models/spending_profile.dart';

class SpendingService extends ChangeNotifier {
  final Box<Transaction> _transactionBox;
  final Box<double> _settingsBox;
  double _monthlyGoal = 1000.0;
  SpendingProfile? _selectedProfile;

  SpendingService(this._transactionBox, this._settingsBox) {
    _monthlyGoal =
        _settingsBox.get('monthlyGoal', defaultValue: 1000.0) ?? 1000.0;
  }

  List<Transaction> get transactions {
    final allTransactions = _transactionBox.values.toList();
    allTransactions.sort((a, b) => b.date.compareTo(a.date));
    return allTransactions;
  }

  double get monthlyGoal => _monthlyGoal;
  SpendingProfile? get selectedProfile => _selectedProfile;

  Future<void> addTransaction(Transaction transaction) async {
    await _transactionBox.add(transaction);
    notifyListeners();
  }

  Future<void> deleteTransaction(Transaction transaction) async {
    await transaction.delete();
    notifyListeners();
  }

  Future<void> setMonthlyGoal(double goal) async {
    _monthlyGoal = goal;
    await _settingsBox.put('monthlyGoal', goal);
    notifyListeners();
  }

  void setSpendingProfile(SpendingProfile profile) {
    _selectedProfile = profile;
    notifyListeners();
  }

  double get totalSavings {
    return transactions
        .where((t) => t.category == 'Savings')
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  Map<String, double> get categoryTotals {
    final totals = <String, double>{};
    for (final transaction in transactions) {
      totals[transaction.category] =
          (totals[transaction.category] ?? 0.0) + transaction.amount;
    }
    return totals;
  }

  Future<void> importFromCsv(String csvContent) async {
    try {
      // Split content into lines and parse manually
      final lines = csvContent.split('\n');
      final List<List<String>> rows = lines
          .where((line) => line.trim().isNotEmpty)
          .map((line) => line.split(',').map((cell) => cell.trim()).toList())
          .toList();

      if (rows.isEmpty) {
        throw Exception('CSV file is empty');
      }

      // Verify header row
      final headers =
          rows.first.map((e) => e.toString().toLowerCase().trim()).toList();
      final requiredHeaders = ['date', 'amount', 'category'];
      final missingHeaders = requiredHeaders.where((h) => !headers.contains(h));

      if (missingHeaders.isNotEmpty) {
        throw Exception(
            'Missing required columns: ${missingHeaders.join(", ")}\n\n'
            'Required format:\n'
            'date,amount,category[,description]');
      }

      // Get column indices
      final dateIndex = headers.indexOf('date');
      final amountIndex = headers.indexOf('amount');
      final categoryIndex = headers.indexOf('category');
      final descIndex = headers.indexOf('description');

      // Clear existing transactions
      await _transactionBox.clear();

      // Process data rows (skip header)
      for (var i = 1; i < rows.length; i++) {
        final row = rows[i];
        try {
          // Skip empty rows
          if (row.isEmpty || row.every((cell) => cell.trim().isEmpty)) {
            continue;
          }

          // Ensure row has enough columns
          if (row.length <= categoryIndex) {
            continue;
          }

          final dateStr = row[dateIndex];
          final amountStr = row[amountIndex].replaceAll(RegExp(r'[^\d.]'),
              ''); // Remove non-numeric characters except decimal
          final category = row[categoryIndex];
          final description =
              descIndex >= 0 && descIndex < row.length ? row[descIndex] : '';

          final transaction = Transaction(
            date: DateTime.parse(dateStr),
            amount: double.parse(amountStr),
            category: category,
            description: description,
          );

          await _transactionBox.add(transaction);
        } catch (e) {
          // Continue processing other rows instead of throwing
          continue;
        }
      }

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
