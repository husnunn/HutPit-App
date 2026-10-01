import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/debt_model.dart';
import '../providers/debt_provider.dart';
import '../providers/expense_provider.dart';
import '../utils/formatters.dart';
import '../widgets/debt_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/summary_card.dart';
import 'debt_detail_screen.dart';
import 'debt_list_screen.dart';
import 'expense_list_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  static const _pages = [
    _DashboardTab(),
    DebtListScreen(),
    ExpenseListScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Ringkasan',
          ),
          NavigationDestination(
            icon: Icon(Icons.swap_vert),
            label: 'Hutang',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Pengeluaran',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Pengaturan',
          ),
        ],
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    final debtProvider = context.watch<DebtProvider>();
    final expenseProvider = context.watch<ExpenseProvider>();

    final upcoming = debtProvider.debts
        .where((d) =>
            d.status != DebtStatus.paidOff &&
            d.category == DebtCategory.oneTime &&
            d.dueDate != null)
        .toList()
      ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));

    return Scaffold(
      appBar: AppBar(title: const Text('Ringkasan')),
      body: RefreshIndicator(
        onRefresh: () async {},
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SummaryGrid(
              children: [
                SummaryCard(
                  title: 'Total Hutang',
                  amount: debtProvider.totalHutangAktif,
                  icon: Icons.arrow_upward,
                  color: Colors.red,
                ),
                SummaryCard(
                  title: 'Total Piutang',
                  amount: debtProvider.totalPiutangAktif,
                  icon: Icons.arrow_downward,
                  color: Colors.green,
                ),
                SummaryCard(
                  title: 'Pengeluaran Bulan Ini',
                  amount: expenseProvider.totalBulanIni,
                  icon: Icons.receipt_long,
                  color: Colors.blueGrey,
                ),
                SummaryCard(
                  title: 'Selisih (Piutang - Hutang)',
                  amount: debtProvider.totalPiutangAktif -
                      debtProvider.totalHutangAktif,
                  icon: Icons.balance,
                  color: Colors.indigo,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Segera Jatuh Tempo',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (upcoming.isEmpty)
              const EmptyState(
                icon: Icons.event_available,
                message: 'Tidak ada hutang/piutang yang akan jatuh tempo.',
              )
            else
              ...upcoming.take(5).map(
                    (d) => DebtCard(
                      debt: d,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DebtDetailScreen(debt: d),
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  final List<Widget> children;

  const _SummaryGrid({required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < children.length; i += 2) ...[
          if (i > 0) const SizedBox(height: 12),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: children[i]),
                const SizedBox(width: 12),
                Expanded(
                  child: i + 1 < children.length
                      ? children[i + 1]
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
