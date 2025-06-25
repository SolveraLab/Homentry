import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// ================= MODEL =================
class HouseModel {
        final String title, price, location, description, imageUrl;
        HouseModel({
                required this.title,
                required this.price,
                required this.location,
                required this.description,
                required this.imageUrl,
        });

        Map<String, dynamic> toMap() => {
                'title': title,
                'price': price,
                'location': location,
                'description': description,
                'imageUrl': imageUrl,
        };

        factory HouseModel.fromMap(Map<String, dynamic> map) => HouseModel(
                title: map['title'],
                price: map['price'],
                location: map['location'],
                description: map['description'],
                imageUrl: map['imageUrl'],
        );
}

// ================= MAIN PAGE =================
class HomePage extends StatefulWidget {
        const HomePage({super.key});
        @override
        State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
        int _currentIndex = 0;
        List<HouseModel> houses = [];

        @override
        void initState() {
                super.initState();
                fetchHouses();
        }

        Future<void> fetchHouses() async {
                final snapshot = await FirebaseFirestore.instance.collection('houses').get();
                final data = snapshot.docs.map((doc) => HouseModel.fromMap(doc.data())).toList();
                setState(() => houses = data);
        }

        // ========== BOTTOM NAV PAGES ==========
        final List<Widget> _pages = [
                // HOME
                Builder(
                        builder: (context) {
                                return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: MasonryGridView.count(
                                                crossAxisCount: 2,
                                                mainAxisSpacing: 8,
                                                crossAxisSpacing: 8,
                                                itemCount: 0, // dummy placeholder
                                                itemBuilder: (_, __) => const SizedBox(),
                                        ),
                                );
                        },
                ),
                const WishlistPage(),
                const ChatPage(),
                const ProfilePage(),
        ];

        @override
        Widget build(BuildContext context) {
                // Home page content
                Widget homeContent = Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: MasonryGridView.count(
                                crossAxisCount: 2,
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 8,
                                itemCount: houses.length,
                                itemBuilder: (context, index) {
                                        final house = houses[index];
                                        return Card(
                                                elevation: 5,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                                child: Stack(
                                                        children: [
                                                                ClipRRect(
                                                                        borderRadius: BorderRadius.circular(15),
                                                                        child: Image.network(
                                                                                house.imageUrl,
                                                                                fit: BoxFit.cover,
                                                                                height: double.infinity,
                                                                                width: double.infinity,
                                                                                loadingBuilder: (context, child, progress) =>
                                                                                progress == null ? child : const Center(child: CircularProgressIndicator()),
                                                                        ),
                                                                ),
                                                                Positioned(
                                                                        bottom: 0,
                                                                        left: 0,
                                                                        right: 0,
                                                                        child: Container(
                                                                                padding: const EdgeInsets.all(8),
                                                                                decoration: BoxDecoration(
                                                                                        color: Colors.black.withOpacity(0.5),
                                                                                        borderRadius: const BorderRadius.only(
                                                                                                bottomLeft: Radius.circular(15),
                                                                                                bottomRight: Radius.circular(15),
                                                                                        ),
                                                                                ),
                                                                                child: Column(
                                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                                        children: [
                                                                                                Text(house.title,
                                                                                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                                                                                Text("GH₵ ${house.price} · ${house.location}",
                                                                                                    style: const TextStyle(color: Colors.white70)),
                                                                                        ],
                                                                                ),
                                                                        ),
                                                                )
                                                        ],
                                                ),
                                        );
                                },
                        ),
                );

                return Scaffold(
                        appBar: AppBar(
                                title: const Text("HomeBite"),
                                backgroundColor: Colors.blueAccent,
                                actions: [
                                        IconButton(
                                                icon: const Icon(Icons.add_box_rounded),
                                                onPressed: () => Get.to(() => const UploadHousePage()),
                                        ),
                                        IconButton(
                                                icon: const Icon(Icons.logout),
                                                onPressed: () async {
                                                        await FirebaseAuth.instance.signOut();
                                                        Get.offAllNamed('/login');
                                                },
                                        ),
                                ],
                        ),
                        body: _currentIndex == 0 ? homeContent : _pages[_currentIndex],
                        bottomNavigationBar: BottomNavigationBar(
                                currentIndex: _currentIndex,
                                selectedItemColor: Colors.blueAccent,
                                unselectedItemColor: Colors.grey,
                                onTap: (index) => setState(() => _currentIndex = index),
                                items: const [
                                        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                                        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Wishlist'),
                                        BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: 'Chat'),
                                        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
                                ],
                        ),
                );
        }
}

