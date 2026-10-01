import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/debt_model.dart';
import '../providers/debt_provider.dart';
import '../utils/formatters.dart';

class AddEditDebtScreen extends StatefulWidget {
  final DebtType initialType;

  const AddEditDebtScreen({super.key, required this.initialType});

  @override
  State<AddEditDebtScreen> createState() => _AddEditDebtScreenState();
}

class _AddEditDebtScreenState extends State<AddEditDebtScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _amountController = TextEditingController();
  final _installmentCountController = TextEditingController(text: '2');
  final _notesController = TextEditingController();

  late DebtType _type;
  DebtCategory _category = DebtCategory.oneTime;
  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _amountController.dispose();
    _installmentCountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final provider = context.read<DebtProvider>();
    final amount = double.parse(_amountController.text.replaceAll(',', '.'));

    try {
      if (_category == DebtCategory.oneTime) {
        await provider.addOneTimeDebt(
          personName: _nameController.text.trim(),
          personContact: _contactController.text.trim().isEmpty
              ? null
              : _contactController.text.trim(),
          type: _type,
          amount: amount,
          dueDate: _dueDate,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        );
      } else {
        await provider.addInstallmentDebt(
          personName: _nameController.text.trim(),
          personContact: _contactController.text.trim().isEmpty
              ? null
              : _contactController.text.trim(),
          type: _type,
          totalAmount: amount,
          installmentCount: int.parse(_installmentCountController.text),
          firstDueDate: _dueDate,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        );
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Catatan')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SegmentedButton<DebtType>(
              segments: const [
                ButtonSegment(
                  value: DebtType.hutang,
                  label: Text('Hutang Saya'),
                  icon: Icon(Icons.arrow_upward),
                ),
                ButtonSegment(
                  value: DebtType.piutang,
                  label: Text('Piutang'),
                  icon: Icon(Icons.arrow_downward),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (s) => setState(() => _type = s.first),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama orang',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _contactController,
              decoration: const InputDecoration(
                labelText: 'Kontak (opsional)',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Jumlah total',
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
            Text('Kategori Pembayaran',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            SegmentedButton<DebtCategory>(
              segments: const [
                ButtonSegment(
                  value: DebtCategory.oneTime,
                  label: Text('Sekali Bayar'),
                ),
                ButtonSegment(
                  value: DebtCategory.installment,
                  label: Text('Cicilan'),
                ),
              ],
              selected: {_category},
              onSelectionChanged: (s) => setState(() => _category = s.first),
            ),
            const SizedBox(height: 12),
            if (_category == DebtCategory.installment)
              TextFormField(
                controller: _installmentCountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Jumlah cicilan (kali)',
                  prefixIcon: Icon(Icons.calendar_view_month),
                ),
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null || n < 1) return 'Minimal 1 kali';
                  return null;
                },
              ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_outlined),
              title: Text(
                _category == DebtCategory.oneTime
                    ? 'Tanggal jatuh tempo'
                    : 'Tanggal jatuh tempo cicilan pertama',
              ),
              subtitle: Text(formatDate(_dueDate)),
              trailing: TextButton(
                onPressed: _pickDueDate,
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
