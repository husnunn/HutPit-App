import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/debt_model.dart';
import '../models/installment_model.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';

class DebtProvider extends ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();
  final NotificationService _notifications = NotificationService.instance;

  String? _uid;
  StreamSubscription<List<DebtModel>>? _sub;

  List<DebtModel> debts = [];
  bool isLoading = true;

  void updateUser(String? uid) {
    if (uid == _uid) return;
    _uid = uid;
    _sub?.cancel();
    debts = [];

    if (uid == null) {
      isLoading = false;
      notifyListeners();
      return;
    }

    isLoading = true;
    notifyListeners();
    _sub = _firestore.watchDebts(uid).listen((data) {
      debts = data;
      isLoading = false;
      notifyListeners();
    });
  }

  List<DebtModel> get hutangList =>
      debts.where((d) => d.type == DebtType.hutang).toList();

  List<DebtModel> get piutangList =>
      debts.where((d) => d.type == DebtType.piutang).toList();

  double get totalHutangAktif => hutangList
      .where((d) => d.status != DebtStatus.paidOff)
      .fold(0, (sum, d) => sum + d.totalAmount);

  double get totalPiutangAktif => piutangList
      .where((d) => d.status != DebtStatus.paidOff)
      .fold(0, (sum, d) => sum + d.totalAmount);

  /// Tambah hutang/piutang sekali bayar. Notifikasi H-1 & hari-H otomatis
  /// dijadwalkan berdasarkan [dueDate].
  Future<void> addOneTimeDebt({
    required String personName,
    String? personContact,
    required DebtType type,
    required double amount,
    required DateTime dueDate,
    String? notes,
  }) async {
    if (_uid == null) return;
    final debt = DebtModel(
      id: '',
      personName: personName,
      personContact: personContact,
      type: type,
      category: DebtCategory.oneTime,
      totalAmount: amount,
      startDate: DateTime.now(),
      dueDate: dueDate,
      notes: notes,
      createdAt: DateTime.now(),
    );
    final debtId = await _firestore.addDebt(_uid!, debt);

    await _notifications.scheduleDueReminder(
      key: debtId,
      title: type == DebtType.hutang ? 'Hutang jatuh tempo' : 'Piutang jatuh tempo',
      body: '$personName - Rp ${amount.toStringAsFixed(0)}',
      dueDate: dueDate,
    );
  }

  /// Tambah hutang/piutang dengan cicilan. Total dibagi rata ke
  /// [installmentCount] bagian, jatuh tempo tiap tanggal yang sama tiap
  /// bulan mulai dari [firstDueDate]. Notifikasi dijadwalkan untuk tiap cicilan.
  Future<void> addInstallmentDebt({
    required String personName,
    String? personContact,
    required DebtType type,
    required double totalAmount,
    required int installmentCount,
    required DateTime firstDueDate,
    String? notes,
  }) async {
    if (_uid == null || installmentCount < 1) return;

    final debt = DebtModel(
      id: '',
      personName: personName,
      personContact: personContact,
      type: type,
      category: DebtCategory.installment,
      totalAmount: totalAmount,
      startDate: DateTime.now(),
      installmentCount: installmentCount,
      notes: notes,
      createdAt: DateTime.now(),
    );
    final debtId = await _firestore.addDebt(_uid!, debt);

    final perInstallment =
        double.parse((totalAmount / installmentCount).toStringAsFixed(2));
    final installments = <InstallmentModel>[];
    for (var i = 0; i < installmentCount; i++) {
      final dueDate = DateTime(
        firstDueDate.year,
        firstDueDate.month + i,
        firstDueDate.day,
      );
      installments.add(InstallmentModel(
        id: const Uuid().v4(),
        debtId: debtId,
        installmentNumber: i + 1,
        amount: perInstallment,
        dueDate: dueDate,
      ));
    }
    await _firestore.addInstallments(_uid!, debtId, installments);

    for (final inst in installments) {
      await _notifications.scheduleDueReminder(
        key: '$debtId-${inst.installmentNumber}',
        title: type == DebtType.hutang
            ? 'Cicilan hutang jatuh tempo'
            : 'Cicilan piutang jatuh tempo',
        body:
            '$personName - Cicilan ke-${inst.installmentNumber} - Rp ${inst.amount.toStringAsFixed(0)}',
        dueDate: inst.dueDate,
      );
    }
  }

  Stream<List<InstallmentModel>> watchInstallments(String debtId) {
    if (_uid == null) return const Stream.empty();
    return _firestore.watchInstallments(_uid!, debtId);
  }

  Future<void> markInstallmentPaid(
    String debtId,
    String installmentId,
    bool isPaid,
  ) async {
    if (_uid == null) return;
    await _firestore.markInstallmentPaid(
        _uid!, debtId, installmentId, isPaid);
    if (isPaid) {
      await _notifications.cancelReminder('$debtId-$installmentId');
    }
  }

  Future<void> markDebtPaidOff(String debtId) async {
    if (_uid == null) return;
    await _firestore.updateDebtStatus(_uid!, debtId, DebtStatus.paidOff);
    await _notifications.cancelReminder(debtId);
  }

  Future<void> deleteDebt(String debtId) async {
    if (_uid == null) return;
    await _firestore.deleteDebt(_uid!, debtId);
    await _notifications.cancelReminder(debtId);
  }
}
