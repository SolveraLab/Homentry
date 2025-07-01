import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _pickedImage;
  final deepAmber = const Color(0xFFFFB300);
  String agentStatus = '';
  bool loadingStatus = true;
  final user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _pickedImage = File(picked.path));
      await _uploadProfilePicToCloudinary(_pickedImage!);
    }
  }

  Future<void> _uploadProfilePicToCloudinary(File image) async {
    try {
      const uploadPreset = 'flutter_upload';
      final uri = Uri.parse("https://api.cloudinary.com/v1_1/ddbcmdxu8/image/upload");

      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', image.path));

      final streamedResponse = await request.send();
      final responseData = await streamedResponse.stream.bytesToString();
      final responseJson = jsonDecode(responseData);

      if (streamedResponse.statusCode == 200) {
        final imageUrl = responseJson['secure_url'];
        await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
          'profilePic': imageUrl
        }, SetOptions(merge: true));
        await _fetchUserData();
        Get.snackbar("Success", "Profile picture updated successfully.",
            backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        final errorMessage = responseJson['error']['message'] ?? "Unknown error";
        Get.snackbar("Upload Failed", errorMessage,
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Error", e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Get.offAllNamed('/login');
  }

  Future<void> _resetPassword() async {
    if (user?.email != null) {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: user!.email!);
        Get.snackbar("Email Sent", "Check ${user!.email} to reset password",
            backgroundColor: Colors.green, colorText: Colors.white);
      } catch (e) {
        Get.snackbar("Error", e.toString(),
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    }
  }

  Future<void> _checkAgentStatus() async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
    if (doc.exists && doc.data()!.containsKey('agent_status')) {
      setState(() => agentStatus = doc['agent_status']);
    } else {
      setState(() => agentStatus = 'none');
    }
    loadingStatus = false;
  }

  Future<void> _fetchUserData() async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
    if (doc.exists) {
      setState(() {
        userData = doc.data();
      });
    }
  }

  Future<void> _applyAsAgent() async {
    final formKey = GlobalKey<FormState>();
    String firstName = '', lastName = '', city = '', region = '';

    await Get.dialog(
      AlertDialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        title: const Text("Agent Application", style: TextStyle(color: Colors.amber)),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _agentField("First Name", (v) => firstName = v!),
                _agentField("Last Name", (v) => lastName = v!),
                _agentField("City", (v) => city = v!),
                _agentField("Region", (v) => region = v!),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel", style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
                  'first_name': firstName,
                  'last_name': lastName,
                  'city': city,
                  'region': region,
                  'role': 'agent',
                  'agent_status': 'pending',
                }, SetOptions(merge: true));
                setState(() => agentStatus = 'pending');
                Get.back();
                Get.snackbar("Submitted", "Your agent request has been sent for review.",
                    backgroundColor: Colors.green, colorText: Colors.white);
              }
            },
            child: const Text("Submit", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Widget _agentField(String label, FormFieldSetter<String> onSaved) {
    return TextFormField(
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(color: Colors.amber)),
      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
      onSaved: onSaved,
    );
  }

  Widget _buildTile({required IconData icon, required String title, required String subtitle, Color iconColor = const Color(0xFFFFB300), VoidCallback? onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      leading: Icon(icon, color: iconColor),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white54)),
      onTap: onTap,
    );
  }

  @override
  void initState() {
    super.initState();
    _checkAgentStatus();
    _fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Account"),
        backgroundColor: deepAmber,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: loadingStatus
          ? const Center(child: CircularProgressIndicator(color: Colors.amber))
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.white,
                      backgroundImage: _pickedImage != null
                          ? FileImage(_pickedImage!)
                          : (userData != null && userData!['profilePic'] != null)
                          ? NetworkImage(userData!['profilePic'])
                          : const NetworkImage("https://ui-avatars.com/api/?name=User&background=ffb300&color=000000") as ImageProvider,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          decoration: BoxDecoration(color: Colors.black, shape: BoxShape.circle, border: Border.all(color: deepAmber, width: 2)),
                          padding: const EdgeInsets.all(6),
                          child: Icon(Icons.edit, size: 16, color: deepAmber),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                Text(userData?['name'] ?? "User", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                Text(user!.email ?? "email@example.com", style: const TextStyle(color: Colors.white54)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text("Account Settings", style: TextStyle(color: Colors.white60)),
          const SizedBox(height: 10),

// Removed Address, My Cart, My Orders
          _buildTile(icon: Icons.payment_outlined, title: "Payment History", subtitle: "Check your previous payments"),
          if (agentStatus == 'approved') ...[
            _buildTile(
              icon: Icons.cloud_outlined,
              title: "My Uploads",
              subtitle: "Modify or remove your house",
              onTap: () => Get.toNamed("/my_upload"),
            ),
            _buildTile(
              icon: Icons.cloud_upload_outlined,
              title: "Upload House",
              subtitle: "Upload house details to our map",
              onTap: () => Get.toNamed("/upload_house"),
            ),
          ],
          _buildTile(icon: Icons.lock_outline, title: "Account Privacy", subtitle: "Manage data usage and connected accounts"),
          _buildTile(icon: Icons.lock_reset, title: "Reset Password", subtitle: "Send password reset email", onTap: _resetPassword),
          _buildTile(icon: Icons.logout, title: "Logout", subtitle: "Sign out of your account", iconColor: Colors.redAccent, onTap: _logout),

          const SizedBox(height: 10),
          if (agentStatus == 'none')
            ElevatedButton.icon(
              onPressed: _applyAsAgent,
              icon: const Icon(Icons.badge_outlined, color: Colors.black),
              label: const Text("Apply to be an Agent", style: TextStyle(color: Colors.black)),
              style: ElevatedButton.styleFrom(
                backgroundColor: deepAmber,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            )
          else if (agentStatus == 'pending')
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(10)),
              child: const Row(
                children: [
                  Icon(Icons.hourglass_empty, color: Colors.amber),
                  SizedBox(width: 10),
                  Expanded(child: Text("Your agent request is under review.", style: TextStyle(color: Colors.white70))),
                ],
              ),
            )
          else if (agentStatus == 'approved')
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.green[900], borderRadius: BorderRadius.circular(10)),
                child: const Row(
                  children: [
                    Icon(Icons.verified, color: Colors.greenAccent),
                    SizedBox(width: 10),
                    Expanded(child: Text("You are now verified as an Agent.", style: TextStyle(color: Colors.white))),
                  ],
                ),
              )
        ],
      ),
    );
  }
}
