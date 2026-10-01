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
    final liveDebt = context.watch<DebtProvider>().debts.firstWhere(
          (d) => d.id == debt.id,
          orElse: () => debt,
        );
    final isInstallment = liveDebt.category == DebtCategory.installment;
    final isPaidOff = liveDebt.status == DebtStatus.paidOff;

    return Scaffold(
      appBar: AppBar(
        title: Text(liveDebt.personName),
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
                      Chip(label: Text(liveDebt.type.label)),
                      Chip(label: Text(liveDebt.category.label)),
                      isPaidOff
                          ? Chip(
                              avatar: const Icon(Icons.check_circle,
                                  color: Colors.white, size: 18),
                              label: Text(
                                liveDebt.status.label,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              backgroundColor: Colors.green,
                              side: BorderSide.none,
                            )
                          : Chip(label: Text(liveDebt.status.label)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    formatCurrency(liveDebt.totalAmount),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (liveDebt.personContact != null) ...[
                    const SizedBox(height: 8),
                    Text('Kontak: ${liveDebt.personContact}'),
                  ],
                  if (!isInstallment && liveDebt.dueDate != null) ...[
                    const SizedBox(height: 8),
                    Text('Jatuh tempo: ${formatDate(liveDebt.dueDate!)}'),
                  ],
                  if (liveDebt.notes != null && liveDebt.notes!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text('Catatan: ${liveDebt.notes}'),
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
                                    debtId: debt.id,
                                    installmentId: inst.id,
                                    isPaid: paid,
                                    allInstallments: installments,
                                    currentDebtStatus: liveDebt.status,
                                  ),
                            ))
                        .toList(),
                  ),
                );
              },
            ),
          ] else if (!isPaidOff) ...[
            FilledButton.icon(
              onPressed: () =>
                  context.read<DebtProvider>().markDebtPaidOff(liveDebt.id),
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
