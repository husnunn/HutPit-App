import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/expense_model.dart';
import '../providers/expense_provider.dart';
import '../utils/formatters.dart';
import '../widgets/empty_state.dart';
import 'add_expense_screen.dart';

class ExpenseListScreen extends StatelessWidget {
  const ExpenseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final expenses = provider.expenses;

    return Scaffold(
      appBar: AppBar(title: const Text('Pengeluaran')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total bulan ini'),
                    Text(
                      formatCurrency(provider.totalBulanIni),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: expenses.isEmpty
                ? const EmptyState(
                    icon: Icons.receipt_long_outlined,
                    message: 'Belum ada pengeluaran tercatat.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 88),
                    itemCount: expenses.length,
                    itemBuilder: (context, i) {
                      final ExpenseModel e = expenses[i];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(e.category.label.substring(0, 1)),
                          ),
                          title: Text(e.category.label),
                          subtitle: Text(
                            '${formatDate(e.date)}'
                            '${e.notes != null && e.notes!.isNotEmpty ? ' - ${e.notes}' : ''}',
                          ),
                          trailing: Text(
                            formatCurrency(e.amount),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onLongPress: () => _confirmDelete(context, e),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, ExpenseModel e) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus pengeluaran?'),
        content: Text('${e.category.label} - ${formatCurrency(e.amount)}'),
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
      await context.read<ExpenseProvider>().deleteExpense(e.id);
    }
  }
}
