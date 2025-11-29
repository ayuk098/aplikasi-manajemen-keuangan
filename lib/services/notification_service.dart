import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _noti =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(android: android);

    await _noti.initialize(initSettings);
  }

  static Future<void> showNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'transaksi_channel',
      'Transaksi Notification',
      importance: Importance.high,
      priority: Priority.high,
    );

    const generalDetails = NotificationDetails(android: androidDetails);

    await _noti.show(0, title, body, generalDetails);
  }
}
