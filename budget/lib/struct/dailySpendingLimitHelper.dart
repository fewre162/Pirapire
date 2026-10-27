import 'dart:math';
import 'package:flutter/material.dart';

/// Modelo de cálculo dinámico para el presupuesto diario inteligente.
/// Informa exactamente cuánto se puede gastar hoy según el saldo restante y los días del período.
class DailySpendingAllowance {
  final double budgetTotal;
  final double totalSpentSoFar;
  final double remainingBudget;
  final int totalDaysInPeriod;
  final int daysRemainingInPeriod; // Incluyendo el día de hoy
  final double dailyAllowance; // Límite diario sugerido
  final double todaySpent; // Gasto acumulado en el día de hoy
  final double remainingForToday; // Margen disponible restante para hoy
  final bool isOverBudget; // Si ya se superó el presupuesto total
  final bool isOverDailyAllowance; // Si el gasto de hoy superó la cuota sugerida

  DailySpendingAllowance({
    required this.budgetTotal,
    required this.totalSpentSoFar,
    required this.remainingBudget,
    required this.totalDaysInPeriod,
    required this.daysRemainingInPeriod,
    required this.dailyAllowance,
    required this.todaySpent,
    required this.remainingForToday,
    required this.isOverBudget,
    required this.isOverDailyAllowance,
  });

  factory DailySpendingAllowance.calculate({
    required double budgetTotal,
    required double totalSpentSoFar,
    required DateTimeRange periodRange,
    required double todaySpent,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final periodStart = DateTime(periodRange.start.year, periodRange.start.month, periodRange.start.day);
    final periodEnd = DateTime(periodRange.end.year, periodRange.end.month, periodRange.end.day);

    final totalDays = max(1, periodEnd.difference(periodStart).inDays + 1);

    int remainingDays = 0;
    if (today.isBefore(periodStart)) {
      remainingDays = totalDays;
    } else if (today.isAfter(periodEnd)) {
      remainingDays = 1;
    } else {
      remainingDays = max(1, periodEnd.difference(today).inDays + 1);
    }

    final remainingBudget = budgetTotal - totalSpentSoFar;
    final isOverBudget = remainingBudget <= 0;

    // Límite diario sugerido a partir de hoy
    final dailyAllowance = isOverBudget ? 0.0 : (remainingBudget / remainingDays);
    final remainingForToday = max(0.0, dailyAllowance - todaySpent);
    final isOverDailyAllowance = todaySpent > dailyAllowance && dailyAllowance > 0;

    return DailySpendingAllowance(
      budgetTotal: budgetTotal,
      totalSpentSoFar: totalSpentSoFar,
      remainingBudget: remainingBudget,
      totalDaysInPeriod: totalDays,
      daysRemainingInPeriod: remainingDays,
      dailyAllowance: dailyAllowance,
      todaySpent: todaySpent,
      remainingForToday: remainingForToday,
      isOverBudget: isOverBudget,
      isOverDailyAllowance: isOverDailyAllowance,
    );
  }
}
