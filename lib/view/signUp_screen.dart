import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// Import Firebase packages
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';  // <-- Added Firestore import
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // Controllers for form fields
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
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.pinkAccent, Colors.amberAccent],
              begin: FractionalOffset(0, 0),
              end: FractionalOffset(1, 0),
              stops: [0, 1],
              tileMode: TileMode.clamp,
            ),
          ),
        ),
        title: const Text('Create HomeBite Account'),
      ),
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
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 25, right: 25),
              child: Image.asset(
                "images/key.png",
                width: 50,
              ),
            ),
            const Text(
              "SignUp Here, Please.",
              style: TextStyle(
                fontSize: 30.0,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField("First Name", _firstNameTextEditingController),
                    _buildTextField("Last Name", _surnameTextEditingController),
                    _buildTextField("Email", _emailTextEditingController, isEmail: true),
                    _buildTextField("Password", _passwordTextEditingController, isPassword: true),
                    _buildTextField("City", _cityTextEditingController),
                    _buildTextField("Region", _regionTextEditingController),
                    // Optional: Include Bio field if needed
                    _buildTextField("Bio", _bioTextEditingController),
                    const SizedBox(height: 30),
                    MaterialButton(
                      onPressed: () {
                        // TODO: Implement image picker functionality if needed
                      },
                      child: imageFileOfUser == null
                          ? const Icon(Icons.add_a_photo, size: 50)
                          : CircleAvatar(
                        backgroundColor: Colors.blueAccent,
                        radius: MediaQuery.of(context).size.width / 5.0,
                        child: CircleAvatar(
                          backgroundImage: FileImage(imageFileOfUser!),
                          radius: MediaQuery.of(context).size.width / 5.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _handleSignup,
                      icon: const Icon(Icons.person_add),
                      label: const Text(
                        'Create Account',
                        style: TextStyle(fontSize: 18),
                      ),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blueAccent,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build a text field with validation
  Widget _buildTextField(String label, TextEditingController controller,
      {bool isEmail = false, bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(top: 26),
      child: TextFormField(
        decoration: InputDecoration(labelText: label),
        obscureText: isPassword,
        style: const TextStyle(fontSize: 24),
        controller: controller,
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

  // Updated signup function that uses FirebaseAuth and saves extra profile info to Firestore
  void _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Show a loading dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(child: CircularProgressIndicator()),
        );

        // Create a new user with Firebase Authentication
        final auth = FirebaseAuth.instance;
        UserCredential userCredential = await auth.createUserWithEmailAndPassword(
          email: _emailTextEditingController.text.trim(),
          password: _passwordTextEditingController.text.trim(),
        );

        // Save additional user profile data to Firestore (excluding the password!)
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'uid': userCredential.user!.uid,
          'first_name': _firstNameTextEditingController.text.trim(),
          'last_name': _surnameTextEditingController.text.trim(),
          'email': _emailTextEditingController.text.trim(),
          'city': _cityTextEditingController.text.trim(),
          'region': _regionTextEditingController.text.trim(),
          'bio': _bioTextEditingController.text.trim(),
          'created_at': FieldValue.serverTimestamp(),
        });

        // Close the loading dialog
        Navigator.pop(context);

        // Show success message and navigate to the Login screen
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
