import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:project/Mobile/LoginScreen/login_screen.dart';
import 'package:project/Web/Introduction/intro_screen.dart';
import 'package:project/colors/colors_scheme.dart';
import 'package:project/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      home: kIsWeb ? const WebIntroScreen() : const LoginSignupScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
