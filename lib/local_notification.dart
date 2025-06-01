import "package:firebase_core/firebase_core.dart";
import "package:firebase_messaging/firebase_messaging.dart";
import "package:flutter/material.dart";
import "package:patinka/api/config.dart";
import "package:patinka/api/fcm_token.dart";
import "package:patinka/api/messages.dart";
import "package:patinka/api/social.dart";
import "package:patinka/common_logger.dart";
import "package:patinka/services/navigation_service.dart";
import "package:patinka/social_media/private_messages/private_message.dart";
import "package:patinka/misc/notifications/session_notification.dart";

// Entry point for handling Firebase background messages
@pragma("vm:entry-point")
Future<void> _firebaseMessagingBackgroundHandler(
    final RemoteMessage message) async {
  await Firebase.initializeApp(); // Ensure Firebase is initialized
  if (message.notification != null) {
    commonLogger.d("Current URI is: ${Config.uri}");
    NotificationManager.instance.addMessage(message);
  }
}

Future<void> _firebaseMessagingMessageOpenedHandler(
    final RemoteMessage message) async {
  if (message.data.containsKey("channelId") &&
      message.data.containsKey("click_action")) {
    if (message.data["click_action"] == "FLUTTER_NOTIFICATION_CLICK") {
      final Map<String, dynamic> user =
          await SocialAPI.getUser(message.data["senderId"]);
      final Map<String, dynamic> channel =
          await MessagesAPI.getChannel(message.data["channelId"]);
      final String? userId = await storage.getId();
      if (userId == null) {
        return;
      }
      Navigator.push(
        NavigationService.currentNavigatorKey.currentContext!,
        MaterialPageRoute(
          builder: (final context) => PrivateMessage(
            initSelf: true,
            channel: channel,
            user: user,
            currentUser: userId,
          ),
        ),
      );
    }
  }
}

// Manages notifications and handles Firebase messaging events
class NotificationManager extends ChangeNotifier {
  factory NotificationManager() => _instance;

  // Private constructor
  NotificationManager._privateConstructor();
  final messaging = FirebaseMessaging.instance;

  final List<CustomNotification> _notifications = [];

  static final NotificationManager _instance =
      NotificationManager._privateConstructor();
  static NotificationManager get instance => _instance;

  List<CustomNotification> get notifications => _notifications;

  // Adds a new message/notification to the list
  void addMessage(final RemoteMessage message) {
    if (message.notification != null) {
      _notifications.add(CustomNotification(
        title: message.notification!.title ?? "",
        body: message.notification!.body,
      ));
    }
    notifyListeners();
  }

  // Dismisses a specific message/notification
  void dismissMessage(final CustomNotification message) {
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
    final settings = await messaging.requestPermission(
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
      FirebaseMessaging.onMessage.listen((final RemoteMessage message) async {
        if (message.notification != null) {
          commonLogger.d("Recieved Notification");
          final String? userId = await storage.getId();
          if (userId == null) {
            return;
          }
          final Map<String, dynamic> data = {
            "sender": message.data["senderId"],
            "content": message.notification?.body ?? "",
            "channel": message.data["channelId"],
          };
          if (NavigationService.currentNavigatorKey.currentContext != null) {
            showNotification(
                NavigationService.currentNavigatorKey.currentContext!,
                data,
                userId);
            addMessage(message);
          }
        }
      });

      // Sets the background message handler
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);
      FirebaseMessaging.onMessageOpenedApp
          .listen(_firebaseMessagingMessageOpenedHandler);

      // Listens for token refresh events
      FirebaseMessaging.instance.onTokenRefresh.listen(updateToken);
    }
  }
}

// Represents a custom notification with title, body, route, and icon information
class CustomNotification {
  CustomNotification({
    required this.title,
    this.body,
    this.route,
    this.iconPath,
  });
  String title;
  String? body;
  String? route;
  String? iconPath;
}
