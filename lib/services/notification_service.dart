import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Menjadwalkan notifikasi lokal H-1 (default) dan pada hari jatuh tempo,
/// untuk hutang sekali-bayar maupun untuk tiap cicilan.
///
/// Catatan: notifikasi lokal dijadwalkan di perangkat itu sendiri. Jika app
/// di-uninstall atau data plugin dibersihkan, jadwal yang tersimpan di OS ikut
/// hilang — jadwalkan ulang setiap kali data hutang/cicilan berubah.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tzdata.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings =
        InitializationSettings(android: androidInit, iOS: iosInit);

    await _plugin.initialize(settings);
    await _createAndroidChannel();
    await _requestPermissions();
  }

  Future<void> _createAndroidChannel() async {
    const channel = AndroidNotificationChannel(
      'debt_due_channel',
      'Pengingat Jatuh Tempo',
      description: 'Notifikasi untuk hutang/piutang yang akan jatuh tempo',
      importance: Importance.high,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> _requestPermissions() async {
    await Permission.notification.request();
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();
    await _plugin
    .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
    ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  /// ID notifikasi dibuat deterministik dari sebuah key (mis. debtId atau
  /// installmentId) supaya bisa dibatalkan lagi nanti dengan key yang sama.
  int _idFor(String key) => key.hashCode & 0x7fffffff;

  /// Menjadwalkan 2 notifikasi: [daysBefore] hari sebelum [dueDate] jam 09:00,
  /// dan pada hari-H jam 09:00. [key] harus unik per hutang/cicilan.
  Future<void> scheduleDueReminder({
    required String key,
    required String title,
    required String body,
    required DateTime dueDate,
    int daysBefore = 1,
  }) async {
    final now = DateTime.now();

    final reminderDate = dueDate.subtract(Duration(days: daysBefore));
    final reminderAt =
        DateTime(reminderDate.year, reminderDate.month, reminderDate.day, 9);
    if (reminderAt.isAfter(now)) {
      await _schedule(
        id: _idFor('$key-reminder'),
        title: title,
        body: body,
        dateTime: reminderAt,
      );
    }

    final dueAt = DateTime(dueDate.year, dueDate.month, dueDate.day, 9);
    if (dueAt.isAfter(now)) {
      await _schedule(
        id: _idFor('$key-dueday'),
        title: title,
        body: 'Jatuh tempo hari ini: $body',
        dateTime: dueAt,
      );
    }
  }

  Future<void> _schedule({
    required int id,
    required String title,
    required String body,
    required DateTime dateTime,
  }) async {
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(dateTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'debt_due_channel',
          'Pengingat Jatuh Tempo',
          channelDescription:
              'Notifikasi untuk hutang/piutang yang akan jatuh tempo',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// Batalkan kedua notifikasi (reminder H- & hari-H) untuk [key] tertentu.
  Future<void> cancelReminder(String key) async {
    await _plugin.cancel(_idFor('$key-reminder'));
    await _plugin.cancel(_idFor('$key-dueday'));
  }
}
