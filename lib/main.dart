import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';
import 'models/transaction.dart';
import 'services/spending_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(TransactionAdapter());
  }

  final transactionBox = await Hive.openBox<Transaction>('transactions');
  final settingsBox = await Hive.openBox<double>('settings');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SpendingService(transactionBox, settingsBox),
        ),
      ],
      child: const MyApp(),
    ),
  );

  // Close Hive boxes when app is closed
  WidgetsBinding.instance.addObserver(
    LifecycleEventHandler(
      detachedCallBack: () async {
        await Hive.close();
      },
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MoneyMirror',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: const HomeScreen(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double _savings = 0.0;
  double _monthlyGoal = 1000.0;
  List<Transaction> _recentTransactions = [];

  void _addTransaction() {
    setState(() {
      // Simulating adding a new savings transaction
      double amount = 100.0; // This would come from user input in a real app
      _savings += amount;
      _recentTransactions.add(
        Transaction(
          amount: amount,
          date: DateTime.now(),
          category: 'Savings',
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    double progressPercentage = (_savings / _monthlyGoal).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monthly Savings Goal',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progressPercentage,
                      minHeight: 10,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${_savings.toStringAsFixed(2)} / \$${_monthlyGoal.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Recent Transactions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _recentTransactions.length,
                itemBuilder: (context, index) {
                  final transaction = _recentTransactions[index];
                  return ListTile(
                    leading: const Icon(Icons.savings),
                    title: Text('\$${transaction.amount.toStringAsFixed(2)}'),
                    subtitle: Text(
                      '${transaction.category} - ${transaction.date.toString().split(' ')[0]}',
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTransaction,
        tooltip: 'Add Transaction',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class LifecycleEventHandler extends WidgetsBindingObserver {
  final Future<void> Function() detachedCallBack;

  LifecycleEventHandler({
    required this.detachedCallBack,
  });

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.detached) {
      await detachedCallBack();
    }
  }
}
