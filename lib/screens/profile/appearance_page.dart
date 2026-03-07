import 'package:flutter/material.dart';
import 'package:cnp_navigator/core/theme_controller.dart';

class AppearancePage extends StatefulWidget {
  const AppearancePage({super.key});

  @override
  State<AppearancePage> createState() => _AppearancePageState();
}

class _AppearancePageState extends State<AppearancePage> {
  AppThemeMode _selected = themeNotifier.value;

  final _options = const [
    _ThemeOption(
      mode: AppThemeMode.light,
      label: 'Light',
      subtitle: 'Clean white background',
      icon: Icons.wb_sunny_outlined,
      color: Color(0xFF4FBF26),
    ),
    _ThemeOption(
      mode: AppThemeMode.gray,
      label: 'Dim',
      subtitle: 'Warm, reduced brightness',
      icon: Icons.brightness_medium_outlined,
      color: Color(0xFF3D4F3E),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appearance'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Choose Theme',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ..._options.map((opt) => _buildTile(opt)),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(_ThemeOption opt) {
    final isSelected = _selected == opt.mode;
    return GestureDetector(
      onTap: () async {
        setState(() => _selected = opt.mode);
        await saveTheme(opt.mode);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? opt.color.withOpacity(0.1)
              : Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? opt.color : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: opt.color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(opt.icon, color: opt.color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(opt.label,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: isSelected ? opt.color : null)),
                  Text(opt.subtitle,
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade500)),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: opt.color, size: 22),
          ],
        ),
      ),
    );
  }
}

class _ThemeOption {
  final AppThemeMode mode;
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  const _ThemeOption(
      {required this.mode,
      required this.label,
      required this.subtitle,
      required this.icon,
      required this.color});
}
