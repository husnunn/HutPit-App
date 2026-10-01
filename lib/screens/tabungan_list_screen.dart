import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/tabungan_model.dart';
import '../providers/tabungan_provider.dart';
import '../utils/formatters.dart';
import '../widgets/empty_state.dart';
import 'add_tabungan_screen.dart';

class TabunganListScreen extends StatelessWidget {
  const TabunganListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TabunganProvider>();
    final items = provider.tabunganList;

    return Scaffold(
      appBar: AppBar(title: const Text('Tabungan')),
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
                    const Text('Saldo Tabungan'),
                    Text(
                      formatCurrency(provider.saldoTabungan),
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
            child: items.isEmpty
                ? const EmptyState(
                    icon: Icons.savings_outlined,
                    message: 'Belum ada catatan tabungan.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 88),
                    itemCount: items.length,
                    itemBuilder: (context, i) {
                      final TabunganModel t = items[i];
                      final isSetor = t.type == TabunganType.setor;
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isSetor
                                ? Colors.green.withValues(alpha: 0.15)
                                : Colors.red.withValues(alpha: 0.15),
                            child: Icon(
                              isSetor
                                  ? Icons.arrow_downward
                                  : Icons.arrow_upward,
                              color: isSetor ? Colors.green : Colors.red,
                            ),
                          ),
                          title: Text(t.type.label),
                          subtitle: Text(
                            '${formatDate(t.date)}'
                            '${t.notes != null && t.notes!.isNotEmpty ? ' - ${t.notes}' : ''}',
                          ),
                          trailing: Text(
                            '${isSetor ? '+' : '-'}${formatCurrency(t.amount)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isSetor ? Colors.green : Colors.red,
                            ),
                          ),
                          onLongPress: () => _confirmDelete(context, t),
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
          MaterialPageRoute(builder: (_) => const AddTabunganScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, TabunganModel t) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus catatan tabungan?'),
        content: Text('${t.type.label} - ${formatCurrency(t.amount)}'),
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
      await context.read<TabunganProvider>().deleteTabungan(t.id);
    }
  }
}