// ==================== OTHER PAGES ====================
class WishlistPage extends StatelessWidget {
        const WishlistPage({super.key});
        @override
        Widget build(BuildContext context) {
                return const Center(child: Text("Wishlist Page"));
        }
}

class ChatPage extends StatelessWidget {
        const ChatPage({super.key});
        @override
        Widget build(BuildContext context) {
                return const Center(child: Text("Chat Page"));
        }
}

class ProfilePage extends StatelessWidget {
        const ProfilePage({super.key});
        @override
        Widget build(BuildContext context) {
                return const Center(child: Text("Profile Page"));
        }
}

// ==================== UPLOAD PAGE ====================
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
        File? _pickedImage;

        Future<void> _pickImage() async {
                final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
                if (picked != null) setState(() => _pickedImage = File(picked.path));
        }

        Future<String> _uploadToCloudinary(File image) async {
                const cloudName = 'ddbcmdxu8';
                const uploadPreset = 'Houses';
                final uri = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");
                final request = http.MultipartRequest('POST', uri)
                        ..fields['upload_preset'] = uploadPreset
                        ..files.add(await http.MultipartFile.fromPath('file', image.path));
                final response = await request.send();
                final responseData = await response.stream.bytesToString();
                final json = jsonDecode(responseData);
                return json['secure_url'];
        }

        Future<void> _uploadHouse() async {
                if (_formKey.currentState!.validate() && _pickedImage != null) {
                        try {
                                showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
                                final imageUrl = await _uploadToCloudinary(_pickedImage!);
                                final house = HouseModel(
                                        title: _title.text,
                                        price: _price.text,
                                        location: _location.text,
                                        description: _description.text,
                                        imageUrl: imageUrl,
                                );
                                await FirebaseFirestore.instance.collection('houses').add(house.toMap());
                                Navigator.pop(context);
                                Get.back();
                                Get.snackbar("Success", "House uploaded successfully",
                                    backgroundColor: Colors.green, colorText: Colors.white);
                        } catch (e) {
                                Navigator.pop(context);
                                Get.snackbar("Error", "Upload failed: $e", backgroundColor: Colors.red, colorText: Colors.white);
                        }
                }
        }

        @override
        Widget build(BuildContext context) {
                return Scaffold(
                        appBar: AppBar(title: const Text("Upload New House"), backgroundColor: Colors.blueAccent),
                        body: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Form(
                                        key: _formKey,
                                        child: ListView(
                                                children: [
                                                        TextFormField(controller: _title, decoration: const InputDecoration(labelText: "Title"), validator: (v) => v!.isEmpty ? "Required" : null),
                                                        TextFormField(controller: _price, decoration: const InputDecoration(labelText: "Price (GHS)"), validator: (v) => v!.isEmpty ? "Required" : null),
                                                        TextFormField(controller: _location, decoration: const InputDecoration(labelText: "Location"), validator: (v) => v!.isEmpty ? "Required" : null),
                                                        TextFormField(controller: _description, decoration: const InputDecoration(labelText: "Description"), maxLines: 3),
                                                        const SizedBox(height: 20),
                                                        ElevatedButton.icon(onPressed: _pickImage, icon: const Icon(Icons.image), label: const Text("Pick Image")),
                                                        const SizedBox(height: 20),
                                                        ElevatedButton.icon(onPressed: _uploadHouse, icon: const Icon(Icons.upload_file), label: const Text("Upload to Cloudinary")),
                                                ],
                                        ),
                                ),
                        ),
                );
        }
}
