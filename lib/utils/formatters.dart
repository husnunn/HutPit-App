import 'package:intl/intl.dart';

final _currencyFormat = NumberFormat.currency(
  locale: 'id_ID',
  symbol: 'Rp ',
  decimalDigits: 0,
);

final _dateFormat = DateFormat('d MMM yyyy', 'id_ID');

String formatCurrency(num amount) => _currencyFormat.format(amount);

String formatDate(DateTime date) => _dateFormat.format(date);

/// Sisa hari sampai [dueDate], bisa negatif jika sudah lewat.
int daysUntil(DateTime dueDate) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
  return due.difference(today).inDays;
}
