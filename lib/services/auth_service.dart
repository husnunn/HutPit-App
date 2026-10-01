import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Login menggunakan SSO: Google Sign-In & Sign in with Apple, keduanya
/// dijembatani ke Firebase Auth supaya data user (uid) konsisten dipakai
/// sebagai kunci koleksi Firestore.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _googleInitialized = false;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<void> _ensureGoogleInitialized() async {
    if (_googleInitialized) return;
    await _googleSignIn.initialize(
      // WAJIB diisi dengan OAuth "Web client" Client ID dari project Firebase
      // kamu (Google Cloud Console -> APIs & Services -> Credentials).
      // Ini dipakai di semua platform supaya idToken bisa diverifikasi Firebase.
      serverClientId: '912790501929-cok39triffeumrcfdl7ag83m5t9hbf3b.apps.googleusercontent.com',
    );
    _googleInitialized = true;
  }

  /// Login dengan akun Google. Melempar [GoogleSignInException] jika user
  /// membatalkan proses login (cek `e.code == GoogleSignInExceptionCode.canceled`).
  Future<UserCredential> signInWithGoogle() async {
    await _ensureGoogleInitialized();

    if (!_googleSignIn.supportsAuthenticate()) {
      throw StateError('Google Sign-In tidak didukung di platform ini.');
    }

    final account = await _googleSignIn.authenticate();
    final idToken = account.authentication.idToken;
    if (idToken == null) {
      throw StateError('Gagal mendapatkan ID token dari Google.');
    }

    final credential = GoogleAuthProvider.credential(idToken: idToken);
    return _auth.signInWithCredential(credential);
  }

  /// Login dengan Sign in with Apple. Wajib tersedia di iOS; di Android akan
  /// memakai alur web (lihat README untuk setup Service ID di Apple Developer).
  Future<UserCredential> signInWithApple() async {
    final rawNonce = _generateNonce();
    final hashedNonce = _sha256ofString(rawNonce);

    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: hashedNonce,
    );

    final oauthCredential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
    );

    return _auth.signInWithCredential(oauthCredential);
  }

  Future<void> signOut() async {
    if (_googleInitialized) {
      await _googleSignIn.signOut();
    }
    await _auth.signOut();
  }

  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  String _sha256ofString(String input) {
    return sha256.convert(utf8.encode(input)).toString();
  }
}
