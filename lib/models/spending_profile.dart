class SpendingProfile {
  final String name;
  final Map<String, double> monthlySpending;

  SpendingProfile({
    required this.name,
    required this.monthlySpending,
  });

  factory SpendingProfile.fromCsv(List<String> row) {
    return SpendingProfile(
      name: row[0],
      monthlySpending: {
        'rent': double.parse(row[1]),
        'food': double.parse(row[2]),
        'entertainment': double.parse(row[3]),
        'subscriptions': double.parse(row[4]),
        'savings': double.parse(row[5]),
        'debt_payments': double.parse(row[6]),
        'travel': double.parse(row[7]),
      },
    );
  }
}
