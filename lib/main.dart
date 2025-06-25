import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ✅ Add this import to enable Firebase
import 'package:firebase_core/firebase_core.dart';

import 'package:homebite/view/login_screen.dart';
import 'package:homebite/view/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize Firebase here
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HomeBite',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SplashScreen(), // Set splash screen as initial screen
      getPages: [
        GetPage(name: '/login', page: () => const LoginScreen()),
      ],
    );
  }
}
