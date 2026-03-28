import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class FAQsPage extends StatefulWidget {
  const FAQsPage({super.key});

  @override
  State<FAQsPage> createState() => _FAQsPageState();
}

class _FAQsPageState extends State<FAQsPage> {
  String _searchQuery = '';

  static const _categories = [
    _FaqCategory(
      title: 'Planning Your Visit',
      titleKey: 'faq_cat_planning',
      icon: Icons.calendar_month,
      color: Color(0xFF2E7D32),
      faqs: [
        _Faq('When is the best time to visit?',
            'The "sweet spot" is October to December for pleasant weather. For maximum wildlife sightings, late January to May is best because tall elephant grass is cut, improving visibility.'),
        _Faq('How much is the entry fee?',
            'As of 2026, the daily permit fee is NPR 2,000 for foreigners, NPR 1,000 for SAARC nationals, and NPR 150 for Nepali citizens.'),
        _Faq('Can I use the same permit for two days?',
            'No. Permits are valid for one day only, from sunrise to sunset. A new permit is required for each day.'),
        _Faq('Is the park open all year round?',
            'Yes, but some activities may be restricted during the monsoon season (June–September) due to flooding and safety risks.'),
        _Faq('What is the monsoon season like in Chitwan?',
            'Monsoon season brings heavy rain, high humidity, leeches, and limited wildlife visibility, but the forest is lush and green.'),
        _Faq('Can I visit Chitwan as a day trip?',
            'A day trip is possible but not ideal. Staying at least one night allows time for multiple activities and better wildlife chances.'),
        _Faq('Can I visit the park without booking in advance?',
            'During off-season, yes. During peak season (October–March), advance booking is strongly recommended.'),
        _Faq('How early should I book safaris in peak season?',
            'It is best to book 1–2 days in advance as permits, vehicles, and guides are limited.'),
      ],
    ),
    _FaqCategory(
      title: 'Wildlife & Nature',
      titleKey: 'faq_cat_wildlife',
      icon: Icons.pets,
      color: Color(0xFF1565C0),
      faqs: [
        _Faq('What are my chances of seeing a tiger?',
            'Tigers are elusive. Even though CNP has a healthy population, the success rate is around 20–30%. Full-day jeep safaris during March–May offer the best chance.'),
        _Faq('Are there still wild elephants in the park?',
            'Yes. Wild elephants exist but are fewer and more dangerous than rhinos. Most elephants seen by visitors are domestic, though wild bulls sometimes enter the park and nearby villages.'),
        _Faq('What animals are most commonly seen?',
            'Rhinos, deer, monkeys, peacocks, crocodiles, and various bird species are commonly seen. Tigers and leopards are rare sightings.'),
        _Faq('Are there crocodiles in Chitwan National Park?',
            'Yes. Both mugger crocodiles and gharials live in the rivers and wetlands of the park.'),
        _Faq('Is Chitwan suitable for bird watching?',
            'Yes. The park is home to over 500 bird species, making it one of the best bird-watching destinations in South Asia.'),
        _Faq('Why is Chitwan National Park important?',
            'Chitwan is Nepal\'s first national park and plays a vital role in conserving endangered species like the one-horned rhino and Bengal tiger.'),
      ],
    ),
    _FaqCategory(
      title: 'Safari & Activities',
      titleKey: 'faq_cat_safari',
      icon: Icons.directions_car,
      color: Color(0xFF6A1B9A),
      faqs: [
        _Faq('Do I really need a guide?',
            'Yes. Hiring a guide is mandatory by law. Entry into the core jungle without an authorized guide is strictly prohibited.'),
        _Faq('Is a jungle walk safe?',
            'It is a calculated risk. Guides are trained, but animals like rhinos and sloth bears are unpredictable. Most visitors still find it thrilling and rewarding.'),
        _Faq('Can I enter the park without a safari vehicle?',
            'No. Entry into core areas is only allowed through authorized activities like jeep safaris, guided walks, canoeing, or elephant safaris.'),
        _Faq('Are children allowed on safaris?',
            'Yes, children are allowed on jeep and elephant safaris. Jungle walks are not recommended for very young children due to safety concerns.'),
        _Faq('What is the best safari option for first-time visitors?',
            'A jeep safari is recommended as it covers a larger area and is safer and more comfortable for most visitors.'),
        _Faq('What is the difference between jeep safari and elephant safari?',
            'Jeep safaris cover longer distances and are better for spotting tigers. Elephant safaris allow closer views of rhinos but are more limited in range.'),
        _Faq('Is elephant riding ethical?',
            'This is debated. Many visitors now prefer jeep safaris, which are considered more ethical and less stressful for animals.'),
        _Faq('What time do safaris usually start?',
            'Morning safaris usually start around 6:00 AM, and afternoon safaris around 1:00–2:00 PM.'),
      ],
    ),
    _FaqCategory(
      title: 'Rules & Regulations',
      titleKey: 'faq_cat_rules',
      icon: Icons.gavel,
      color: Color(0xFFC62828),
      faqs: [
        _Faq('What should I wear inside the park?',
            'Wear neutral colors such as khaki, olive, or brown. Avoid white, red, yellow, or bright colors as they attract attention and may provoke animals.'),
        _Faq('Is photography allowed inside the park?',
            'Yes, personal photography is allowed. However, flash photography near animals and the use of drones are strictly prohibited.'),
        _Faq('Are drones allowed in Chitwan National Park?',
            'No. Drones are completely banned unless special written permission is obtained from park authorities.'),
        _Faq('Can I bring food inside the park?',
            'Small snacks are allowed, but feeding animals is strictly prohibited. All trash must be carried back.'),
        _Faq('Are plastic bags allowed inside the park?',
            'Plastic bags are discouraged. Visitors are requested to avoid bringing non-biodegradable materials into the park.'),
        _Faq('Is swimming allowed in rivers inside the park?',
            'No. Rivers contain crocodiles and strong currents, making swimming extremely dangerous.'),
        _Faq('Are night safaris allowed?',
            'No. Night safaris are not allowed for regular visitors due to safety and conservation rules.'),
        _Faq('Do I need special permission for filming or documentaries?',
            'Yes. Professional filming, documentaries, and research activities require official permission from park authorities.'),
        _Faq('Is alcohol allowed inside the park?',
            'No. Carrying or consuming alcohol inside the park is strictly prohibited.'),
        _Faq('Are pets allowed inside Chitwan National Park?',
            'No. Pets are not allowed inside the park under any circumstances.'),
      ],
    ),
    _FaqCategory(
      title: 'Facilities & Services',
      titleKey: 'faq_cat_facilities',
      icon: Icons.hotel,
      color: Color(0xFFE65100),
      faqs: [
        _Faq('Where do most visitors stay?',
            'Most visitors stay in Sauraha or nearby buffer-zone areas, which offer a wide range of hotels and lodges.'),
        _Faq('Are there accommodations inside the park?',
            'Yes, but they are limited and require special arrangements. Most tourists stay outside the core park.'),
        _Faq('Is internet or mobile network available inside the park?',
            'Mobile network coverage is weak or unavailable inside core areas. Internet access is usually available only in hotels outside the park.'),
        _Faq('What should I do if I encounter a wild animal on foot?',
            'Remain calm, follow your guide\'s instructions, do not run, and avoid sudden movements.'),
        _Faq('Are toilets available inside the park?',
            'Basic toilet facilities are available at entry points, but not inside jungle routes.'),
        _Faq('What languages do guides usually speak?',
            'Most guides speak Nepali and basic English. Some experienced guides speak good conversational English.'),
        _Faq('Is tipping guides mandatory?',
            'Tipping is not mandatory but is appreciated if you are satisfied with the service.'),
        _Faq('Is Chitwan safe for solo travelers?',
            'Yes, as long as park rules are followed and activities are done through authorized operators.'),
      ],
    ),
  ];

