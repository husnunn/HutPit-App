import 'package:cloud_firestore/cloud_firestore.dart';

enum ExpenseCategory {
  makanan,
  transportasi,
  tagihan,
  hiburan,
  kesehatan,
  belanja,
  pendidikan,
  lainnya,
}

extension ExpenseCategoryX on ExpenseCategory {
  String get label {
    switch (this) {
      case ExpenseCategory.makanan:
        return 'Makanan';
      case ExpenseCategory.transportasi:
        return 'Transportasi';
      case ExpenseCategory.tagihan:
        return 'Tagihan';
      case ExpenseCategory.hiburan:
        return 'Hiburan';
      case ExpenseCategory.kesehatan:
        return 'Kesehatan';
      case ExpenseCategory.belanja:
        return 'Belanja';
      case ExpenseCategory.pendidikan:
        return 'Pendidikan';
      case ExpenseCategory.lainnya:
        return 'Lainnya';
    }
  }
}

class ExpenseModel {
  final String id;
  final double amount;
  final ExpenseCategory category;
  final DateTime date;
  final String? notes;
  final DateTime createdAt;

  const ExpenseModel({
    required this.id,
    required this.amount,
    required this.category,
    required this.date,
    this.notes,
    required this.createdAt,
  });

  factory ExpenseModel.fromMap(String id, Map<String, dynamic> map) {
    return ExpenseModel(
      id: id,
      amount: (map['amount'] as num? ?? 0).toDouble(),
      category: ExpenseCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => ExpenseCategory.lainnya,
      ),
      date: (map['date'] as Timestamp).toDate(),
      notes: map['notes'] as String?,
      createdAt:
          (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'category': category.name,
      'date': Timestamp.fromDate(date),
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
