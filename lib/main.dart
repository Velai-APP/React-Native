import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:velai/l10n/app_localizations.dart';

import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/notification.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  debugPrint("Background notification title: ${message.notification?.title}");
  debugPrint("Background notification body: ${message.notification?.body}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

await NotificationService.initialize();

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await setupFirebaseMessaging();

  runApp(const MyApp());
}

Future<void> setupFirebaseMessaging() async {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  final NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  debugPrint("Notification permission: ${settings.authorizationStatus}");

  final String? token = await messaging.getToken();
  debugPrint("FCM Token: $token");

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    debugPrint("Foreground notification title: ${message.notification?.title}");
    debugPrint("Foreground notification body: ${message.notification?.body}");
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    debugPrint("Notification clicked");
  });

  final RemoteMessage? initialMessage =
      await FirebaseMessaging.instance.getInitialMessage();

  if (initialMessage != null) {
    debugPrint("App opened from terminated notification");
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState? of(BuildContext context) {
    return context.findAncestorStateOfType<_MyAppState>();
  }
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Velai',

      locale: _locale,

      supportedLocales: const [
        Locale('en'),
        Locale('ta'),
        Locale('hi'),
      ],

      localizationsDelegates: AppLocalizations.localizationsDelegates,

      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
      ),

      home: const SplashScreen(),
    );
  }
}