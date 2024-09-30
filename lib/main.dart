import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:project/Mobile/Notifications/notifications.dart';
import 'package:project/Mobile/VideoCall/fetch_users.dart';
import 'package:project/colors/colors_scheme.dart';
import 'package:project/firebase_options.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final notificationService = NotificationService();

  await notificationService.initialize((String route) {
    // Navigate to the specified route
    navigatorKey.currentState?.pushNamed(route);
  });
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const FetchUsersWEBRTC(),
      debugShowCheckedModeBanner: false,
    );
  }
}
