import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:homebite/view/signUp_screen.dart';
import 'package:homebite/view/splash_screen.dart';
import 'package:homebite/view/home_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailTextEditingController = TextEditingController();
  final TextEditingController _passwordTextEditingController = TextEditingController();

  bool isLoading = false;

  // 🔐 Login method
  Future<void> _loginUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailTextEditingController.text.trim(),
          password: _passwordTextEditingController.text.trim(),
        );

        Get.offAll(() => const HomePage());


      } on FirebaseAuthException catch (e) {
        String errorMessage = 'Login failed. Please try again.';
        if (e.code == 'user-not-found') {
          errorMessage = 'No user found with this email.';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Incorrect password.';
        }

        Get.snackbar(
          "Login Error",
          errorMessage,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  // 📧 Forgot password method
  Future<void> _forgotPassword() async {
    final email = _emailTextEditingController.text.trim();
    if (email.isEmpty || !email.contains("@")) {
      Get.snackbar(
        "Invalid Email",
        "Enter a valid email to reset password.",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      Get.snackbar(
        "Reset Link Sent",
        "Check your email to reset your password.",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        "Error",
        e.message ?? "Something went wrong.",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
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
          ),
        ),
        child: ListView(
          children: [
            Image.asset("images/PORSCHE.jpeg"),
            const Text(
              "Hello Friend.\nWelcome back",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 28,
                color: Colors.blueAccent,
                letterSpacing: 3,
              ),
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // 📧 Email field
                    Padding(
                      padding: const EdgeInsets.only(top: 26),
                      child: TextFormField(
                        controller: _emailTextEditingController,
                        decoration: const InputDecoration(labelText: "Email"),
                        style: const TextStyle(fontSize: 24),
                        validator: (valueEmail) {
                          if (!valueEmail!.contains("@")) {
                            return "Please enter a valid email.";
                          }
                          return null;
                        },
                      ),
                    ),

                    // 🔒 Password field
                    Padding(
                      padding: const EdgeInsets.only(top: 21),
                      child: TextFormField(
                        controller: _passwordTextEditingController,
                        decoration: const InputDecoration(labelText: "Password"),
                        style: const TextStyle(fontSize: 24),
                        obscureText: true,
                        validator: (valuePassword) {
                          if (valuePassword!.length < 8) {
                            return "Password should be at least 8 characters.";
                          }
                          return null;
                        },
                      ),
                    ),

                    // 🔵 Login button
                    Padding(
                      padding: const EdgeInsets.only(top: 25),
                      child: ElevatedButton(
                        onPressed: _loginUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 8),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    // 💡 Forgot Password button
                    TextButton(
                      onPressed: _forgotPassword,
                      child: const Text(
                        "Forgot Password?",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),

                    // 🧍 Signup navigation
                    TextButton(
                      onPressed: () => Get.offAll(() => const SignupScreen()),
                      child: const Text(
                        "Don't have an Account? Create one here.",
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
