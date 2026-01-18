# CNP Navigator - Chitwan National Park Activity Booking System

Activity Booking and Wildlife Exploration System for Chitwan National Park using Flutter, Firebase, and AI (LLM & RAG).

## 🎯 Features

- **User Side**:
  - Activity booking (Jungle Safari, Canoe Ride, etc.)
  - Wildlife species exploration with AI
  - Real-time notifications
  - Payment integration (Khalti, eSewa)
  - Booking history

- **Admin Side**:
  - Activity management
  - Wildlife data management
  - Booking management
  - Guide management
  - User management
  - Notices & announcements

## 🛠 Tech Stack

- **Frontend**: Flutter
- **Backend**: Firebase (Authentication, Firestore, Storage)
- **State Management**: BLoC Pattern
- **Architecture**: Clean Architecture

---

## 🚀 Project Setup

### Prerequisites

Before you begin, ensure you have:
- Flutter SDK 3.0.0 or higher ([Install Flutter](https://docs.flutter.dev/get-started/install))
- Firebase CLI ([Install Firebase CLI](https://firebase.google.com/docs/cli))
- Git
- Android Studio or VS Code with Flutter extensions
<!-- - A Firebase account -->

### Step 1: Clone the Repository

```bash
git clone https://github.com/your-org/cnp-navigator.git
cd cnp-navigator
```

### Step 2: Install Flutter Dependencies

```bash
flutter pub get
```

### Step 3: Environment Variables Setup

#### 3.1 Copy the .env.example file

```bash
cp .env.example .env
```

<!-- #### 3.2 Get Credentials from Team Lead

Contact the team lead to get:
- Firebase configuration values
- eSewa credentials

#### 3.3 Fill in your .env file

Open `.env` and replace placeholder values with actual credentials:

```bash
FIREBASE_API_KEY=your_actual_api_key
FIREBASE_APP_ID=your_actual_app_id
# ... etc
```

**⚠️ NEVER commit the .env file to Git!** -->

<!-- ### Step 4: Firebase Configuration

You have two options:

#### Option A: Use Team's Firebase Project (Recommended for Development)

1. Contact team lead for Firebase project access
2. They will add your Google account to the Firebase project
3. Login to Firebase CLI:
   ```bash
   firebase login
   ```
4. Generate Firebase configuration:
   ```bash
   flutterfire configure
   ```
5. Select the team's Firebase project when prompted

#### Option B: Create Your Own Development Firebase Project

Only do this if you need an isolated environment for testing:

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project named "cnp-navigator-dev-yourname"
3. Run FlutterFire configuration:
   ```bash
   flutterfire configure
   ```
4. Enable Authentication (Email/Password method)
5. Create Firestore Database
6. Apply Firestore Security Rules (see below)

### Step 5: Apply Firestore Security Rules

If you created your own Firebase project:

1. Go to Firebase Console → Firestore Database → Rules
2. Copy the rules from `firestore.rules` file in the project
3. Paste and publish

### Step 6: Seed Initial Test Data

#### 6.1 Install Node.js dependencies for seeder

```bash
cd firebase-seeder
npm install
```

#### 6.2 Get Service Account Key

1. Firebase Console → Project Settings → Service Accounts
2. Click "Generate New Private Key"
3. Save the JSON file as `serviceAccountKey.json` in `firebase-seeder` folder

**⚠️ NEVER commit serviceAccountKey.json to Git!**

#### 6.3 Run the seeder

```bash
node firebase_seeder.js
```

This will create:
- Test admin user (admin@cnp.com / admin123)
- Test regular user (user@cnp.com / user123)
- Sample activities, species, guides, and categories -->

### Step 7: Run the Application

```bash
# Return to project root
cd ..

# Run on connected device/emulator
flutter run

# Run on chrome
flutter run -d chrome
```

---

<!-- ## 🧪 Test Credentials

After seeding data, you can login with:

- **Admin Account**:
  - Email: `admin@cnp.com`
  - Password: `admin123`
  - Access: Admin Dashboard with full management capabilities

- **User Account**:
  - Email: `user@cnp.com`
  - Password: `user123`
  - Access: User Dashboard for booking and exploration

--- -->

<!-- ## 📁 Project Structure

```
lib/
├── core/                    # App-wide utilities and constants
├── features/               
│   ├── auth/               # Authentication (login, logout)
│   ├── user/               # User-side features
│   │   ├── booking/        # Activity booking
│   │   ├── wildlife/       # Wildlife exploration
│   │   └── payment/        # Payment processing
│   └── admin/              # Admin-side features
│       ├── activity_management/
│       ├── wildlife_management/
│       └── booking_management/
├── shared/                 # Shared widgets and services
├── config/                 # App configuration
└── injection_container.dart # Dependency injection
``` -->

---

<!-- ## 🔒 Security Best Practices

### Files to NEVER Commit to Git:

✅ **Safe to commit:**
- `.env.example` (template file)
- `README.md`
- Source code files

❌ **NEVER commit:**
- `.env` (contains actual credentials)
- `firebase_options.dart` (auto-generated)
- `google-services.json` (Android Firebase config)
- `GoogleService-Info.plist` (iOS Firebase config)
- `serviceAccountKey.json` (Firebase admin credentials)
- Any file with API keys or passwords

### Before Committing Code:

```bash
# Check what you're about to commit
git status

# Make sure no sensitive files are staged
git diff --staged

# If you accidentally staged a sensitive file:
git reset HEAD path/to/sensitive/file
```

---

## 🌍 Environment Management

### Development vs Production

This project supports multiple environments:

- **Development**: For local testing
- **Staging**: For testing before production
- **Production**: Live app

To run different environments:

```bash
# Development
flutter run -t lib/main_dev.dart

# Staging
flutter run -t lib/main_staging.dart

# Production
flutter run -t lib/main_prod.dart
# or simply
flutter run
```

---

## 🐛 Troubleshooting

### Issue: "Error: Could not load .env file"
**Solution**: Make sure `.env` file exists in project root and contains all required variables from `.env.example`

### Issue: "Firebase initialization failed"
**Solution**: 
1. Verify `firebase_options.dart` exists in `lib/config/firebase/`
2. Run `flutterfire configure` again
3. Check if your `.env` has correct Firebase credentials

### Issue: "Missing required environment variable"
**Solution**: Compare your `.env` with `.env.example` and add any missing variables

### Issue: "Login fails with test credentials"
**Solution**: 
1. Make sure you ran the seeder script
2. Check Firebase Console → Authentication to verify users exist
3. Check Firebase Console → Firestore to verify user documents exist

### Issue: "Permission denied" in Firestore
**Solution**: 
1. Verify security rules are applied correctly
2. Make sure the user has the correct `role` field in Firestore
3. Check if you're logged in with the correct account

--- -->

## 🤝 Contributing

### Git Workflow

1. Create a new branch for your feature:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. Make your changes and commit:
   ```bash
   git add .
   git commit -m "Add: your feature description"
   ```

3. Push to your branch:
   ```bash
   git push origin feature/your-feature-name
   ```

4. Create a Pull Request on GitHub

<!-- --- -->

<!-- ## 📝 Additional Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [BLoC Pattern Guide](https://bloclibrary.dev/)
- [Clean Architecture in Flutter](https://resocoder.com/flutter-clean-architecture-tdd/)

--- -->