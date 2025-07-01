import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:homdwell/view/signUp_screen.dart';
import 'package:homdwell/view/home_page.dart';
import 'package:shimmer/shimmer.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool isLoading = false;
  bool showPassword = false;
  double opacity = 0;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) Get.offAll(() => const HomePage());
    });
    _checkEmailLink();

    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() => opacity = 1);
    });
  }

  void _checkEmailLink() async {
    final email = _emailController.text.trim();
    final link = Uri.base.toString();
    if (FirebaseAuth.instance.isSignInWithEmailLink(link)) {
      try {
        await FirebaseAuth.instance
            .signInWithEmailLink(email: email, emailLink: link);
      } catch (e) {
        Get.snackbar("Login Error", "Could not complete email link login.",
            backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    }
  }

  Future<void> _loginUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        Get.offAll(() => const HomePage());
      } on FirebaseAuthException catch (e) {
        String errorMessage = switch (e.code) {
          'user-not-found' => 'No user found with this email.',
          'wrong-password' => 'Incorrect password.',
          _ => e.message ?? 'Login failed. Please try again.',
        };
        Get.snackbar("Login Error", errorMessage,
            backgroundColor: Colors.redAccent, colorText: Colors.white);
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _sendSignInLinkToEmail() async {
    final email = _emailController.text.trim();
    if (!email.contains("@")) {
      Get.snackbar("Invalid Email", "Please enter a valid email address.");
      return;
    }

    ActionCodeSettings acs = ActionCodeSettings(
      url: 'https://homebite.page.link/login',
      handleCodeInApp: true,
      androidPackageName: 'com.example.homebite',
      androidInstallApp: true,
      androidMinimumVersion: '21',
    );

    try {
      await FirebaseAuth.instance.sendSignInLinkToEmail(
          email: email, actionCodeSettings: acs);
      Get.snackbar("Email Sent", "Check your email for the login link.",
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Error", e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains("@")) {
      Get.snackbar("Invalid Email", "Enter a valid email to reset password.",
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      Get.snackbar("Reset Link Sent", "Check your email to reset password.",
          backgroundColor: Colors.green, colorText: Colors.white);
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Error", e.message ?? "Something went wrong.",
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    const amber = Color(0xFFFFB300);
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedOpacity(
        duration: const Duration(milliseconds: 600),
        opacity: opacity,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Shimmer.fromColors(
                    baseColor: amber,
                    highlightColor: Colors.white,
                    child: const Icon(Icons.house_rounded,
                        size: 80, color: amber),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Welcome to HomDwell",
                    style: TextStyle(
                      color: amber,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Email
                  TextFormField(
                    controller: _emailController,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      prefixIcon: Icon(Icons.mail_outline, color: amber),
                      labelStyle: TextStyle(color: amber),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: amber, width: 2)),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: amber)),
                    ),
                    validator: (value) =>
                    !value!.contains("@") ? "Enter a valid email." : null,
                  ),

                  const SizedBox(height: 20),

                  // Password
                  TextFormField(
                    controller: _passwordController,
                    style: const TextStyle(color: Colors.white),
                    obscureText: !showPassword,
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon:
                      const Icon(Icons.lock_outline_rounded, color: amber),
                      suffixIcon: IconButton(
                        icon: Icon(
                          showPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: amber,
                        ),
                        onPressed: () =>
                            setState(() => showPassword = !showPassword),
                      ),
                      labelStyle: const TextStyle(color: amber),
                      focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: amber, width: 2)),
                      enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: amber)),
                    ),
                    validator: (value) => value == null || value.length < 8
                        ? "Password must be at least 8 characters."
                        : null,
                  ),

                  const SizedBox(height: 30),

                  // Login Button
                  ElevatedButton.icon(
                    onPressed: isLoading ? null : _loginUser,
                    icon: const Icon(Icons.login, color: Colors.black),
                    label: isLoading
                        ? Shimmer.fromColors(
                      baseColor: Colors.black,
                      highlightColor: Colors.white,
                      child: const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.black, strokeWidth: 2),
                      ),
                    )
                        : const Text("Login",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: amber,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 100, vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Email Link Login
                  TextButton.icon(
                    onPressed: _sendSignInLinkToEmail,
                    icon: const Icon(Icons.link, color: amber),
                    label: const Text("Login with Email Link",
                        style: TextStyle(color: amber)),
                  ),

                  // Forgot Password
                  TextButton.icon(
                    onPressed: _forgotPassword,
                    icon: const Icon(Icons.lock_reset, color: amber),
                    label: const Text("Forgot Password?",
                        style: TextStyle(color: amber)),
                  ),

                  const Divider(color: Colors.grey),
                  const SizedBox(height: 10),

                  // Signup
                  TextButton(
                    onPressed: () => Get.offAll(() => const SignupScreen()),
                    child: const Text("Don't have an account? Sign up",
                        style: TextStyle(
                            color: amber,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
