import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homebite/view/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {  // Reduced to 3 seconds
      Get.offAll(() => const LoginScreen());  // Proper navigation
    });
  }

  @override
  void didChangeDependencies() {
    precacheImage(const AssetImage("images/pic1.jpg"), context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.pinkAccent, Colors.amberAccent],
            begin: FractionalOffset(0, 0),
            end: FractionalOffset(1, 0),
            stops: [0, 1],
            tileMode: TileMode.clamp,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "images/pic1.jpg",
                height: 150,  // Constrained height
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.fastfood, size: 100),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 18),
                child: Text(
                  "HomeBite",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                    color: Colors.blueAccent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}