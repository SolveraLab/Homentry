import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shimmer/shimmer.dart';

class UploadHousePage extends StatefulWidget {
  const UploadHousePage({super.key});

  @override
  State<UploadHousePage> createState() => _UploadHousePageState();
}

class _UploadHousePageState extends State<UploadHousePage> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _price = TextEditingController();
  final _location = TextEditingController();
  final _description = TextEditingController();
  List<File> _pickedImages = [];
  File? _pickedVideo;
  bool isLoading = true;
  bool isAgentApproved = false;

  final amber = const Color(0xFFFFB300);

  Future<void> _fetchUserRole() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance.collection("users").doc(uid).get();
    if (doc.exists && doc.data() != null) {
      final status = doc.data()!["agent_status"] ?? "none";
      setState(() {
        isAgentApproved = status == "approved";
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage();
    if (picked.isNotEmpty) {
      setState(() => _pickedImages = picked.map((x) => File(x.path)).toList());
    }
  }

  Future<void> _pickVideo() async {
    final picked = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _pickedVideo = File(picked.path));
    }
  }

  Future<String> _uploadToCloudinary(File file, {bool isVideo = false}) async {
    final uri = Uri.parse("https://api.cloudinary.com/v1_1/ddbcmdxu8/${isVideo ? 'video' : 'image'}/upload");

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = 'flutter_upload'
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();
    final responseData = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return jsonDecode(responseData)['secure_url'];
    } else {
      throw Exception('Upload failed: ${jsonDecode(responseData)['error']['message']}');
    }
  }

  Future<void> _uploadHouse() async {
    if (_formKey.currentState!.validate() && _pickedImages.isNotEmpty) {
      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(child: CircularProgressIndicator(color: Colors.amber)),
        );

        final uid = FirebaseAuth.instance.currentUser!.uid;

        // Upload images
        List<String> uploadedImageUrls = [];
        for (final image in _pickedImages) {
          final url = await _uploadToCloudinary(image);
          uploadedImageUrls.add(url);
        }

        // Upload video (optional)
        String? videoUrl;
        if (_pickedVideo != null) {
          videoUrl = await _uploadToCloudinary(_pickedVideo!, isVideo: true);
        }

        final newHouse = {
          'title': _title.text.trim(),
          'price': _price.text.trim(),
          'location': _location.text.trim(),
          'description': _description.text.trim(),
          'images': uploadedImageUrls,
          'videoUrl': videoUrl,
          'uploaded_by': uid,
          'isActive': true,
          'timestamp': FieldValue.serverTimestamp(),
        };

        await FirebaseFirestore.instance.collection('houses').add(newHouse);

        Navigator.pop(context);
        Get.back();
        Get.snackbar("Success", "House uploaded successfully",
            backgroundColor: Colors.green, colorText: Colors.white);
      } catch (e) {
        Navigator.pop(context);
        Get.snackbar("Upload Failed", e.toString(),
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } else {
      Get.snackbar("Missing Info", "Fill the form and select at least one image.",
          backgroundColor: Colors.orange, colorText: Colors.white);
    }
  }

  InputDecoration fieldStyle(String label, IconData icon) => InputDecoration(
    labelText: label,
    labelStyle: TextStyle(color: amber),
    prefixIcon: Icon(icon, color: amber),
    enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: amber), borderRadius: BorderRadius.circular(10)),
    focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: amber, width: 2), borderRadius: BorderRadius.circular(10)),
  );

  Widget shimmerBox({double height = 120}) => Shimmer.fromColors(
    baseColor: Colors.grey.shade800,
    highlightColor: Colors.grey.shade600,
    child: Container(
      height: height,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: amber)),
      );
    }

    if (!isAgentApproved) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text("Only approved agents can upload houses.",
              style: TextStyle(color: amber, fontSize: 16)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Upload New House"),
        backgroundColor: amber,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _title,
                style: const TextStyle(color: Colors.white),
                decoration: fieldStyle("Title", Icons.title),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _price,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: fieldStyle("Price (GHS)", Icons.monetization_on),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _location,
                style: const TextStyle(color: Colors.white),
                decoration: fieldStyle("Location", Icons.location_on),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _description,
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
                decoration: fieldStyle("Description", Icons.description),
              ),
              const SizedBox(height: 20),

              // Images
              ElevatedButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.image_outlined, color: Colors.black),
                label: const Text("Pick Multiple Images", style: TextStyle(color: Colors.black)),
                style: ElevatedButton.styleFrom(backgroundColor: amber),
              ),
              const SizedBox(height: 10),
              _pickedImages.isNotEmpty
                  ? SizedBox(
                height: 130,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: _pickedImages
                      .map((img) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(img, height: 120, width: 160, fit: BoxFit.cover),
                    ),
                  ))
                      .toList(),
                ),
              )
                  : Column(children: [shimmerBox(), shimmerBox(), shimmerBox()]),

              const SizedBox(height: 20),

              // Video (optional)
              ElevatedButton.icon(
                onPressed: _pickVideo,
                icon: const Icon(Icons.videocam_outlined, color: Colors.black),
                label: const Text("Upload Optional Video", style: TextStyle(color: Colors.black)),
                style: ElevatedButton.styleFrom(backgroundColor: amber),
              ),
              const SizedBox(height: 10),
              _pickedVideo != null
                  ? Text("🎥 Video Selected: ${_pickedVideo!.path.split('/').last}",
                  style: const TextStyle(color: Colors.white70))
                  : shimmerBox(height: 30),

              const SizedBox(height: 30),

              ElevatedButton.icon(
                onPressed: _uploadHouse,
                icon: const Icon(Icons.cloud_upload_outlined, color: Colors.black),
                label: const Text("Upload House", style: TextStyle(color: Colors.black)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: amber,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
