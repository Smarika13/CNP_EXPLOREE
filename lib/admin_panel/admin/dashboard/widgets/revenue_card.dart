import 'package:flutter/material.dart';

class RevenueCard extends StatelessWidget {
  final int totalRevenue;
  const RevenueCard({super.key, required this.totalRevenue});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text("Total Revenue", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text("\$$totalRevenue", style: TextStyle(fontSize: 20, color: Colors.green)),
          ],
        ),
      ),
    );
  }
}
