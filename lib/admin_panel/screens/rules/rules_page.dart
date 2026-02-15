import 'package:flutter/material.dart';

class RulesPage extends StatelessWidget {
  const RulesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rules & Safety Measures"),
        backgroundColor: const Color(0xFF4FBF26),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Rules & Safety Measures in Chitwan National Park",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // ===== Inside the Jungle =====
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 3,
            shadowColor: Colors.black26,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Inside the Jungle",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                  const SizedBox(height: 12),
                  ruleItem("Mandatory Guides: You are strictly prohibited from entering the jungle on foot without at least two certified nature guides. For jeep safaris, a guide is also mandatory."),
                  ruleItem("Permit Required: Every visitor must have a valid daily entry permit. These are for single entry only; if you leave and come back the next day, you need a new one."),
                  ruleItem("Timing: The park is open only from sunrise to sunset (roughly 6:00 AM to 5:00 PM). Staying overnight inside the core jungle is illegal."),
                  ruleItem("No Trace: Carrying out plastic, littering, or removing any plants or stones is a punishable offense. Drones are strictly banned unless you have a special government permit."),
                  ruleItem("Silence: Loud talking, music, or shouting is prohibited as it disturbs wildlife and can trigger aggressive behavior."),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ===== Safety Measures Inside Jungle =====
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 3,
            shadowColor: Colors.black26,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Safety Measures Inside Jungle",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.redAccent),
                  ),
                  const SizedBox(height: 12),
                  ruleItem("Walking Safaris: If you encounter a Rhino on foot, climb a tree or run in a zigzag pattern. If you see a Sloth Bear, stay in a tight group and make noise to scare it off. Never run from a Tiger; maintain eye contact and back away slowly."),
                  ruleItem("Clothing: Wear neutral colors (khaki, olive, tan). Avoid bright colors like red, yellow, or white, which can attract or irritate animals."),
                  ruleItem("Distance: Maintain at least 20–30 meters from all wildlife."),
                  ruleItem("Guide Equipment: Guides carry only bamboo sticks; no firearms are allowed for tourism. Trust their expertise; they are trained to read animal 'body language'."),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ===== Outside the Jungle =====
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 3,
            shadowColor: Colors.black26,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Outside the Jungle",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                  const SizedBox(height: 12),
                  ruleItem("Respect Culture: When visiting Tharu villages, dress modestly (shoulders and knees covered). Always ask for permission before taking photos of people or their homes."),
                  ruleItem("Waste Management: While there are more bins here, travelers are encouraged to take non-biodegradable waste back to major cities like Bharatpur or Kathmandu."),
                  ruleItem("Alcohol & Noise: Many lodges have 'quiet hours' to respect both the animals nearby and other travelers."),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ===== Safety Measures Outside Jungle =====
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 3,
            shadowColor: Colors.black26,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Safety Measures Outside Jungle",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.redAccent),
                  ),
                  const SizedBox(height: 12),
                  ruleItem("Night Hazards: Rhino and wild Boar frequently wander into the streets of Sauraha or Meghauli at night. Do not walk alone after dark in these areas. Use a strong flashlight if needed."),
                  ruleItem("Water Safety: Do not swim or dip your hands in the Rapti or Narayani rivers. They are home to Gharials and Mugger crocodiles, which can be dangerous."),
                  ruleItem("Health: The area is humid and prone to mosquitoes. Use DEET-based repellent and wear long sleeves in the evenings to prevent Dengue."),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Reusable widget for numbered rules
  Widget ruleItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("•  ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16, color: Colors.black87))),
        ],
      ),
    );
  }
}
