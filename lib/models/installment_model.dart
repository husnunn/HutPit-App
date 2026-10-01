import 'package:cloud_firestore/cloud_firestore.dart';

/// Satu angsuran/cicilan dari sebuah [DebtModel] yang category-nya installment.
/// Disimpan sebagai subcollection di bawah dokumen hutangnya.
class InstallmentModel {
  final String id;
  final String debtId;
  final int installmentNumber;
  final double amount;
  final DateTime dueDate;
  final bool isPaid;
  final DateTime? paidAt;

  const InstallmentModel({
    required this.id,
    required this.debtId,
    required this.installmentNumber,
    required this.amount,
    required this.dueDate,
    this.isPaid = false,
    this.paidAt,
  });

  factory InstallmentModel.fromMap(
    String id,
    String debtId,
    Map<String, dynamic> map,
  ) {
    return InstallmentModel(
      id: id,
      debtId: debtId,
      installmentNumber: map['installmentNumber'] as int? ?? 0,
      amount: (map['amount'] as num? ?? 0).toDouble(),
      dueDate: (map['dueDate'] as Timestamp).toDate(),
      isPaid: map['isPaid'] as bool? ?? false,
      paidAt: map['paidAt'] != null
          ? (map['paidAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'installmentNumber': installmentNumber,
      'amount': amount,
      'dueDate': Timestamp.fromDate(dueDate),
      'isPaid': isPaid,
      'paidAt': paidAt != null ? Timestamp.fromDate(paidAt!) : null,
    };
  }
}
