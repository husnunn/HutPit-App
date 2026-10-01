# HutPit — Catatan Hutang, Piutang & Tabungan

![Flutter](https://img.shields.io/badge/Flutter-3.47-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.13-0175C2?logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-Auth%20%7C%20Firestore-FFCA28?logo=firebase&logoColor=black)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-3DDC84)

Aplikasi mobile Flutter untuk mencatat **hutang**, **piutang**, dan **tabungan** pribadi.
Mendukung pembayaran **sekali bayar** maupun **cicilan**, mengirim **pengingat jatuh tempo**
lewat notifikasi lokal, dan menyinkronkan data ke **Cloud Firestore** sehingga aman
walau berganti perangkat.

---

## Daftar Isi

- [Fitur](#fitur)
- [Tech Stack](#tech-stack)
- [Struktur Proyek](#struktur-proyek)
- [Model Data Firestore](#model-data-firestore)
- [Memulai](#memulai)
- [Konfigurasi Firebase](#konfigurasi-firebase)
- [Konfigurasi Login](#konfigurasi-login)
- [Notifikasi Pengingat](#notifikasi-pengingat)
- [Build Release](#build-release)
- [Troubleshooting](#troubleshooting)
- [Roadmap](#roadmap)

---

## Fitur

**Ringkasan (Dashboard)**
- Total hutang aktif, total piutang aktif, saldo tabungan, dan selisih piutang − hutang.
- Total hutang/piutang otomatis berkurang setiap kali cicilan ditandai lunas.
- Daftar hutang/piutang yang **segera jatuh tempo**.

**Hutang & Piutang**
- Tab terpisah untuk *Hutang Saya* dan *Piutang*.
- Dua kategori pembayaran:
  - **Sekali Bayar** — satu tanggal jatuh tempo.
  - **Cicilan** — total dibagi rata ke N cicilan, jatuh tempo di tanggal yang sama setiap bulan.
- Simpan nama, kontak (opsional), nominal, dan catatan.
- Tandai cicilan lunas satu per satu; status hutang otomatis menjadi **Lunas** bila semua cicilan terbayar.
- Status: *Berjalan*, *Lunas*, *Terlambat*.

**Tabungan**
- Catat transaksi **Setor** dan **Tarik**, lengkap dengan tanggal dan catatan.
- Saldo tabungan dihitung otomatis.
- Tekan lama pada item untuk menghapus.

**Akun & Sinkronisasi**
- Login SSO dengan **Google** (Android & iOS) dan **Apple** (iOS).
- Data tersimpan per pengguna di Cloud Firestore dan tersinkron real-time.

**Lainnya**
- Notifikasi lokal **H-1** dan **hari-H** pukul 09.00 untuk setiap hutang/cicilan.
- Material 3 dengan dukungan **light & dark mode** mengikuti sistem.
- Format mata uang dan tanggal Indonesia (`id_ID`).

---

## Tech Stack

| Kebutuhan | Paket |
|---|---|
| UI | Flutter, Material 3 |
| State management | [`provider`](https://pub.dev/packages/provider) |
| Backend | [`firebase_core`](https://pub.dev/packages/firebase_core), [`cloud_firestore`](https://pub.dev/packages/cloud_firestore) |
| Autentikasi | [`firebase_auth`](https://pub.dev/packages/firebase_auth), [`google_sign_in`](https://pub.dev/packages/google_sign_in), [`sign_in_with_apple`](https://pub.dev/packages/sign_in_with_apple) |
| Notifikasi | [`flutter_local_notifications`](https://pub.dev/packages/flutter_local_notifications), [`timezone`](https://pub.dev/packages/timezone), [`permission_handler`](https://pub.dev/packages/permission_handler) |
| Utilitas | [`intl`](https://pub.dev/packages/intl), [`uuid`](https://pub.dev/packages/uuid), [`crypto`](https://pub.dev/packages/crypto) |

---

## Struktur Proyek

```
lib/
├── main.dart                  # Inisialisasi Firebase, notifikasi, dan Provider
├── firebase_options.dart      # Dihasilkan oleh `flutterfire configure`
├── models/
│   ├── debt_model.dart        # Hutang/piutang (tipe, kategori, status)
│   ├── installment_model.dart # Cicilan
│   └── tabungan_model.dart    # Transaksi setor/tarik
├── services/
│   ├── auth_service.dart      # Google & Apple Sign-In → Firebase Auth
│   ├── firestore_service.dart # CRUD Firestore
│   └── notification_service.dart # Penjadwalan notifikasi lokal
├── providers/
│   ├── auth_provider.dart
│   ├── debt_provider.dart
│   └── tabungan_provider.dart
├── screens/
│   ├── splash_screen.dart
│   ├── login_screen.dart
│   ├── home_screen.dart       # Bottom navigation + tab Ringkasan
│   ├── debt_list_screen.dart
│   ├── debt_detail_screen.dart
│   ├── add_edit_debt_screen.dart
│   ├── tabungan_list_screen.dart
│   ├── add_tabungan_screen.dart
│   └── settings_screen.dart
├── widgets/                   # SummaryCard, DebtCard, InstallmentTile, EmptyState
└── utils/                     # Tema aplikasi, formatter mata uang & tanggal
```

---

## Model Data Firestore

Semua data disimpan di bawah UID pengguna sehingga setiap akun hanya bisa mengakses datanya sendiri.

```
users/{uid}
├── debts/{debtId}
│   ├── personName, personContact, notes
│   ├── type            : "hutang" | "piutang"
│   ├── category        : "oneTime" | "installment"
│   ├── totalAmount, paidAmount
│   ├── startDate, dueDate (khusus oneTime), installmentCount (khusus installment)
│   ├── status          : "active" | "paidOff" | "overdue"
│   ├── createdAt
│   └── installments/{installmentId}      # hanya untuk category = installment
│       └── installmentNumber, amount, dueDate, isPaid, paidAt
└── tabungan/{tabunganId}
    └── type ("setor" | "tarik"), amount, date, notes, createdAt
```

---

## Memulai

### Prasyarat

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.47 atau lebih baru (Dart 3.13+)
- Android Studio (Android SDK) dan/atau Xcode (untuk iOS, wajib macOS)
- JDK 17
- Akun [Firebase](https://console.firebase.google.com)

### Instalasi

```bash
git clone https://github.com/husnunn/HutPit-App.git
cd HutPit-App
flutter pub get
flutter run
```

> Repo ini sudah berisi konfigurasi Firebase milik pengembang. Jika kamu melakukan fork
> dan ingin memakai backend sendiri, ikuti bagian [Konfigurasi Firebase](#konfigurasi-firebase).

---

## Konfigurasi Firebase

1. Buat project baru di [Firebase Console](https://console.firebase.google.com).
2. Aktifkan **Cloud Firestore**.
3. Di **Authentication → Sign-in method**, aktifkan **Google** dan **Apple**.
4. Hubungkan aplikasi dengan FlutterFire CLI:

   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

   Perintah ini akan menimpa `lib/firebase_options.dart`, `android/app/google-services.json`,
   dan `ios/Runner/GoogleService-Info.plist` dengan konfigurasi project kamu.

5. Pasang **Firestore Security Rules** berikut supaya setiap pengguna hanya bisa membaca
   dan menulis datanya sendiri:

   ```
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /users/{userId}/{document=**} {
         allow read, write: if request.auth != null && request.auth.uid == userId;
       }
     }
   }
   ```

---

## Konfigurasi Login

### Google Sign-In

1. Ganti nilai `serverClientId` di `lib/services/auth_service.dart` dengan **Web client ID**
   dari project Firebase kamu (Google Cloud Console → APIs & Services → Credentials).
2. **Android** — daftarkan sidik jari SHA-1 dan SHA-256 di
   *Firebase Console → Project Settings → Android app → Add fingerprint*, lalu unduh ulang
   `google-services.json`. Daftarkan **kedua** kunci:
   - Kunci debug (untuk `flutter run`):
     ```bash
     keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android
     ```
   - Kunci release (untuk APK/AAB yang dibagikan), lihat [Build Release](#build-release).
3. **iOS** — pastikan URL scheme `REVERSED_CLIENT_ID` dari `GoogleService-Info.plist`
   sudah ada di `ios/Runner/Info.plist`.

### Sign in with Apple (iOS)

1. Aktifkan capability **Sign In with Apple** untuk App ID di
   [Apple Developer Portal](https://developer.apple.com/account).
2. Buka `ios/Runner.xcworkspace` di Xcode → target **Runner** → **Signing & Capabilities**
   → tambahkan **Sign in with Apple**.

Tombol login Apple hanya ditampilkan di iOS.

---

## Notifikasi Pengingat

Notifikasi dijadwalkan secara lokal di perangkat oleh `NotificationService`:

- **H-1 pukul 09.00** — pengingat sehari sebelum jatuh tempo.
- **Hari-H pukul 09.00** — pengingat pada hari jatuh tempo.

Untuk hutang cicilan, pengingat dijadwalkan untuk setiap cicilan. Pengingat hutang
sekali bayar otomatis dibatalkan saat hutang ditandai lunas atau dihapus.

**Android** — izin berikut sudah dideklarasikan di `AndroidManifest.xml`:
`POST_NOTIFICATIONS`, `SCHEDULE_EXACT_ALARM`, `USE_EXACT_ALARM`, `RECEIVE_BOOT_COMPLETED`.

**iOS** — izin notifikasi diminta saat aplikasi pertama kali dibuka.

> Karena dijadwalkan secara lokal, pengingat akan hilang jika aplikasi di-uninstall.

---

## Build Release

### Android

1. Buat keystore release (cukup sekali, simpan baik-baik):

   ```bash
   keytool -genkey -v -keystore ~/hutpit-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias hutpit
   ```

2. Buat file `android/key.properties` (sudah masuk `.gitignore`, **jangan di-commit**):

   ```properties
   storePassword=<password>
   keyPassword=<password>
   keyAlias=hutpit
   storeFile=/path/ke/hutpit-release.jks
   ```

3. Daftarkan SHA-1/SHA-256 kunci release di Firebase agar Google Sign-In berfungsi:

   ```bash
   keytool -list -v -keystore ~/hutpit-release.jks -alias hutpit
   ```

4. Build:

   ```bash
   # APK untuk dipasang langsung
   flutter build apk --release
   # → build/app/outputs/flutter-apk/app-release.apk

   # APK lebih kecil, dipisah per arsitektur
   flutter build apk --release --split-per-abi

   # App Bundle untuk Google Play Store
   flutter build appbundle --release
   ```

### iOS

Build **Debug** tidak bisa dibuka tanpa terhubung ke Mac, jadi gunakan mode **Release**:

```bash
# Pasang langsung ke iPhone yang tersambung kabel
flutter run --release

# Atau buat file .ipa untuk TestFlight / App Store
flutter build ipa --release
```

> Dengan Apple ID gratis, aplikasi yang dipasang hanya berlaku 7 hari.
> Dengan Apple Developer Program, aplikasi berlaku sekitar 1 tahun dan bisa didistribusikan lewat TestFlight.

---

## Troubleshooting

| Masalah | Solusi |
|---|---|
| Login Google gagal (`ApiException: 10`) | SHA-1 kunci yang dipakai belum terdaftar di Firebase. Tambahkan, lalu unduh ulang `google-services.json`. |
| `Inconsistent JVM-target compatibility` saat build Android | Pastikan `compileOptions` dan `kotlin.jvmTarget` di `android/app/build.gradle.kts` sama-sama memakai Java 17. |
| Aplikasi iOS langsung tertutup saat dibuka dari home screen | Aplikasi masih build Debug. Pasang ulang dengan `flutter run --release`. |
| Notifikasi tidak muncul di Android 12+ | Izinkan *Alarms & reminders* untuk aplikasi di pengaturan sistem. |

---

## Roadmap

- [ ] Edit data hutang/piutang dan tabungan
- [ ] Pengaturan jumlah hari pengingat (saat ini tetap H-1)
- [ ] Grafik riwayat tabungan dan hutang
- [ ] Ekspor data (CSV/PDF)
- [ ] Pencarian dan filter berdasarkan status

---

## Kontribusi

Issue dan pull request sangat diterima. Untuk perubahan besar, buka issue terlebih dahulu
untuk mendiskusikan apa yang ingin diubah.

1. Fork repo ini
2. Buat branch fitur: `git checkout -b feat/nama-fitur`
3. Commit perubahan: `git commit -m "feat: tambah nama fitur"`
4. Push: `git push origin feat/nama-fitur`
5. Buka Pull Request
