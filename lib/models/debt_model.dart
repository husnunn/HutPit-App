import 'package:cloud_firestore/cloud_firestore.dart';

/// Arah hutang: apakah ini uang yang HARUS DIBAYAR pengguna (hutang),
/// atau uang yang AKAN DITERIMA pengguna dari orang lain (piutang).
enum DebtType { hutang, piutang }

/// Kategori pembayaran: sekali bayar penuh, atau dicicil beberapa kali.
enum DebtCategory { oneTime, installment }

enum DebtStatus { active, paidOff, overdue }

extension DebtTypeX on DebtType {
  String get label => this == DebtType.hutang ? 'Hutang' : 'Piutang';
}

extension DebtCategoryX on DebtCategory {
  String get label =>
      this == DebtCategory.oneTime ? 'Sekali Bayar' : 'Cicilan';
}

extension DebtStatusX on DebtStatus {
  String get label {
    switch (this) {
      case DebtStatus.active:
        return 'Berjalan';
      case DebtStatus.paidOff:
        return 'Lunas';
      case DebtStatus.overdue:
        return 'Terlambat';
    }
  }
}

class DebtModel {
  final String id;
  final String personName;
  final String? personContact;
  final DebtType type;
  final DebtCategory category;
  final double totalAmount;
  final DateTime startDate;

  /// Hanya diisi jika category == oneTime.
  final DateTime? dueDate;

  /// Hanya diisi jika category == installment.
  final int? installmentCount;

  final String? notes;
  final DebtStatus status;
  final DateTime createdAt;

  const DebtModel({
    required this.id,
    required this.personName,
    this.personContact,
    required this.type,
    required this.category,
    required this.totalAmount,
    required this.startDate,
    this.dueDate,
    this.installmentCount,
    this.notes,
    this.status = DebtStatus.active,
    required this.createdAt,
  });

  factory DebtModel.fromMap(String id, Map<String, dynamic> map) {
    return DebtModel(
      id: id,
      personName: map['personName'] as String? ?? '',
      personContact: map['personContact'] as String?,
      type: DebtType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => DebtType.hutang,
      ),
      category: DebtCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => DebtCategory.oneTime,
      ),
      totalAmount: (map['totalAmount'] as num? ?? 0).toDouble(),
      startDate: (map['startDate'] as Timestamp).toDate(),
      dueDate: map['dueDate'] != null
          ? (map['dueDate'] as Timestamp).toDate()
          : null,
      installmentCount: map['installmentCount'] as int?,
      notes: map['notes'] as String?,
      status: DebtStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => DebtStatus.active,
      ),
      createdAt:
          (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'personName': personName,
      'personContact': personContact,
      'type': type.name,
      'category': category.name,
      'totalAmount': totalAmount,
      'startDate': Timestamp.fromDate(startDate),
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'installmentCount': installmentCount,
      'notes': notes,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  DebtModel copyWith({DebtStatus? status}) {
    return DebtModel(
      id: id,
      personName: personName,
      personContact: personContact,
      type: type,
      category: category,
      totalAmount: totalAmount,
      startDate: startDate,
      dueDate: dueDate,
      installmentCount: installmentCount,
      notes: notes,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}
