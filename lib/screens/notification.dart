import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin notifications =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'website_updates';

  static const String _channelName = 'Website Updates';

  static const String _channelDescription =
      'Notifications about website generation and publishing';

  static Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await notifications.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    await _createAndroidChannel();
    await _requestAndroidPermission();
  }

  static void _onNotificationTapped(
    NotificationResponse response,
  ) {
    final payload = response.payload;

    if (payload == null || payload.isEmpty) {
      return;
    }

    // Later you can navigate to MyWebsitesScreen
    // using the websiteId passed in the payload.
    print('Notification tapped: $payload');
  }

  static Future<void> _createAndroidChannel() async {
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
    );

    final androidPlugin = notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(
      channel,
    );
  }

  static Future<void> _requestAndroidPermission() async {
    final androidPlugin = notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.requestNotificationsPermission();
  }

  static Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
    int? id,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    await notifications.show(
      id: id ?? DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      notificationDetails: details,
      payload: payload,
    );
  }

  static Future<void> showWebsiteReadyNotification({
    required String websiteId,
    required String businessName,
  }) async {
    await showNotification(
      title: 'Your website is ready',
      body: '$businessName has been published successfully.',
      payload: websiteId,
    );
  }

  static Future<void> showWebsiteFailedNotification({
    required String websiteId,
    required String businessName,
  }) async {
    await showNotification(
      title: 'Website generation failed',
      body: 'We could not publish $businessName. Please try again.',
      payload: websiteId,
    );
  }

  static Future<void> cancelNotification(
    int notificationId,
  ) async {
    await notifications.cancel(
      id: notificationId,
    );
  }

  static Future<void> cancelAllNotifications() async {
    await notifications.cancelAll();
  }
}