import 'package:flutter/material.dart';

import '../models/installment_model.dart';
import '../utils/formatters.dart';

class InstallmentTile extends StatelessWidget {
  final InstallmentModel installment;
  final ValueChanged<bool> onTogglePaid;

  const InstallmentTile({
    super.key,
    required this.installment,
    required this.onTogglePaid,
  });

  @override
  Widget build(BuildContext context) {
    final sisaHari = daysUntil(installment.dueDate);
    final isLate = !installment.isPaid && sisaHari < 0;
    final isPaidEarly = installment.isPaid &&
        installment.paidAt != null &&
        DateTime(
          installment.paidAt!.year,
          installment.paidAt!.month,
          installment.paidAt!.day,
        ).isBefore(DateTime(
          installment.dueDate.year,
          installment.dueDate.month,
          installment.dueDate.day,
        ));

    return CheckboxListTile(
      value: installment.isPaid,
      onChanged: (v) => onTogglePaid(v ?? false),
      controlAffinity: ListTileControlAffinity.leading,
      title: Text('Cicilan ke-${installment.installmentNumber}'),
      subtitle: installment.isPaid
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    'Lunas pada ${installment.paidAt != null ? formatDate(installment.paidAt!) : '-'}',
                  ),
                ),
                if (isPaidEarly) ...[
                  const SizedBox(width: 6),
                  Tooltip(
                    message: 'Dibayar lebih awal',
                    child: Icon(Icons.bolt,
                        size: 16, color: Colors.green.shade600),
                  ),
                ],
              ],
            )
          : Text(
              'Jatuh tempo ${formatDate(installment.dueDate)}'
              '${isLate ? ' (terlambat ${-sisaHari} hari)' : ''}',
              style: TextStyle(
                color: isLate ? Theme.of(context).colorScheme.error : null,
              ),
            ),
      secondary: Text(
        formatCurrency(installment.amount),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
