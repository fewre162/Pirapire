import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/struct/dailySpendingLimitHelper.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Tarjeta visual para el Home Page o Budget Page que muestra en tiempo real
/// cuánto se puede gastar en el día de hoy según el ritmo de gasto acumulado.
class DailyAllowanceCard extends StatelessWidget {
  final DailySpendingAllowance allowance;
  final VoidCallback? onTap;

  const DailyAllowanceCard({
    Key? key,
    required this.allowance,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final allWallets = Provider.of<AllWallets>(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final double dailyRatio = allowance.dailyAllowance > 0
        ? (allowance.todaySpent / allowance.dailyAllowance).clamp(0.0, 1.0)
        : 1.0;

    Color statusColor = colorScheme.primary;
    if (allowance.isOverBudget) {
      statusColor = colorScheme.error;
    } else if (allowance.isOverDailyAllowance) {
      statusColor = Colors.orangeAccent;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.55),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: statusColor.withOpacity(0.35),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.today_rounded,
                    size: 20,
                    color: statusColor,
                  ),
                  const SizedBox(width: 8),
                  TextFont(
                    text: "Podés gastar hoy",
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextFont(
                  text: "${allowance.daysRemainingInPeriod} días restantes",
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  textColor: statusColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFont(
            text: convertToMoney(allWallets, allowance.remainingForToday),
            fontSize: 32,
            fontWeight: FontWeight.bold,
            textColor: allowance.isOverDailyAllowance
                ? Colors.orangeAccent
                : colorScheme.onSurface,
          ),
          const SizedBox(height: 6),
          TextFont(
            text: allowance.isOverBudget
                ? "Presupuesto mensual agotado"
                : "Límite diario proyectado: ${convertToMoney(allWallets, allowance.dailyAllowance)} | Gastado hoy: ${convertToMoney(allWallets, allowance.todaySpent)}",
            fontSize: 13,
            textColor: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: dailyRatio,
              minHeight: 8,
              backgroundColor: colorScheme.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ),
        ],
      ),
    );
  }
}
