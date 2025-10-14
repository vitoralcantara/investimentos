// lib/models.dart

enum TransactionType {
  aporte, // Deposit
  resgate, // Withdrawal
}

class Transaction {
  final DateTime date;
  final double amount;
  final TransactionType type;
  
  Transaction({
    required this.date,
    required this.amount,
    required this.type,
  });

  // Método para converter a instância para um Map (JSON)
  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'amount': amount,
        'type': type.toString(),
      };

  // Factory constructor para criar uma instância a partir de um Map (JSON)
  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        date: DateTime.parse(json['date']),
        amount: json['amount'],
        type: TransactionType.values.firstWhere((e) => e.toString() == json['type']),
      );
}

class MonthlyValuation {
  final DateTime date; // Ex: 2023-10-31 (último dia do mês)
  final double value;  // Valor total da carteira no fim do mês
  
  MonthlyValuation({required this.date, required this.value});

  // Método para converter a instância para um Map (JSON)
  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'value': value,
      };

  // Factory constructor para criar uma instância a partir de um Map (JSON)
  factory MonthlyValuation.fromJson(Map<String, dynamic> json) => MonthlyValuation(
        date: DateTime.parse(json['date']),
        value: json['value'],
      );
}

class InvestmentFund {
  final String name;
  final List<Transaction> transactions;
  final List<MonthlyValuation> valuations;
  
  InvestmentFund({
    required this.name,
    this.transactions = const [],
    this.valuations = const [],
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'transactions': transactions.map((tx) => tx.toJson()).toList(),
        'valuations': valuations.map((v) => v.toJson()).toList(),
      };

  factory InvestmentFund.fromJson(Map<String, dynamic> json) => InvestmentFund(
        name: json['name'],
        transactions: (json['transactions'] as List)
            .map((txJson) => Transaction.fromJson(txJson))
            .toList(),
        valuations: (json['valuations'] as List)
            .map((vJson) => MonthlyValuation.fromJson(vJson))
            .toList(),
      );
}