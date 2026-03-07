import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final ValueNotifier<AppThemeMode> themeNotifier =
    ValueNotifier(AppThemeMode.light);

enum AppThemeMode { light, gray }

Future<void> loadSavedTheme() async {
  final prefs = await SharedPreferences.getInstance();
  final saved = prefs.getString('app_theme') ?? 'light';
  themeNotifier.value = switch (saved) {
    'gray' => AppThemeMode.gray,
    _ => AppThemeMode.light,
  };
}

Future<void> saveTheme(AppThemeMode mode) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('app_theme', mode.name);
  themeNotifier.value = mode;
}
