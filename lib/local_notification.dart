import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:patinka/api/fcm_token.dart';
import 'common_logger.dart';

// Entry point for handling Firebase background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (message.notification != null) {
    NotificationManager.instance.addMessage(message);
  }
}

// Manages notifications and handles Firebase messaging events
class NotificationManager extends ChangeNotifier {
  final messaging = FirebaseMessaging.instance;

  final List<CustomNotification> _notifications = [];

  static final NotificationManager _instance =
      NotificationManager._privateConstructor();

  factory NotificationManager() => _instance;
  static NotificationManager get instance => _instance;

  // Private constructor
  NotificationManager._privateConstructor();

  List<CustomNotification> get notifications => _notifications;

  // Adds a new message/notification to the list
  void addMessage(RemoteMessage message) {
    if (message.notification != null) {
      _notifications.add(CustomNotification(
        title: message.notification!.title ?? '',
        body: message.notification!.body,
      ));
    }
    notifyListeners();
  }

  // Dismisses a specific message/notification
  void dismissMessage(CustomNotification message) {
    _notifications.remove(message);
    notifyListeners();
  }

  // Dismisses all messages/notifications
  void dismissAllMessages() {
    _notifications.removeRange(0, _notifications.length);
    notifyListeners();
  }

  // Initializes the notification manager
  Future<void> initialize() async {
    // Retrieves the FCM token
    final fcmToken = await FirebaseMessaging.instance.getToken();
    commonLogger.i(fcmToken);

    // Requests permission to show notifications
    var settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: true,
      sound: true,
    );

    // Checks if the permission was granted
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Configures foreground notification presentation options
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true, // Required to display a heads up notification
        badge: true,
        sound: true,
      );

      // Listens for incoming messages while the app is in the foreground
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (message.notification != null) {
          addMessage(message);
        }
      });

      // Sets the background message handler
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);

      // Listens for token refresh events
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        updateToken(newToken);
      });
    }
  }
}

// Represents a custom notification with title, body, route, and icon information
class CustomNotification {
  String title;
  String? body;
  String? route;
  String iconPath;

  CustomNotification(
      {required this.title,
      this.body,
      this.route,
      this.iconPath = "eee" //CustomIcons.bell,
      });
}
