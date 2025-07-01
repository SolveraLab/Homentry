import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WishlistPage extends StatelessWidget {
  const WishlistPage({Key? key}) : super(key: key);

  Future<void> _removeFromWishlist(String docId) async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('wishlist')
          .doc(docId)
          .delete();

      Get.snackbar("Removed", "House removed from wishlist",
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Error", "Failed to remove: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final deepAmber = const Color(0xFFFFB300);

    if (user == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            "Please log in to view your wishlist.",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("My Wishlist"),
        backgroundColor: deepAmber,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('wishlist')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.amber));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No houses in your wishlist yet.",
                style: TextStyle(color: Colors.white54, fontSize: 16),
              ),
            );
          }

          final wishlistItems = snapshot.data!.docs;

          return ListView.builder(
            itemCount: wishlistItems.length,
            itemBuilder: (context, index) {
              final data = wishlistItems[index].data() as Map<String, dynamic>;
              final docId = wishlistItems[index].id;

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: deepAmber.withOpacity(0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      data['imageUrl'],
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey,
                        width: 70,
                        height: 70,
                        child: const Icon(Icons.image_not_supported, color: Colors.black54),
                      ),
                    ),
                  ),
                  title: Text(
                    data['title'],
                    style: const TextStyle(
                      color: Colors.amberAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    "GH₵ ${data['price']} · ${data['location']}",
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent),
                    onPressed: () => _removeFromWishlist(docId),
                    tooltip: "Remove",
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
