import 'package:flutter/material.dart';

class PublishNewsPage extends StatefulWidget {
  const PublishNewsPage({super.key});

  @override
  State<PublishNewsPage> createState() => _PublishNewsPageState();
}

class _PublishNewsPageState extends State<PublishNewsPage> {
  // Sample news data
  List<Map<String, String>> newsList = [
    {
      "title": "Park Entry Fee Update",
      "subtitle": "New fees effective from next week."
    },
    {
      "title": "Safari Timings Updated",
      "subtitle": "Jeep Safari timings revised this month."
    },
    {
      "title": "New Bird Watching Spot",
      "subtitle": "A new bird watching area opened in Chitwan."
    },
  ];

  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();

  // Show a dialog to add or edit news
  void _showNewsDialog({int? index}) {
    if (index != null) {
      _titleController.text = newsList[index]["title"]!;
      _subtitleController.text = newsList[index]["subtitle"]!;
    } else {
      _titleController.clear();
      _subtitleController.clear();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(index == null ? "Add News" : "Edit News"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Title"),
              ),
              TextField(
                controller: _subtitleController,
                decoration: const InputDecoration(labelText: "Subtitle"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final title = _titleController.text.trim();
              final subtitle = _subtitleController.text.trim();
              if (title.isEmpty || subtitle.isEmpty) return;

              setState(() {
                if (index != null) {
                  // Edit
                  newsList[index] = {"title": title, "subtitle": subtitle};
                } else {
                  // Add
                  newsList.add({"title": title, "subtitle": subtitle});
                }
              });

              Navigator.pop(context);
            },
            child: Text(index == null ? "Add" : "Update"),
          ),
        ],
      ),
    );
  }

  // Delete a news item
  void _deleteNews(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete News"),
        content: const Text("Are you sure you want to delete this news item?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                newsList.removeAt(index);
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Publish News"),
        backgroundColor: const Color(0xFF4FBF26),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showNewsDialog(), // Add news
            tooltip: "Add News",
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF4F6F5),
      body: newsList.isEmpty
          ? const Center(
        child: Text("No news published yet."),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: newsList.length,
        itemBuilder: (context, index) {
          final news = newsList[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              leading: const Icon(Icons.newspaper, color: Color(0xFF4FBF26)),
              title: Text(news["title"]!),
              subtitle: Text(news["subtitle"]!),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showNewsDialog(index: index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteNews(index),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
