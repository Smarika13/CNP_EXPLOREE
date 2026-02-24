import 'package:flutter/material.dart';

class AnimalDetailPage extends StatelessWidget {
  final Map<String, dynamic> animal;

  const AnimalDetailPage({super.key, required this.animal});

  @override
  Widget build(BuildContext context) {
    // This line tries all common names. If 'mainImg' is empty, it tries 'imageUrl', etc.
    String imagePath = animal['mainImg'] ?? animal['imageUrl'] ?? animal['imagePath'] ?? '';
    
    bool isNetworkImage = imagePath.startsWith('http');

    return Scaffold(
      appBar: AppBar(
        title: Text(animal['name'] ?? 'Details'),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 300,
              width: double.infinity,
              child: imagePath.isEmpty 
                ? _buildStatusBox("No Image Path Found", Colors.orange)
                : isNetworkImage
                    ? Image.network(
                        imagePath,
                        fit: BoxFit.cover,
                        // This handles the 404 error from your logs
                        errorBuilder: (context, error, stackTrace) => 
                            _buildStatusBox("Network Error: 404\nLink is broken", Colors.red),
                      )
                    : Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                        // This handles the "Asset not found" error
                        errorBuilder: (context, error, stackTrace) => 
                            _buildStatusBox("Asset Not Found:\nCheck your folder/pubspec", Colors.blue),
                      ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    animal['name'] ?? 'Unknown',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  Text("Category: ${animal['category'] ?? 'N/A'}"),
                  const SizedBox(height: 20),
                  const Text("Description", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(animal['description'] ?? "No description provided."),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // A clear box to tell you EXACTLY what is wrong on the screen
  Widget _buildStatusBox(String message, Color color) {
    return Container(
      color: color.withOpacity(0.2),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}