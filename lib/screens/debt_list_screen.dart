import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/debt_model.dart';
import '../providers/debt_provider.dart';
import '../widgets/debt_card.dart';
import '../widgets/empty_state.dart';
import 'add_edit_debt_screen.dart';
import 'debt_detail_screen.dart';

class DebtListScreen extends StatefulWidget {
  const DebtListScreen({super.key});

  @override
  State<DebtListScreen> createState() => _DebtListScreenState();
}

class _DebtListScreenState extends State<DebtListScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final debtProvider = context.watch<DebtProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hutang & Piutang'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Hutang Saya'),
            Tab(text: 'Piutang'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _DebtListView(list: debtProvider.hutangList),
          _DebtListView(list: debtProvider.piutangList),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final type =
              _tabController.index == 0 ? DebtType.hutang : DebtType.piutang;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddEditDebtScreen(initialType: type),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
    );
  }
}

class _DebtListView extends StatelessWidget {
  final List<DebtModel> list;

  const _DebtListView({required this.list});

  @override
  Widget build(BuildContext context) {
    if (list.isEmpty) {
      return const EmptyState(
        icon: Icons.receipt_long_outlined,
        message: 'Belum ada data. Ketuk tombol Tambah untuk mencatat.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
      itemCount: list.length,
      itemBuilder: (context, i) {
        final debt = list[i];
        return DebtCard(
          debt: debt,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DebtDetailScreen(debt: debt)),
          ),
        );
      },
    );
  }
}
