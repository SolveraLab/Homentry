import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homdwell/view/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeIn = CurvedAnimation(parent: _animationController, curve: Curves.easeIn);
    _animationController.forward();

    Timer(const Duration(seconds: 3), () {
      Get.offAll(() => const LoginScreen());
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    precacheImage(const AssetImage("images/pic1.jpg"), context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    const Color amber = Color(0xFFFFB300);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Amber gradient layer
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black, amber],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Fading logo and text
          Center(
            child: FadeTransition(
              opacity: _fadeIn,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      "images/pic1.jpg",
                      height: 150,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.fastfood, size: 100, color: amber),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "HomDwell",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: amber,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Find best, Dwell Right",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
