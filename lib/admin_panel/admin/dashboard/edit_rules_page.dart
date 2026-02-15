import 'package:flutter/material.dart';

class EditRulesPage extends StatefulWidget {
  const EditRulesPage({super.key});

  @override
  State<EditRulesPage> createState() => _EditRulesPageState();
}

class _EditRulesPageState extends State<EditRulesPage> {
  final TextEditingController _controller = TextEditingController();

  // Structure rules as Map<String, List<String>> to keep sections
  Map<String, List<String>> rulesSections = {
    "Inside the Jungle": [
      "Mandatory Guides: You are strictly prohibited from entering the jungle on foot without at least two certified nature guides. For jeep safaris, a guide is also mandatory.",
      "Permit Required: Every visitor must have a valid daily entry permit. These are for single entry only; if you leave and come back the next day, you need a new one.",
      "Timing: The park is open only from sunrise to sunset (roughly 6:00 AM to 5:00 PM). Staying overnight inside the core jungle is illegal.",
      "No Trace: Carrying out plastic, littering, or removing any plants or stones is a punishable offense. Drones are strictly banned unless you have a special government permit.",
      "Silence: Loud talking, music, or shouting is prohibited as it disturbs wildlife and can trigger aggressive behavior.",
    ],
    "Safety Measures Inside Jungle": [
      "Walking Safaris: If you encounter a Rhino on foot, climb a tree or run in a zigzag pattern. If you see a Sloth Bear, stay in a tight group and make noise to scare it off. Never run from a Tiger; maintain eye contact and back away slowly.",
      "Clothing: Wear neutral colors (khaki, olive, tan). Avoid bright colors like red, yellow, or white, which can attract or irritate animals.",
      "Distance: Maintain at least 20–30 meters from all wildlife.",
      "Guide Equipment: Guides carry only bamboo sticks; no firearms are allowed for tourism. Trust their expertise; they are trained to read animal 'body language'.",
    ],
    "Outside the Jungle": [
      "Respect Culture: When visiting Tharu villages, dress modestly (shoulders and knees covered). Always ask for permission before taking photos of people or their homes.",
      "Waste Management: While there are more bins here, travelers are encouraged to take non-biodegradable waste back to major cities like Bharatpur or Kathmandu.",
      "Alcohol & Noise: Many lodges have 'quiet hours' to respect both the animals nearby and other travelers.",
    ],
    "Safety Measures Outside Jungle": [
      "Night Hazards: Rhino and wild Boar frequently wander into the streets of Sauraha or Meghauli at night. Do not walk alone after dark in these areas. Use a strong flashlight if needed.",
      "Water Safety: Do not swim or dip your hands in the Rapti or Narayani rivers. They are home to Gharials and Mugger crocodiles, which can be dangerous.",
      "Health: The area is humid and prone to mosquitoes. Use DEET-based repellent and wear long sleeves in the evenings to prevent Dengue.",
    ],
  };

  void _editRule(String section, int index) {
    _controller.text = rulesSections[section]![index];
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Rule"),
        content: TextField(
          controller: _controller,
          autofocus: true,
          maxLines: 3,
          decoration: const InputDecoration(hintText: "Enter rule text"),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              setState(() {
                rulesSections[section]![index] = _controller.text;
              });
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _deleteRule(String section, int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Rule"),
        content: const Text("Are you sure you want to delete this rule?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              setState(() {
                rulesSections[section]!.removeAt(index);
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

  void _addRule(String section) {
    _controller.clear();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add New Rule"),
        content: TextField(
          controller: _controller,
          autofocus: true,
          maxLines: 3,
          decoration: const InputDecoration(hintText: "Enter rule text"),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              setState(() {
                rulesSections[section]!.add(_controller.text);
              });
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Rules"),
        backgroundColor: const Color(0xFF4FBF26),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: rulesSections.entries.map((entry) {
          final section = entry.key;
          final rules = entry.value;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      section,
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: section.contains("Safety")
                              ? Colors.redAccent
                              : Colors.green),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.blue),
                    onPressed: () => _addRule(section),
                    tooltip: "Add Rule",
                  )
                ],
              ),
              const SizedBox(height: 8),
              ...rules.asMap().entries.map((r) {
                final index = r.key;
                final text = r.value;
                return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                  shadowColor: Colors.black26,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    title: Text(text, style: const TextStyle(fontSize: 16)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editRule(section, index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteRule(section, index),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),
            ],
          );
        }).toList(),
      ),
    );
  }
}
