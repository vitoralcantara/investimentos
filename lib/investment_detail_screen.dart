// lib/investment_detail_screen.dart

import 'package:flutter/material.dart';
import 'models.dart';
import 'twr_calculator.dart';

class InvestmentDetailScreen extends StatelessWidget {
  final InvestmentFund fund;

  const InvestmentDetailScreen({super.key, required this.fund});

  void _calculateAndShowTWR(BuildContext context) {
    // A lógica de cálculo foi movida para cá.
    // Para um app real, você faria um loop ou uma lógica mais robusta
    // para calcular para todos os meses disponíveis.

    // --- CÁLCULO PARA OUTUBRO/2023 ---
    // Tratamento de erro caso não encontre a avaliação
    final initialValueOct = fund.valuations
            .firstWhere((v) => v.date.month == 9 && v.date.year == 2023,
                orElse: () => MonthlyValuation(date: DateTime.now(), value: 0))
            .value;
    final finalValueOct = fund.valuations
        .firstWhere((v) => v.date.month == 10 && v.date.year == 2023)
        .value;
    final transactionsOct = fund.transactions
        .where((t) => t.date.month == 10 && t.date.year == 2023)
        .toList();

    final twrOct = TWRCalculator.calculateMonthlyTWR(
        initialValueOct, finalValueOct, transactionsOct);

    // --- CÁLCULO PARA NOVEMBRO/2023 ---
    final initialValueNov = finalValueOct;
    final finalValueNov = fund.valuations
        .firstWhere((v) => v.date.month == 11 && v.date.year == 2023)
        .value;
    final transactionsNov = fund.transactions
        .where((t) => t.date.month == 11 && t.date.year == 2023)
        .toList();

    final twrNov = TWRCalculator.calculateMonthlyTWR(
        initialValueNov, finalValueNov, transactionsNov);

    // Exibe os resultados
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Rendimento TWR de '${fund.name}'"),
        content: Text(
            "Outubro/2023: ${(twrOct * 100).toStringAsFixed(2)}%\n"
            "Novembro/2023: ${(twrNov * 100).toStringAsFixed(2)}%"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(fund.name),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Detalhes de: ${fund.name}',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // Adicione mais detalhes do fundo aqui se desejar
            // Ex: Lista de transações, gráfico de avaliações, etc.
            ElevatedButton(
              onPressed: () => _calculateAndShowTWR(context),
              child: const Text('Calcular Rendimento Mensal (TWR)'),
            ),
          ],
        ),
      ),
    );
  }
}