  List<({_Faq faq, _FaqCategory category})> get _searchResults {
    final q = _searchQuery.toLowerCase();
    return [
      for (final cat in _categories)
        for (final faq in cat.faqs)
          if (faq.question.toLowerCase().contains(q) ||
              faq.answer.toLowerCase().contains(q))
            (faq: faq, category: cat),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        title: Text('faq_title'.tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1B5E20),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'faq_search_hint'.tr(),
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.8)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white70),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
                filled: true,
                fillColor: Colors.white.withOpacity(0.15),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: _searchQuery.isEmpty ? _buildCategorized() : _buildSearchResultsList(),
    );
  }

  Widget _buildCategorized() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        for (final cat in _categories) ...[
          _CategoryHeader(cat),
          const SizedBox(height: 4),
          _CategoryCard(cat),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildSearchResultsList() {
    final results = _searchResults;
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, size: 48, color: Colors.grey),
            const SizedBox(height: 8),
            Text('faq_no_results'.tr(), style: const TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: results
          .map((r) => _FaqTile(faq: r.faq, accentColor: r.category.color))
          .toList(),
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  final _FaqCategory cat;
  const _CategoryHeader(this.cat);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: cat.color.withOpacity(0.15),
          child: Icon(cat.icon, size: 16, color: cat.color),
        ),
        const SizedBox(width: 10),
        Text(
          cat.titleKey.tr(),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: cat.color,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Divider(color: cat.color.withOpacity(0.3), thickness: 1)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: cat.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${cat.faqs.length}',
            style: TextStyle(fontSize: 11, color: cat.color, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final _FaqCategory cat;
  const _CategoryCard(this.cat);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: cat.color.withOpacity(0.15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cat.color.withOpacity(0.15)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: cat.faqs
              .map((faq) => _FaqTile(faq: faq, accentColor: cat.color))
              .toList(),
        ),
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  final _Faq faq;
  final Color accentColor;
  const _FaqTile({required this.faq, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        childrenPadding: EdgeInsets.zero,
        leading: Icon(Icons.help_outline, size: 18, color: accentColor.withOpacity(0.7)),
        title: Text(
          faq.question,
          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
        ),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border(left: BorderSide(color: accentColor, width: 3)),
            ),
            child: Text(
              faq.answer,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade800, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqCategory {
  final String title;
  final String titleKey;
  final IconData icon;
  final Color color;
  final List<_Faq> faqs;
  const _FaqCategory({
    required this.title,
    required this.titleKey,
    required this.icon,
    required this.color,
    required this.faqs,
  });
}

class _Faq {
  final String question;
  final String answer;
  const _Faq(this.question, this.answer);
}
