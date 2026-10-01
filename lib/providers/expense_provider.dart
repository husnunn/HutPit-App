import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/expense_model.dart';
import '../services/firestore_service.dart';

class ExpenseProvider extends ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();

  String? _uid;
  StreamSubscription<List<ExpenseModel>>? _sub;

  List<ExpenseModel> expenses = [];
  bool isLoading = true;

  void updateUser(String? uid) {
    if (uid == _uid) return;
    _uid = uid;
    _sub?.cancel();
    expenses = [];

    if (uid == null) {
      isLoading = false;
      notifyListeners();
      return;
    }

    isLoading = true;
    notifyListeners();
    _sub = _firestore.watchExpenses(uid).listen((data) {
      expenses = data;
      isLoading = false;
      notifyListeners();
    });
  }

  double get totalBulanIni {
    final now = DateTime.now();
    return expenses
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .fold(0, (sum, e) => sum + e.amount);
  }

  Map<ExpenseCategory, double> get totalPerKategoriBulanIni {
    final now = DateTime.now();
    final result = <ExpenseCategory, double>{};
    for (final e in expenses) {
      if (e.date.year == now.year && e.date.month == now.month) {
        result[e.category] = (result[e.category] ?? 0) + e.amount;
      }
    }
    return result;
  }

  Future<void> addExpense({
    required double amount,
    required ExpenseCategory category,
    required DateTime date,
    String? notes,
  }) async {
    if (_uid == null) return;
    final expense = ExpenseModel(
      id: '',
      amount: amount,
      category: category,
      date: date,
      notes: notes,
      createdAt: DateTime.now(),
    );
    await _firestore.addExpense(_uid!, expense);
  }

  Future<void> deleteExpense(String expenseId) async {
    if (_uid == null) return;
    await _firestore.deleteExpense(_uid!, expenseId);
  }
}
