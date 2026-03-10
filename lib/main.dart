import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'auth_wrapper.dart';
import 'firebase_options.dart';
import 'shared/services/firebase_service.dart';
import 'screens/splash_screen.dart';
import 'core/app_theme.dart';
import 'core/theme_controller.dart';
import 'shared/widgets/no_internet_wrapper.dart';

const _backendHealth = 'https://ai-part-h3xq.onrender.com/api/v1/health';

void _pingBackend() {
  http.get(Uri.parse(_backendHealth)).catchError((_) => http.Response('', 0));
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await loadSavedTheme();

  final firebaseService = FirebaseService();
  try {
    await firebaseService.seedInitialData();
    print("Firebase: Chitwan activities are ready!");
  } catch (e) {
    print("Firebase Setup Error: $e");
  }

  // Wake up the Render backend immediately so it's ready by the time
  // the user navigates to the chatbot.
  _pingBackend();

  // Keep the backend alive — ping every 14 minutes to prevent Render
  // free-tier from sleeping (sleeps after 15 min of inactivity).
  Timer.periodic(const Duration(minutes: 14), (_) => _pingBackend());

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ne')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, _) {
        final themeData = switch (mode) {
          AppThemeMode.gray => AppTheme.gray,
          _ => AppTheme.light,
        };
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'CNP Navigator',
          theme: themeData,
          home: const NoInternetWrapper(child: SplashScreen()),
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
        );
      },
    );
  }
}