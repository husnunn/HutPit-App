import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  StreamSubscription<User?>? _sub;

  User? user;
  bool isLoading = true;
  String? errorMessage;

  AuthProvider() {
    _sub = _authService.authStateChanges.listen((u) {
      user = u;
      isLoading = false;
      notifyListeners();
    });
  }

  Future<void> signInWithGoogle() async {
    errorMessage = null;
    try {
      await _authService.signInWithGoogle();
    } catch (e) {
      errorMessage = 'Gagal login dengan Google: $e';
      notifyListeners();
    }
  }

  Future<void> signInWithApple() async {
    errorMessage = null;
    try {
      await _authService.signInWithApple();
    } catch (e) {
      errorMessage = 'Gagal login dengan Apple: $e';
      notifyListeners();
    }
  }

  Future<void> signOut() => _authService.signOut();

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
