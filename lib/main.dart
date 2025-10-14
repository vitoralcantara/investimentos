// lib/main.dart

import 'package:flutter/material.dart';
import 'models.dart';
import 'investment_detail_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meus Investimentos',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const InvestmentsScreen(),
    );
  }
}

class InvestmentsScreen extends StatefulWidget {
  const InvestmentsScreen({super.key});

  @override
  State<InvestmentsScreen> createState() => _InvestmentsScreenState();
}

class _InvestmentsScreenState extends State<InvestmentsScreen> {
  // --- DADOS DE EXEMPLO ---
  // Agora temos uma lista de fundos
  late List<InvestmentFund> myFunds;

  @override
  void initState() {
    super.initState();
    // Exemplo com dois fundos
    myFunds = [
      InvestmentFund(
        name: "Fundo Multimercado Exemplo",
        transactions: [
          Transaction(date: DateTime(2023, 10, 5), amount: 1000, type: TransactionType.aporte),
          Transaction(date: DateTime(2023, 10, 20), amount: 500, type: TransactionType.aporte),
          Transaction(date: DateTime(2023, 11, 15), amount: 200, type: TransactionType.resgate),
        ],
        valuations: [
          MonthlyValuation(date: DateTime(2023, 9, 30), value: 0),
          MonthlyValuation(date: DateTime(2023, 10, 31), value: 1550),
          MonthlyValuation(date: DateTime(2023, 11, 30), value: 1380),
        ],
      ),
      InvestmentFund(
        name: "Fundo de Ações Tech",
        transactions: [
          Transaction(date: DateTime(2023, 10, 10), amount: 2000, type: TransactionType.aporte),
        ],
        valuations: [
          MonthlyValuation(date: DateTime(2023, 9, 30), value: 0),
          MonthlyValuation(date: DateTime(2023, 10, 31), value: 2100),
          // Sem dados para novembro neste exemplo
        ],
      ),
    ];
  }

  void _addInvestmentFund() {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Adicionar Novo Fundo'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(hintText: "Nome do Fundo"),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text;
                if (name.isNotEmpty) {
                  setState(() => myFunds.add(InvestmentFund(name: name)));
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Adicionar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minha Carteira'),
      ),
      body: ListView.builder(
        itemCount: myFunds.length,
        itemBuilder: (context, index) {
          final fund = myFunds[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(fund.name),
              subtitle: const Text("Toque para ver detalhes"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InvestmentDetailScreen(fund: fund),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addInvestmentFund,
        tooltip: 'Adicionar Fundo',
        child: const Icon(Icons.add),
      ),
    );
  }
}