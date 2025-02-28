// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// class NotificationService {
//   final FlutterLocalNotificationsPlugin notificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   Future<void> initNotification() async {
//     AndroidInitializationSettings initializationSettingsAndroid =
//         const AndroidInitializationSettings('logo.png');

//     var initializationSettingsIOS = const DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//     );

//     var initializationSettings = InitializationSettings(
//         android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
//     await notificationsPlugin.initialize(initializationSettings,
//         onDidReceiveNotificationResponse:
//             (NotificationResponse notificationResponse) async {});
//   }

//   notificationDetails() {
//     return const NotificationDetails(
//         android: AndroidNotificationDetails('channelId', 'channelName',
//             importance: Importance.max),
//         iOS: DarwinNotificationDetails());
//   }

//   Future showNotification(
//       {int id = 0, String? title, String? body, String? payLoad}) async {
//     return notificationsPlugin.show(
//         id, title, body, await notificationDetails());
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// class NotifiService {
//   static final NotifiService _instance = NotifiService._internal();
//   factory NotifiService() => _instance;
//   NotifiService._internal();

//   final FlutterLocalNotificationsPlugin notificationPlugin =
//       FlutterLocalNotificationsPlugin();
//   bool _initialized = false;

//   Future<void> iniNotification() async {
//     if (_initialized) return;

//     const AndroidInitializationSettings initSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');

//     const DarwinInitializationSettings initSettingsIOS =
//         DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//     );

//     final InitializationSettings initSettings = InitializationSettings(
//       android: initSettingsAndroid,
//       iOS: initSettingsIOS,
//     );

//     await notificationPlugin.initialize(
//       initSettings,
//       onDidReceiveNotificationResponse: (NotificationResponse response) {
//         debugPrint('Notification clicked: ${response.payload}');
//         resetUnreadCount(); // Reset unread count when notification is clicked
//       },
//     );

//     _initialized = true;
//   }

//   NotificationDetails notificationDetails() {
//     return const NotificationDetails(
//       android: AndroidNotificationDetails(
//         'promo_channel_id',
//         'Promotions',
//         channelDescription: 'Notifications for new promotions',
//         importance: Importance.max,
//         priority: Priority.high,
//       ),
//       iOS: DarwinNotificationDetails(),
//     );
//   }

//   Future<void> showNotification({
//     int id = 0,
//     required String title,
//     required String body,
//   }) async {
//     await notificationPlugin.show(id, title, body, notificationDetails());
//     _incrementUnreadCount(); // Update unread count
//   }

//   // Increase unread notification count
//   Future<void> _incrementUnreadCount() async {
//     final prefs = await SharedPreferences.getInstance();
//     int count = prefs.getInt('unread_count') ?? 0;
//     await prefs.setInt('unread_count', count + 1);
//   }

//   // Get unread notification count
//   Future<int> getUnreadCount() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getInt('unread_count') ?? 0;
//   }

//   // Reset unread notification count when user checks notifications
//   Future<void> resetUnreadCount() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setInt('unread_count', 0);
//   }
// }

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_dynamic_icon/flutter_dynamic_icon.dart';

class NotifiService {
  static final NotifiService _instance = NotifiService._internal();
  factory NotifiService() => _instance;
  NotifiService._internal();

  final FlutterLocalNotificationsPlugin notificationPlugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> iniNotification() async {
    if (_initialized) return;

    const AndroidInitializationSettings initSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings initSettings = InitializationSettings(
      android: initSettingsAndroid,
      iOS: initSettingsIOS,
    );

    await notificationPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('Notification clicked: ${response.payload}');
        resetUnreadCount(); // ✅ Reset unread count when notification is clicked
      },
    );

    _initialized = true;

    // ✅ Restore unread count on app start
    int unreadCount = await getUnreadCount();
    _updateBadge(unreadCount);
  }

  NotificationDetails notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'promo_channel_id',
        'Promotions',
        channelDescription: 'Notifications for new promotions',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  Future<void> showNotification({
    int id = 0,
    required String title,
    required String body,
  }) async {
    await notificationPlugin.show(id, title, body, notificationDetails());
    _incrementUnreadCount(); // ✅ Update unread count & badge
  }

  // ✅ Increase unread notification count and update badge
  Future<void> _incrementUnreadCount() async {
    final prefs = await SharedPreferences.getInstance();
    int count = prefs.getInt('unread_count') ?? 0;
    count++;
    await prefs.setInt('unread_count', count);
    _updateBadge(count);
  }

  // ✅ Get unread notification count
  Future<int> getUnreadCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('unread_count') ?? 0;
  }

  // ✅ Reset unread notification count and remove badge
  Future<void> resetUnreadCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('unread_count', 0);
    await prefs.reload();
    _updateBadge(0);
  }

  // ✅ Update the app icon badge dynamically
  Future<void> _updateBadge(int count) async {
    try {
      await FlutterDynamicIcon.setApplicationIconBadgeNumber(count);
    } catch (e) {
      debugPrint('Badge update not supported: $e');
    }
  }
}
