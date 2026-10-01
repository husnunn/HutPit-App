import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/tabungan_model.dart';
import '../services/firestore_service.dart';

class TabunganProvider extends ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();

  String? _uid;
  StreamSubscription<List<TabunganModel>>? _sub;

  List<TabunganModel> tabunganList = [];
  bool isLoading = true;

  void updateUser(String? uid) {
    if (uid == _uid) return;
    _uid = uid;
    _sub?.cancel();
    tabunganList = [];

    if (uid == null) {
      isLoading = false;
      notifyListeners();
      return;
    }

    isLoading = true;
    notifyListeners();
    _sub = _firestore.watchTabungan(uid).listen((data) {
      tabunganList = data;
      isLoading = false;
      notifyListeners();
    });
  }

  double get saldoTabungan => tabunganList.fold(
        0,
        (sum, t) => sum + (t.type == TabunganType.setor ? t.amount : -t.amount),
      );

  Future<void> addTabungan({
    required TabunganType type,
    required double amount,
    required DateTime date,
    String? notes,
  }) async {
    if (_uid == null) return;
    final item = TabunganModel(
      id: '',
      type: type,
      amount: amount,
      date: date,
      notes: notes,
      createdAt: DateTime.now(),
    );
    await _firestore.addTabungan(_uid!, item);
  }

  Future<void> deleteTabungan(String id) async {
    if (_uid == null) return;
    await _firestore.deleteTabungan(_uid!, id);
  }
}
