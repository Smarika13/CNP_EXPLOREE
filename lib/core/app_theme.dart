import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
//  Single source of truth for the app's theme.
//  All pages should use Theme.of(context).colorScheme
//  instead of hardcoded hex values.
// ─────────────────────────────────────────────

/// The brand seed color — a rich, mature forest green.
const Color kSeedColor = Color(0xFF2E7D32);

class AppTheme {
  AppTheme._();

  // ── Light ──────────────────────────────────
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kSeedColor,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F6F5),
        appBarTheme: const AppBarTheme(
          backgroundColor: kSeedColor,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: kSeedColor,
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kSeedColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      );

  // ── Dark ───────────────────────────────────
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(
          primary:            Color(0xFF66BB6A), // soft forest green
          onPrimary:          Color(0xFF003910),
          primaryContainer:   Color(0xFF1B4D2A),
          onPrimaryContainer: Color(0xFFA5D6A7),
          secondary:          Color(0xFF80C784),
          onSecondary:        Color(0xFF003910),
          surface:            Color(0xFF1E2226), // card background
          onSurface:          Color(0xFFDEE1DE),
          error:              Color(0xFFCF6679),
          onError:            Color(0xFF690026),
          outline:            Color(0xFF3A3F44),
        ),
        scaffoldBackgroundColor: const Color(0xFF13161A), // deep, warm-tinted black
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF192420), // dark green tint — brand identity
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF1E2226),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFF2C3137), width: 1),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor:   Color(0xFF80C784),
          unselectedItemColor: Color(0xFF666E75),
          backgroundColor:     Color(0xFF181C20),
          type: BottomNavigationBarType.fixed,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E7D32),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF252A2F),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF3A3F44)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF3A3F44)),
          ),
          hintStyle: const TextStyle(color: Color(0xFF6B7280)),
        ),
        dividerColor: const Color(0xFF2C3137),
        textTheme: const TextTheme(
          bodyLarge:  TextStyle(color: Color(0xFFDEE1DE)),
          bodyMedium: TextStyle(color: Color(0xFFDEE1DE)),
          bodySmall:  TextStyle(color: Color(0xFF9BA3AB)),
          titleLarge: TextStyle(color: Color(0xFFDEE1DE), fontWeight: FontWeight.bold),
          titleMedium:TextStyle(color: Color(0xFFDEE1DE), fontWeight: FontWeight.bold),
          labelSmall: TextStyle(color: Color(0xFF9BA3AB)),
        ),
      );

  // ── Dim ────────────────────────────────────
  // Warm greige tone — clearly darker & warmer than Light, easy on the eyes.
  static ThemeData get gray => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kSeedColor,
          brightness: Brightness.light,
          surface: const Color(0xFFCFC8BE),   // warm greige card
          background: const Color(0xFFC2BBB0), // warm greige scaffold
        ),
        scaffoldBackgroundColor: const Color(0xFFC2BBB0), // noticeably warm & dim
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF3D4F3E), // darker muted olive-green
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFFD8D1C7),     // warm off-white card
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFBBB4AA), width: 1),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor:   Color(0xFF2E5C32),
          unselectedItemColor: Color(0xFF7A736A),
          backgroundColor:     Color(0xFFB8B1A7),
          type: BottomNavigationBarType.fixed,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3D4F3E),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFCFC8BE),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFB0A99F)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFB0A99F)),
          ),
          hintStyle: const TextStyle(color: Color(0xFF8A837A)),
        ),
        dividerColor: const Color(0xFFB0A99F),
        textTheme: const TextTheme(
          bodyLarge:   TextStyle(color: Color(0xFF1E1A17)),
          bodyMedium:  TextStyle(color: Color(0xFF1E1A17)),
          bodySmall:   TextStyle(color: Color(0xFF5A544E)),
          titleLarge:  TextStyle(color: Color(0xFF1E1A17), fontWeight: FontWeight.bold),
          titleMedium: TextStyle(color: Color(0xFF1E1A17), fontWeight: FontWeight.bold),
          labelSmall:  TextStyle(color: Color(0xFF5A544E)),
        ),
      );
}
