import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/debt_model.dart';
import '../models/installment_model.dart';
import '../models/tabungan_model.dart';

/// Semua data disimpan per-user di:
///   users/{uid}/debts/{debtId}
///   users/{uid}/debts/{debtId}/installments/{installmentId}
///   users/{uid}/tabungan/{tabunganId}
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _debts(String uid) =>
      _db.collection('users').doc(uid).collection('debts');

  CollectionReference<Map<String, dynamic>> _installments(
    String uid,
    String debtId,
  ) =>
      _debts(uid).doc(debtId).collection('installments');

  CollectionReference<Map<String, dynamic>> _tabungan(String uid) =>
      _db.collection('users').doc(uid).collection('tabungan');

  // ---------------- Debts (hutang & piutang) ----------------

  Stream<List<DebtModel>> watchDebts(String uid) {
    return _debts(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => DebtModel.fromMap(d.id, d.data())).toList());
  }

  Future<String> addDebt(String uid, DebtModel debt) async {
    final ref = await _debts(uid).add(debt.toMap());
    return ref.id;
  }

  Future<void> updateDebtStatus(
    String uid,
    String debtId,
    DebtStatus status,
  ) {
    return _debts(uid).doc(debtId).update({'status': status.name});
  }

  Future<void> updateDebtPaidAmount(
    String uid,
    String debtId,
    double paidAmount,
  ) {
    return _debts(uid).doc(debtId).update({'paidAmount': paidAmount});
  }

  Future<void> deleteDebt(String uid, String debtId) async {
    final installments = await _installments(uid, debtId).get();
    final batch = _db.batch();
    for (final doc in installments.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(_debts(uid).doc(debtId));
    await batch.commit();
  }

  // ---------------- Installments (cicilan) ----------------

  Future<void> addInstallments(
    String uid,
    String debtId,
    List<InstallmentModel> installments,
  ) async {
    final batch = _db.batch();
    for (final inst in installments) {
      final ref = _installments(uid, debtId).doc();
      batch.set(ref, inst.toMap());
    }
    await batch.commit();
  }

  Stream<List<InstallmentModel>> watchInstallments(String uid, String debtId) {
    return _installments(uid, debtId)
        .orderBy('installmentNumber')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => InstallmentModel.fromMap(d.id, debtId, d.data()))
            .toList());
  }

  Future<void> markInstallmentPaid(
    String uid,
    String debtId,
    String installmentId,
    bool isPaid,
  ) {
    return _installments(uid, debtId).doc(installmentId).update({
      'isPaid': isPaid,
      'paidAt': isPaid ? Timestamp.now() : null,
    });
  }

  // ---------------- Tabungan ----------------

  Stream<List<TabunganModel>> watchTabungan(String uid) {
    return _tabungan(uid)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => TabunganModel.fromMap(d.id, d.data()))
            .toList());
  }

  Future<void> addTabungan(String uid, TabunganModel item) {
    return _tabungan(uid).add(item.toMap());
  }

  Future<void> deleteTabungan(String uid, String id) {
    return _tabungan(uid).doc(id).delete();
  }
}
