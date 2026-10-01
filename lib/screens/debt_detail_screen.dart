import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/debt_model.dart';
import '../models/installment_model.dart';
import '../providers/debt_provider.dart';
import '../utils/formatters.dart';
import '../widgets/installment_tile.dart';

class DebtDetailScreen extends StatelessWidget {
  final DebtModel debt;

  const DebtDetailScreen({super.key, required this.debt});

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus catatan?'),
        content: Text(
          'Catatan ${debt.type.label.toLowerCase()} untuk ${debt.personName} akan dihapus permanen.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<DebtProvider>().deleteDebt(debt.id);
      if (context.mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isInstallment = debt.category == DebtCategory.installment;
    final isPaidOff = debt.status == DebtStatus.paidOff;

    return Scaffold(
      appBar: AppBar(
        title: Text(debt.personName),
        actions: [
          IconButton(
            onPressed: () => _confirmDelete(context),
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Chip(label: Text(debt.type.label)),
                      Chip(label: Text(debt.category.label)),
                      Chip(label: Text(debt.status.label)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    formatCurrency(debt.totalAmount),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (debt.personContact != null) ...[
                    const SizedBox(height: 8),
                    Text('Kontak: ${debt.personContact}'),
                  ],
                  if (!isInstallment && debt.dueDate != null) ...[
                    const SizedBox(height: 8),
                    Text('Jatuh tempo: ${formatDate(debt.dueDate!)}'),
                  ],
                  if (debt.notes != null && debt.notes!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text('Catatan: ${debt.notes}'),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (isInstallment) ...[
            Text('Daftar Cicilan', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            StreamBuilder<List<InstallmentModel>>(
              stream: context.read<DebtProvider>().watchInstallments(debt.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final installments = snapshot.data!;
                return Card(
                  child: Column(
                    children: installments
                        .map((inst) => InstallmentTile(
                              installment: inst,
                              onTogglePaid: (paid) => context
                                  .read<DebtProvider>()
                                  .markInstallmentPaid(
                                      debt.id, inst.id, paid),
                            ))
                        .toList(),
                  ),
                );
              },
            ),
          ] else if (!isPaidOff) ...[
            FilledButton.icon(
              onPressed: () =>
                  context.read<DebtProvider>().markDebtPaidOff(debt.id),
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Tandai Lunas'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
