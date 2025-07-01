import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:homdwell/view/login_screen.dart';
import 'package:homdwell/view/splash_screen.dart';
import 'package:homdwell/view/my_upload_page.dart';
import 'package:homdwell/view/upload_house_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HomDwell',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SplashScreen(),
      getPages: [
        GetPage(name: '/login', page: () => const LoginScreen()),
        GetPage(name: '/my_upload', page: () => MyUploadPage()),
        GetPage(name: '/upload_house', page: () => const UploadHousePage()),
      ],
    );
  }
}
