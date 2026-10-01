import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/expense_model.dart';
import '../providers/expense_provider.dart';
import '../utils/formatters.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  ExpenseCategory _category = ExpenseCategory.makanan;
  DateTime _date = DateTime.now();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    await context.read<ExpenseProvider>().addExpense(
          amount: double.parse(_amountController.text.replaceAll(',', '.')),
          category: _category,
          date: _date,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        );

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Pengeluaran')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Jumlah',
                prefixIcon: Icon(Icons.payments_outlined),
                prefixText: 'Rp ',
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Wajib diisi';
                final n = double.tryParse(v.replaceAll(',', '.'));
                if (n == null || n <= 0) return 'Jumlah tidak valid';
                return null;
              },
            ),
            const SizedBox(height: 16),
            Text('Kategori', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ExpenseCategory.values.map((c) {
                return ChoiceChip(
                  label: Text(c.label),
                  selected: _category == c,
                  onSelected: (_) => setState(() => _category = c),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_outlined),
              title: const Text('Tanggal'),
              subtitle: Text(formatDate(_date)),
              trailing: TextButton(
                onPressed: _pickDate,
                child: const Text('Ubah'),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Catatan (opsional)',
                prefixIcon: Icon(Icons.notes_outlined),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _isSubmitting ? null : _submit,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
