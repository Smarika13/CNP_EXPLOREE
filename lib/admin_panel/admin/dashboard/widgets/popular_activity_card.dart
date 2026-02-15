import 'package:flutter/material.dart';

class PopularActivityCard extends StatelessWidget {
  final String activity;
  const PopularActivityCard({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "Most Popular Activity",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              activity,
              style: TextStyle(fontSize: 18, color: Colors.orange[800]),
            ),
          ],
        ),
      ),
    );
  }
}
