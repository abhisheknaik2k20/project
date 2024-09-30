import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:project/Mobile/DashBoard/black_screen.dart';
import 'package:project/Mobile/LoginScreen/login_screen.dart';
import 'package:project/Web/Introduction/intro_screen.dart';
import 'package:project/colors/colors_scheme.dart';
import 'package:project/firebase_options.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'notifications/periodic_noti.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  NotificationService().initNotification();
  tz.initializeTimeZones();
  // tz.initializeTimeZones();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    User? user=FirebaseAuth.instance.currentUser;
    return MaterialApp(
      title: 'Demo App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: kIsWeb ? const WebIntroScreen() : user!=null?BlackScreen(): LoginSignupScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
