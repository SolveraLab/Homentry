import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:homdwell/view/house_detail_page.dart';

class MyUploadPage extends StatelessWidget {
  final Color amber = const Color(0xFFFFB300);

  /// 🔁 Reusable text field builder
  Widget _editField(
      String label,
      String initialValue,
      FormFieldSetter<String> onSaved, {
        TextInputType inputType = TextInputType.text,
        List<TextInputFormatter>? inputFormatters,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        initialValue: initialValue,
        keyboardType: inputType,
        inputFormatters: inputFormatters,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.amber),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.amber),
          ),
        ),
        validator: (val) => val == null || val.isEmpty ? "Required" : null,
        onSaved: onSaved,
      ),
    );
  }

  /// ✏️ Edit house info popup
  Future<void> _editHouse(
      BuildContext context,
      String docId,
      Map<String, dynamic> currentData,
      ) async {
    final formKey = GlobalKey<FormState>();
    String title = currentData['title'] ?? '';
    String price = currentData['price']?.toString() ?? '';
    String location = currentData['location'] ?? '';

    await Get.dialog(
      AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text("Edit House Details", style: TextStyle(color: amber)),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _editField("Title", title, (val) => title = val!),
              _editField("Price", price, (val) => price = val!,
                  inputType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
              _editField("Location", location, (val) => location = val!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel", style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: amber),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                try {
                  await FirebaseFirestore.instance
                      .collection('houses')
                      .doc(docId)
                      .update({
                    'title': title,
                    'price': double.tryParse(price) ?? 0, // ✅ Save as number
                    'location': location,
                  });
                  Get.back();
                  Get.snackbar("Updated", "House details updated",
                      backgroundColor: Colors.green, colorText: Colors.white);
                } catch (e) {
                  Get.snackbar("Error", e.toString(),
                      backgroundColor: Colors.red, colorText: Colors.white);
                }
              }
            },
            child: const Text("Save", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  /// ❌ Delete listing
  Future<void> _deleteHouse(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('houses').doc(docId).delete();
      Get.snackbar("Deleted", "House removed successfully",
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Error", e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  /// 👁 Toggle visibility
  Future<void> _toggleActivation(String docId, bool currentState) async {
    try {
      await FirebaseFirestore.instance
          .collection('houses')
          .doc(docId)
          .update({'isActive': !currentState});
      Get.snackbar(
        currentState ? "Deactivated" : "Reactivated",
        "Listing is now ${currentState ? 'hidden' : 'visible'} on Home",
        backgroundColor: currentState ? Colors.orange : Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar("Error", e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("My Uploads"),
        backgroundColor: amber,
        foregroundColor: Colors.black,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('houses')
            .where('uploaded_by', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.amber),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No uploads yet",
                  style: TextStyle(color: Colors.white70)),
            );
          }

          final houses = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: houses.length,
            itemBuilder: (context, index) {
              final data = houses[index].data() as Map<String, dynamic>;
              final docId = houses[index].id;
              final bool isActive = data['isActive'] ?? true;

              // 🧠 Ensure price is safely parsed as num
              final num price = (data['price'] is String)
                  ? num.tryParse(data['price']) ?? 0
                  : data['price'] ?? 0;

              return Card(
                color: Colors.grey[900],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  children: [
                    ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          data['imageUrl'] ?? '',
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image,
                              color: Colors.grey),
                        ),
                      ),
                      title: Text(data['title'] ?? 'No Title',
                          style: const TextStyle(color: Colors.white)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 💰 Safe price display with 2 decimal places
                          Text("GHS ${price.toStringAsFixed(2)}",
                              style: TextStyle(color: amber)),
                          const SizedBox(height: 4),
                          Text(
                            isActive ? "Active" : "Deactivated",
                            style: TextStyle(
                              color: isActive ? Colors.green : Colors.orange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      onTap: () => Get.to(() => HouseDetailPage(houseData: data)),
                    ),

                    // ✅ Horizontal action icons
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.amber),
                            onPressed: () => _editHouse(context, docId, data),
                            tooltip: "Edit",
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () async {
                              final confirm = await showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  backgroundColor: Colors.grey[900],
                                  title: Text("Confirm Delete", style: TextStyle(color: amber)),
                                  content: const Text(
                                    "Do you really want to delete this listing?",
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text("Delete", style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) _deleteHouse(docId);
                            },
                            tooltip: "Delete",
                          ),
                          IconButton(
                            icon: Icon(
                              isActive ? Icons.visibility_off : Icons.visibility,
                              color: isActive ? Colors.orange : Colors.greenAccent,
                            ),
                            onPressed: () => _toggleActivation(docId, isActive),
                            tooltip: isActive ? "Deactivate" : "Activate",
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
