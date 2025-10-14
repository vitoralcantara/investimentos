// lib/twr_calculator.dart

import 'models.dart';

class TWRCalculator {
  /// Calcula o TWR para um único mês.
  ///
  /// [initialValue] - O valor do fundo no início do mês (ou fim do mês anterior).
  /// [finalValue] - O valor do fundo no fim do mês.
  /// [transactions] - Uma lista de transações que ocorreram APENAS durante esse mês.
  static double calculateMonthlyTWR(
    double initialValue,
    double finalValue,
    List<Transaction> transactions,
  ) {
    // Ordena as transações por data para garantir a ordem correta dos cálculos.
    transactions.sort((a, b) => a.date.compareTo(b.date));

    // Uma forma mais simples e comum de calcular o TWR mensal é:
    // TWR = [ (MV1 - CF) / MV0 ] - 1
    // Onde:
    // MV1 = Valor de Mercado no Fim do Período (finalValue)
    // MV0 = Valor de Mercado no Início do Período (initialValue)
    // CF = Fluxo de Caixa Líquido (Aportes - Resgates)

    double netCashFlow = transactions.fold(0.0, (sum, tx) {
      return sum + (tx.type == TransactionType.aporte ? tx.amount : -tx.amount);
    });

    if (initialValue == 0 && netCashFlow == 0) {
      return 0.0; // Sem investimento ou movimentação.
    }
    
    // Fórmula de Dietz Modificada (aproximação comum para TWR quando não temos valores diários)
    // Para simplificar, vamos usar a fórmula mais básica que assume que os fluxos ocorrem no meio do período.
    // Uma fórmula ainda mais simples é (Final / (Inicial + Fluxo)), mas ela assume que o fluxo ocorre no início.
    // Vamos usar a fórmula de Dietz Simples:
    // Retorno = (ValorFinal - ValorInicial - FluxoCaixa) / (ValorInicial + (FluxoCaixa * 0.5))
    // Esta é uma boa aproximação.

    double denominator = initialValue + (netCashFlow * 0.5);
    if (denominator == 0) {
        // Se o denominador for zero, o retorno é indefinido, mas podemos tratar como 100% se o valor final for > 0
        return (finalValue > 0 && netCashFlow > 0) ? (finalValue / netCashFlow) - 1 : 0.0;
    }

    double monthlyReturn = (finalValue - initialValue - netCashFlow) / denominator;

    return monthlyReturn;
  }
}