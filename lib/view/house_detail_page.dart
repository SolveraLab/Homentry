import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shimmer/shimmer.dart';

class HouseDetailPage extends StatelessWidget {
  final Map<String, dynamic> houseData;
  const HouseDetailPage({super.key, required this.houseData});

  @override
  Widget build(BuildContext context) {
    const amber = Color(0xFFFFB300);

    final String title = houseData['title'] ?? 'No Title';
    final String location = houseData['location'] ?? 'Unknown';
    final String description = houseData['description'] ?? 'No description';
    final String imageUrl = houseData['imageUrl'] ?? '';
    final double price = (houseData['price'] is int)
        ? (houseData['price'] as int).toDouble()
        : (houseData['price'] ?? 0.0) as double;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: amber,
        foregroundColor: Colors.black,
        title: Text(title),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ Image with shimmer placeholder
                imageUrl.isNotEmpty
                    ? SizedBox(
                  height: 250,
                  width: double.infinity,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Shimmer.fromColors(
                        baseColor: Colors.grey[800]!,
                        highlightColor: Colors.grey[600]!,
                        child: Container(
                          height: 250,
                          color: Colors.grey[800],
                        ),
                      );
                    },
                  ),
                )
                    : Container(height: 250, color: Colors.grey[800]),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(FontAwesomeIcons.home, size: 16, color: amber),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                  color: amber,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(FontAwesomeIcons.coins,
                              size: 16, color: Colors.white70),
                          const SizedBox(width: 8),
                          Text("GH₵ ${price.toStringAsFixed(2)}",
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 18)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: amber),
                          const SizedBox(width: 6),
                          Text(location,
                              style: const TextStyle(
                                  color: Colors.white60, fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text("Description",
                          style: TextStyle(
                              color: amber,
                              fontSize: 20,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text(description,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 16)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ✅ Request for Viewing Button
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Viewing request sent!'),
                  backgroundColor: amber,
                ));
              },
              icon: const Icon(Icons.calendar_today, color: Colors.black),
              label: const Text("Request for Viewing",
                  style: TextStyle(color: Colors.black)),
              style: ElevatedButton.styleFrom(
                backgroundColor: amber,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
