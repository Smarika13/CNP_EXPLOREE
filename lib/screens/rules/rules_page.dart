import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class RulesPage extends StatelessWidget {
  const RulesPage({super.key});

  static const _sections = [
    _RulesSection(
      title: 'Safety Rules',
      subtitle: 'For visitors inside the park',
      titleKey: 'rules_sec1_title',
      subtitleKey: 'rules_sec1_sub',
      icon: Icons.security,
      color: Color(0xFF1B5E20),
      rules: [
        'Always stay with your authorized guide and never wander off alone inside the park.',
        'Maintain a safe distance from all wildlife, especially elephants, rhinoceros, and tigers.',
        'Avoid making loud noises or sudden movements near animals.',
        'Follow all instructions given by guides immediately during wildlife encounters.',
        'Remain inside designated safari vehicles and do not exit without permission from your guide.',
      ],
    ),
    _RulesSection(
      title: 'Wildlife Protection',
      subtitle: 'Preserving the park\'s biodiversity',
      titleKey: 'rules_sec2_title',
      subtitleKey: 'rules_sec2_sub',
      icon: Icons.pets,
      color: Color(0xFF2E7D32),
      rules: [
        'Feeding animals inside the park is strictly prohibited.',
        'Littering is not allowed — carry all trash back with you.',
        'Picking flowers, plants, or collecting any natural materials from the park is prohibited.',
        'Photography is allowed for personal use, but flash photography near animals is not permitted.',
        'Do not disturb animal habitats, nests, or breeding areas.',
      ],
    ),
    _RulesSection(
      title: 'Entry Rules & Restrictions',
      subtitle: 'Permits and park access',
      titleKey: 'rules_sec3_title',
      subtitleKey: 'rules_sec3_sub',
      icon: Icons.badge,
      color: Color(0xFF1565C0),
      rules: [
        'All visitors must carry valid entry permits at all times inside the park.',
        'Park entry is only allowed during designated hours: 6:00 AM to 6:00 PM.',
        'Children under the age of 10 must be accompanied by an adult at all times.',
        'Smoking and consumption of alcohol are strictly prohibited inside the park.',
        'Drones and unauthorized filming or recording equipment are not allowed without special permission.',
      ],
    ),
    _RulesSection(
      title: 'Conservation Guidelines',
      subtitle: 'Responsible tourism practices',
      titleKey: 'rules_sec4_title',
      subtitleKey: 'rules_sec4_sub',
      icon: Icons.eco,
      color: Color(0xFF558B2F),
      rules: [
        'Respect local communities and their traditional rights.',
        'Support sustainable and eco-friendly tourism practices.',
        'Report any suspicious activities or signs of poaching to park authorities immediately.',
        'Stay on marked trails and designated areas only.',
        'Bringing plastic bags or non-biodegradable materials into the park is discouraged.',
      ],
    ),
    _RulesSection(
      title: 'Emergency Procedures',
      subtitle: 'What to do in an emergency',
      titleKey: 'rules_sec5_title',
      subtitleKey: 'rules_sec5_sub',
      icon: Icons.emergency,
      color: Color(0xFFC62828),
      rules: [
        'In case of an emergency, contact park rangers or your guide immediately.',
        'Official emergency contact: +977-56-580291 (Chitwan National Park).',
        'First aid stations are available at the park headquarters and major entry points.',
        'Always inform someone about your itinerary before entering the park.',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildIntroCard(),
                const SizedBox(height: 20),
                ..._sections.map((s) => _SectionCard(section: s)),
                const SizedBox(height: 8),
                _buildEmergencyBanner(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 160,
      pinned: true,
      backgroundColor: const Color(0xFF1B5E20),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'rules_title'.tr(),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                top: -20,
                child: Icon(Icons.park, size: 160, color: Colors.white.withOpacity(0.08)),
              ),
              const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),
                    Icon(Icons.gavel, color: Colors.white70, size: 40),
                    SizedBox(height: 8),
                    Text(
                      'CHITWAN NATIONAL PARK',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIntroCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.3)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF1B5E20).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.info_outline, color: Color(0xFF1B5E20), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'rules_intro'.tr(),
              style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEF9A9A)),
      ),
      child: Row(
        children: [
          const Icon(Icons.phone_in_talk, color: Color(0xFFC62828), size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'rules_emergency_title'.tr(),
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFC62828), fontSize: 14),
              ),
              const SizedBox(height: 2),
              Text(
                'rules_emergency_number'.tr(),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFFB71C1C)),
              ),
              Text(
                'rules_emergency_sub'.tr(),
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final _RulesSection section;
  const _SectionCard({required this.section});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: section.color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Icon(section.icon, color: Colors.white, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        section.titleKey.tr(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(
                        section.subtitleKey.tr(),
                        style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${section.rules.length} rules',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          // Rules list
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              children: section.rules.asMap().entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        margin: const EdgeInsets.only(top: 1),
                        decoration: BoxDecoration(
                          color: section.color.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${entry.key + 1}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: section.color,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: const TextStyle(fontSize: 13.5, color: Colors.black87, height: 1.5),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _RulesSection {
  final String title;
  final String subtitle;
  final String titleKey;
  final String subtitleKey;
  final IconData icon;
  final Color color;
  final List<String> rules;
  const _RulesSection({
    required this.title,
    required this.subtitle,
    required this.titleKey,
    required this.subtitleKey,
    required this.icon,
    required this.color,
    required this.rules,
  });
}
