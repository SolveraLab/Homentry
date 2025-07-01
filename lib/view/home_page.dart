import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'chat_page.dart';
import 'house_detail_page.dart';
import 'profile_page.dart';
import 'upload_house_page.dart';
import 'utilities_page.dart';
import 'wishlist_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;

  Stream<QuerySnapshot> get houseStream =>
      FirebaseFirestore.instance.collection('houses').snapshots();

  Future<bool> isAgent() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .get();
    return doc.exists && doc['role'] == 'agent';
  }

  Widget buildHouseCard(Map<String, dynamic> houseData) {
    final String uploaderId = houseData['uploaded_by'] ?? '';
    final String imageUrl = houseData['imageUrl'] ?? '';
    final String title = houseData['title'] ?? 'No Title';
    final String location = houseData['location'] ?? '';
    final double price = (houseData['price'] is int)
        ? (houseData['price'] as int).toDouble()
        : (houseData['price'] ?? 0.0) as double;

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(uploaderId).get(),
      builder: (context, snapshot) {
        String uploaderName = "Unknown";
        String uploaderPic = "";

        if (snapshot.hasData && snapshot.data!.exists) {
          final userData = snapshot.data!.data() as Map<String, dynamic>;
          uploaderName = "${userData['first_name'] ?? ''} ${userData['last_name'] ?? ''}".trim();
          uploaderPic = userData['profilePic'] ?? "";
        }

        return GestureDetector(
          onTap: () => _viewDetails(houseData),
          child: Card(
            color: Colors.grey[850],
            elevation: 5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15), topRight: Radius.circular(15)),
                  child: imageUrl.isNotEmpty
                      ? Image.network(imageUrl, fit: BoxFit.cover, width: double.infinity, height: 140)
                      : Container(height: 140, color: Colors.grey[800]),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              color: Color(0xFFFFB300),
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                      Text("GH₵ ${price.toStringAsFixed(2)} · $location",
                          style: const TextStyle(color: Colors.white70)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundImage: uploaderPic.isNotEmpty
                                ? NetworkImage(uploaderPic)
                                : const AssetImage("images/avatar.png") as ImageProvider,
                          ),
                          const SizedBox(width: 6),
                          Text(uploaderName,
                              style: const TextStyle(color: Colors.white60, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget homeContent() => RefreshIndicator(
    onRefresh: () async => setState(() {}),
    child: StreamBuilder<QuerySnapshot>(
      stream: houseStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.amber));
        }

        final docs = snapshot.data!.docs;

        final filteredHouses = docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .where((house) =>
        (house['isActive'] ?? true) &&
            ((house['title'] ?? '')
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()) ||
                (house['location'] ?? '')
                    .toLowerCase()
                    .contains(_searchController.text.toLowerCase())))
            .toList();

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Search by title or location',
                  labelStyle: const TextStyle(color: Colors.amber),
                  prefixIcon: const Icon(Icons.search, color: Colors.amber),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: MasonryGridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  itemCount: filteredHouses.length,
                  itemBuilder: (context, index) =>
                      buildHouseCard(filteredHouses[index]),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );

  @override
  Widget build(BuildContext context) {
    const amber = Color(0xFFFFB300);
    const dark = Colors.black;

    return Scaffold(
      backgroundColor: dark,
      appBar: AppBar(
        title: const Text("HomDwell", style: TextStyle(color: amber)),
        backgroundColor: dark,
        iconTheme: const IconThemeData(color: amber),
      ),
      body: _currentIndex == 0
          ? homeContent()
          : [
        const WishlistPage(),
        const ChatPage(),
        const ProfilePage(),
        const UtilitiesPage(),
      ][_currentIndex - 1],
      floatingActionButton: _currentIndex == 0
          ? FutureBuilder<bool>(
        future: isAgent(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done ||
              !snapshot.hasData ||
              !snapshot.data!) {
            return const SizedBox.shrink();
          }
          return FloatingActionButton.extended(
            onPressed: () => Get.to(() => const UploadHousePage()),
            backgroundColor: amber,
            icon: const FaIcon(FontAwesomeIcons.plus, color: Colors.black),
            label: const Text("Add House",
                style: TextStyle(color: Colors.black)),
          );
        },
      )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: Colors.black,
        selectedItemColor: amber,
        unselectedItemColor: Colors.grey[600],
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.house), label: 'Home'),
          BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.heart), label: 'Wishlist'),
          BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.comments), label: 'Chat'),
          BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.user), label: 'Profile'),
          BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.toolbox), label: 'Utility'),
        ],
      ),
    );
  }

  void _viewDetails(Map<String, dynamic> houseData) {
    Get.to(() => HouseDetailPage(houseData: houseData));
  }
}
