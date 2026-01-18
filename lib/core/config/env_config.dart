import 'package:flutter_dotenv/flutter_dotenv.dart';

enum Environment { development, staging, production }

class EnvConfig {
  static Environment _environment = Environment.development;

  static void setEnvironment(Environment env) {
    _environment = env;
  }

  static Environment get environment => _environment;

  static bool get isDevelopment => _environment == Environment.development;
  static bool get isStaging => _environment == Environment.staging;
  static bool get isProduction => _environment == Environment.production;

  // ===== FIREBASE =====
  static String get firebaseApiKey => 
      dotenv.env['FIREBASE_API_KEY'] ?? '';
  
  static String get firebaseAppId => 
      dotenv.env['FIREBASE_APP_ID'] ?? '';
  
  static String get firebaseProjectId => 
      dotenv.env['FIREBASE_PROJECT_ID'] ?? '';


  static String get esewaMerchantId => 
      dotenv.env['ESEWA_MERCHANT_ID'] ?? '';
  
  static String get esewaSecretKey => 
      dotenv.env['ESEWA_SECRET_KEY'] ?? '';

  static String get geminiApiKey => 
      dotenv.env['GEMINI_API_KEY'] ?? '';


  static int get apiTimeout => 
      int.tryParse(dotenv.env['API_TIMEOUT'] ?? '30000') ?? 30000;

  static bool get enableAnalytics => 
      dotenv.env['ENABLE_ANALYTICS']?.toLowerCase() == 'true';
  
  static bool get enableCrashlytics => 
      dotenv.env['ENABLE_CRASHLYTICS']?.toLowerCase() == 'true';
  
  static bool get enableDebugLogging => 
      dotenv.env['ENABLE_DEBUG_LOGGING']?.toLowerCase() == 'true' || 
      isDevelopment;

  static String get appName => 
      dotenv.env['APP_NAME'] ?? 'CNP Navigator';
  
  static String get appVersion => 
      dotenv.env['APP_VERSION'] ?? '1.0.0';

  // Validation: Check if required variables are set
  static bool validateRequiredVariables() {
    final required = [
      'FIREBASE_API_KEY',
      'FIREBASE_APP_ID',
      'FIREBASE_PROJECT_ID',
    ];

    for (final key in required) {
      if (dotenv.env[key] == null || dotenv.env[key]!.isEmpty) {
        print('⚠️  Missing required environment variable: $key');
        return false;
      }
    }

    return true;
  }

  // Print configuration (for debugging - hide sensitive data in production)
  static void printConfig() {
    if (isProduction) return;

    print('=================================');
    print('Environment Configuration');
    print('=================================');
    print('Environment: ${environment.name}');
    print('API Base URL: $apiBaseUrl');
    print('Debug Logging: $enableDebugLogging');
    print('Analytics: $enableAnalytics');
    print('Firebase Project: $firebaseProjectId');
    print('=================================');
  }
}