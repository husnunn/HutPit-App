import 'package:flutter/material.dart';

import '../models/debt_model.dart';
import '../utils/formatters.dart';

class DebtCard extends StatelessWidget {
  final DebtModel debt;
  final VoidCallback onTap;

  const DebtCard({super.key, required this.debt, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isPaidOff = debt.status == DebtStatus.paidOff;
    final isInstallment = debt.category == DebtCategory.installment;

    String? subtitleDate;
    Color? dueColor;
    if (!isInstallment && debt.dueDate != null && !isPaidOff) {
      final sisaHari = daysUntil(debt.dueDate!);
      if (sisaHari < 0) {
        subtitleDate = 'Terlambat ${-sisaHari} hari';
        dueColor = Theme.of(context).colorScheme.error;
      } else if (sisaHari == 0) {
        subtitleDate = 'Jatuh tempo hari ini';
        dueColor = Theme.of(context).colorScheme.error;
      } else {
        subtitleDate = 'Jatuh tempo ${formatDate(debt.dueDate!)} ($sisaHari hari lagi)';
        dueColor = sisaHari <= 3 ? Colors.orange : null;
      }
    }

    return Card(
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: debt.type == DebtType.hutang
              ? Colors.red.withValues(alpha: 0.15)
              : Colors.green.withValues(alpha: 0.15),
          child: Icon(
            debt.type == DebtType.hutang
                ? Icons.arrow_upward
                : Icons.arrow_downward,
            color: debt.type == DebtType.hutang ? Colors.red : Colors.green,
          ),
        ),
        title: Text(
          debt.personName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          isPaidOff
              ? 'Lunas'
              : isInstallment
                  ? 'Cicilan ${debt.installmentCount ?? '-'}x'
                  : subtitleDate ?? debt.category.label,
          style: TextStyle(color: dueColor),
        ),
        trailing: Text(
          formatCurrency(debt.totalAmount),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isPaidOff
                ? Theme.of(context).colorScheme.outline
                : debt.type == DebtType.hutang
                    ? Colors.red
                    : Colors.green,
          ),
        ),
      ),
    );
  }
}
