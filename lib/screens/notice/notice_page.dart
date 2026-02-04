import 'package:flutter/material.dart';

class NoticePage extends StatelessWidget {
  const NoticePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F5),

        body: Column(
          children: [
            const SizedBox(height: 16),

            // Top TabBar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: const TabBar(
                labelColor: Color(0xFF4FBF26),
                unselectedLabelColor: Colors.black54,
                indicatorColor: Color(0xFF4FBF26),
                tabs: [
                  Tab(icon: Icon(Icons.notifications), text: "Notifications"),
                  Tab(icon: Icon(Icons.newspaper), text: "News"),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Tab content
            Expanded(
              child: TabBarView(
                children: [
                  // Notifications
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: const [
                      Card(
                        child: ListTile(
                          leading: Icon(Icons.notifications,
                              color: Color(0xFF4FBF26)),
                          title: Text("Booking Confirmed"),
                          subtitle:
                          Text("Your Jeep Safari booking is confirmed."),
                        ),
                      ),
                      Card(
                        child: ListTile(
                          leading: Icon(Icons.notifications,
                              color: Color(0xFF4FBF26)),
                          title: Text("Safari Reminder"),
                          subtitle:
                          Text("Elephant Safari scheduled for tomorrow."),
                        ),
                      ),
                    ],
                  ),

                  // News
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: const [
                      Card(
                        child: ListTile(
                          leading: Icon(Icons.newspaper,
                              color: Color(0xFF4FBF26)),
                          title: Text("Park Entry Fee Update"),
                          subtitle:
                          Text("New fees effective from next week."),
                        ),
                      ),
                      Card(
                        child: ListTile(
                          leading: Icon(Icons.newspaper,
                              color: Color(0xFF4FBF26)),
                          title: Text("Safari Timings Updated"),
                          subtitle:
                          Text("Jeep Safari timings revised this month."),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
