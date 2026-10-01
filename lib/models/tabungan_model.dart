import 'package:cloud_firestore/cloud_firestore.dart';

enum TabunganType { setor, tarik }

extension TabunganTypeX on TabunganType {
  String get label => this == TabunganType.setor ? 'Setor' : 'Tarik';
}

class TabunganModel {
  final String id;
  final TabunganType type;
  final double amount;
  final DateTime date;
  final String? notes;
  final DateTime createdAt;

  const TabunganModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.date,
    this.notes,
    required this.createdAt,
  });

  factory TabunganModel.fromMap(String id, Map<String, dynamic> map) {
    return TabunganModel(
      id: id,
      type: TabunganType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => TabunganType.setor,
      ),
      amount: (map['amount'] as num? ?? 0).toDouble(),
      date: (map['date'] as Timestamp).toDate(),
      notes: map['notes'] as String?,
      createdAt:
          (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
