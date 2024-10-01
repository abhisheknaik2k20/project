import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:project/Mobile/DashBoard/black_screen.dart';
import 'package:project/Mobile/LoginScreen/login_screen.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:project/colors/colors_scheme.dart';
import 'package:project/firebase_options.dart';

import 'Mobile/Notifications/periodic_noti.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await setupNotificationChannel();
  await requestNotificationPermissions();

  NotificationServicee().initNotification();
  tz.initializeTimeZones();

  // Initialize local notifications
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse);

  // Set up foreground message handler
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("Received a foreground message: ${message.messageId}");
    showNotification(message);
  });

  runApp(const MyApp());
}

Future<void> setupNotificationChannel() async {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // name
    description:
    'This channel is used for important notifications.', // description
    importance: Importance.high,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('iphone'),
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

void onDidReceiveNotificationResponse(
    NotificationResponse notificationResponse) {
  // Handle notification tap
  final String? payload = notificationResponse.payload;
  if (payload != null) {
    print('Notification payload: $payload');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    return MaterialApp(
      title: 'Demo App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: user!=null?BlackScreen(): LoginSignupScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

Future<void> requestNotificationPermissions() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  print('User granted permission: ${settings.authorizationStatus}');
}

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
  // Handle the message here
}

Future<void> showNotification(RemoteMessage message) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
  AndroidNotificationDetails(
    'your_channel_id',
    'your_channel_name',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: false,
  );
  const NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
  );
  await flutterLocalNotificationsPlugin.show(
    0,
    message.notification?.title ?? 'Notification Title',
    message.notification?.body ?? 'Notification Body',
    platformChannelSpecifics,
    payload: 'Notification Payload',
  );
}