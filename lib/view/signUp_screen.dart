import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailTextEditingController = TextEditingController();
  final TextEditingController _passwordTextEditingController = TextEditingController();
  final TextEditingController _firstNameTextEditingController = TextEditingController();
  final TextEditingController _surnameTextEditingController = TextEditingController();
  final TextEditingController _cityTextEditingController = TextEditingController();
  final TextEditingController _regionTextEditingController = TextEditingController();
  final TextEditingController _bioTextEditingController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  File? imageFileOfUser;

  @override
  void dispose() {
    _emailTextEditingController.dispose();
    _passwordTextEditingController.dispose();
    _firstNameTextEditingController.dispose();
    _surnameTextEditingController.dispose();
    _cityTextEditingController.dispose();
    _regionTextEditingController.dispose();
    _bioTextEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Create HomeBite Account'),
        backgroundColor: Colors.amber[700],
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 10),
              Center(
                child: Image.asset(
                  "images/key.png",
                  width: 80,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Sign Up Here",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.amber),
              ),
              const SizedBox(height: 25),

              // First and Last Name side-by-side
              Row(
                children: [
                  Expanded(child: _buildTextField("First Name", _firstNameTextEditingController)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTextField("Last Name", _surnameTextEditingController)),
                ],
              ),
              _buildTextField("Email", _emailTextEditingController, isEmail: true),
              _buildTextField("Password", _passwordTextEditingController, isPassword: true),
              _buildTextField("City", _cityTextEditingController),
              _buildTextField("Region", _regionTextEditingController),
              _buildTextField("Bio", _bioTextEditingController),

              const SizedBox(height: 20),

              // Profile Image (can implement later)
              Center(
                child: GestureDetector(
                  onTap: () {
                    // Optional: implement image picking
                  },
                  child: imageFileOfUser == null
                      ? const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.add_a_photo, color: Colors.white),
                  )
                      : CircleAvatar(
                    radius: 50,
                    backgroundImage: FileImage(imageFileOfUser!),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              ElevatedButton.icon(
                onPressed: _handleSignup,
                icon: const Icon(Icons.person_add),
                label: const Text('Create Account', style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[700],
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool isEmail = false, bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.amber),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.amber),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.amberAccent, width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        validator: (text) {
          if (text == null || text.isEmpty) {
            return "Please enter your $label.";
          }
          if (isEmail && !text.contains("@")) {
            return "Please enter a valid email.";
          }
          if (isPassword && text.length < 8) {
            return "Password should be at least 8 characters.";
          }
          return null;
        },
      ),
    );
  }

  void _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(child: CircularProgressIndicator()),
        );

        final auth = FirebaseAuth.instance;
        UserCredential userCredential = await auth.createUserWithEmailAndPassword(
          email: _emailTextEditingController.text.trim(),
          password: _passwordTextEditingController.text.trim(),
        );

        final uid = userCredential.user!.uid;

        await FirebaseFirestore.instance.collection('user').doc(uid).set({
          'uid': uid,
          'first_name': _firstNameTextEditingController.text.trim(),
          'last_name': _surnameTextEditingController.text.trim(),
          'email': _emailTextEditingController.text.trim(),
          'city': _cityTextEditingController.text.trim(),
          'region': _regionTextEditingController.text.trim(),
          'bio': _bioTextEditingController.text.trim(),
          'profilePic': "", // default empty string
          'role': "user", // default role
          'created_at': FieldValue.serverTimestamp(),
        });

        Navigator.pop(context);
        Get.snackbar("Success", "Account created successfully 🎉",
            backgroundColor: Colors.green, colorText: Colors.white);
        Get.off(() => const LoginScreen());
      } on FirebaseAuthException catch (e) {
        Navigator.pop(context);
        Get.snackbar("Signup Failed", e.message ?? "Something went wrong",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    }
  }
}
