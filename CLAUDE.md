# CLAUDE.md — Zodi Codebase Guide

## Project Overview

Zodi is a premium AI-powered astrology application built with **Flutter** (mobile) and **React/TypeScript** (web). It delivers personalized horoscope readings, tarot card spreads, rising sign calculations, compatibility analysis, dream interpretation, and more — all powered by Google Gemini AI and Swiss Ephemeris for astronomical accuracy.

**Primary language:** Turkish (all user-facing content, UI strings, and AI prompts are in Turkish).

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Mobile app | Flutter 3.24+ / Dart 3.0+ |
| Web app | React 19 / TypeScript 5.8 / Vite 6 |
| State management | Provider (ChangeNotifier pattern) |
| Backend | Firebase (Auth, Firestore, Analytics, Crashlytics, Storage) |
| AI | Google Gemini API (`google_generative_ai` for Dart, `@google/genai` for web) |
| Astronomy | Swiss Ephemeris (`sweph` package) |
| Ads | Google Mobile Ads (AdMob) |
| CI/CD | GitHub Actions (auto version bump on push to main/master) |

## Quick Commands

### Flutter (primary mobile app)

```bash
flutter pub get              # Install dependencies
flutter run                  # Run on connected device/emulator
flutter test                 # Run all tests
flutter test --coverage      # Run tests with coverage
flutter build apk --release  # Build Android APK
flutter build appbundle      # Build Android App Bundle (Play Store)
flutter build ios --release  # Build iOS release
```

### React web app

```bash
npm install        # Install web dependencies
npm run dev        # Start Vite dev server (port 3000)
npm run build      # Production build
npm run preview    # Preview production build
```

## Project Structure

```
/
├── lib/                          # Flutter/Dart source (main codebase)
│   ├── main.dart                 # App entry point & initialization
│   ├── app.dart                  # App configuration
│   ├── constants/                # App-wide constants
│   │   ├── colors.dart           #   Color palette
│   │   ├── strings.dart          #   String constants (Turkish)
│   │   ├── astro_data.dart       #   Astrological reference data
│   │   └── tarot_data.dart       #   Tarot card definitions
│   ├── models/                   # Data models (15 files)
│   │   ├── user_profile.dart
│   │   ├── daily_horoscope.dart
│   │   ├── tarot_card.dart
│   │   ├── zodiac_sign.dart
│   │   ├── rising_sign.dart
│   │   ├── compatibility_result.dart
│   │   ├── dream_interpretation.dart
│   │   └── ...
│   ├── providers/                # State management (ChangeNotifier)
│   │   ├── auth_provider.dart    #   Authentication state
│   │   ├── horoscope_provider.dart #  Horoscope data state
│   │   └── theme_provider.dart   #   Theme/appearance state
│   ├── services/                 # Business logic & API integrations
│   │   ├── gemini_service.dart   #   Gemini AI integration
│   │   ├── firebase_service.dart #   Firebase operations (singleton)
│   │   ├── astronomy_service.dart #  Swiss Ephemeris calculations
│   │   ├── tarot_service.dart    #   Tarot reading logic
│   │   ├── ad_service.dart       #   AdMob integration
│   │   ├── notification_service.dart # Local notifications
│   │   ├── streak_service.dart   #   User engagement streaks
│   │   ├── usage_limit_service.dart # Freemium usage tracking
│   │   └── ...
│   ├── screens/                  # Full-page UI components (27 files)
│   │   ├── splash_screen.dart
│   │   ├── home_screen.dart
│   │   ├── daily_screen.dart
│   │   ├── tarot_screen.dart
│   │   ├── explore_screen.dart
│   │   └── ...
│   ├── pages/                    # Additional page-level views
│   │   ├── analysis_page.dart
│   │   ├── compatibility_page.dart
│   │   └── ...
│   ├── widgets/                  # Reusable UI components (20+ files)
│   │   ├── animated_background.dart
│   │   ├── bottom_nav.dart
│   │   ├── premium_lock_overlay.dart
│   │   ├── zodi_character.dart
│   │   └── ...
│   ├── theme/                    # Theming system
│   │   ├── app_colors.dart
│   │   ├── app_theme.dart
│   │   └── cosmic_page_route.dart
│   └── utils/                    # Utility helpers
│       ├── navigation_helper.dart
│       └── notification_test_helper.dart
├── views/                        # React TSX views (web)
├── components/                   # React TSX components (web)
├── test/                         # Flutter test files (6 tests)
├── android/                      # Android native project
├── ios/                          # iOS native project
├── assets/                       # Images, videos, tarot cards
│   └── tarot/                    #   22 Major Arcana card images
├── .github/workflows/            # CI/CD (auto version bump)
├── pubspec.yaml                  # Flutter dependencies & config
├── package.json                  # Web dependencies & scripts
├── tsconfig.json                 # TypeScript configuration
├── vite.config.ts                # Vite build configuration
├── analysis_options.yaml         # Dart linter rules
└── .env                          # Environment variables (git-ignored)
```

## Architecture

### Flutter app — MVVM with Provider

```
UI (Screens/Widgets)
       ↓
  Providers (ChangeNotifier)
       ↓
  Services (Business Logic / API calls)
       ↓
  Models (Data Structures)
       ↓
  Firebase / Gemini API / Swiss Ephemeris
```

- **Providers** are registered via `MultiProvider` in `main.dart` and consumed with `Consumer<T>` or `Provider.of<T>`.
- **FirebaseService** uses a singleton pattern (`FirebaseService.initialize()`).
- **AstronomyService** must be initialized at app startup before use.
- **Services** are injected/accessed directly (not through providers in most cases).

### Initialization order (in `main.dart`)

1. `Firebase.initializeApp()`
2. `FirebaseService.initialize()`
3. `AstronomyService.initialize()`
4. `dotenv.load()` (loads `.env`)
5. `initializeDateFormatting('tr_TR')` (Turkish locale)
6. `AdService().initialize()` + preload ads
7. `NotificationService().initialize()` + check cold-start notification
8. Lock portrait orientation
9. `runApp(ZodiApp())`

## Code Conventions

### Dart/Flutter

- **File naming:** `snake_case.dart` (e.g., `daily_screen.dart`, `gemini_service.dart`)
- **Class naming:** `PascalCase` (e.g., `DailyScreen`, `GeminiService`)
- **Variables/functions:** `camelCase`
- **Private members:** prefixed with `_`
- **Const constructors:** required where possible (`prefer_const_constructors` lint enabled)
- **String quotes:** single quotes preferred (`prefer_single_quotes` lint enabled)
- **Widget keys:** required in widget constructors (`use_key_in_widget_constructors` lint enabled)
- **Print statements:** allowed (`avoid_print: false` in linter)

### Import order convention

1. Dart/Flutter SDK imports
2. Third-party package imports
3. Relative project imports (constants, models, services, providers, widgets, screens)

### Linting

Configured in `analysis_options.yaml` using `package:flutter_lints/flutter.yaml` with these overrides:
- `prefer_const_constructors: true`
- `prefer_const_literals_to_create_immutables: true`
- `avoid_print: false`
- `prefer_single_quotes: true`
- `use_key_in_widget_constructors: true`

### React/TypeScript (web)

- **Path alias:** `@/*` maps to project root
- **Target:** ES2022
- **Module resolution:** Bundler (modern ESM)

## Environment Variables

The app requires a `.env` file at the project root (git-ignored):

```
GEMINI_API_KEY=your_gemini_api_key_here
```

- **Flutter:** loaded via `flutter_dotenv`, accessed as `dotenv.env['GEMINI_API_KEY']`
- **Web:** injected by Vite as `process.env.GEMINI_API_KEY`

## Firebase Setup

Firebase services used:
- **Auth:** Email/Password, Google Sign-in, Anonymous auth
- **Firestore:** User profiles, interaction history, horoscope cache
- **Analytics:** User behavior tracking
- **Crashlytics:** Crash reporting
- **Storage:** File storage

Configuration files (all git-ignored — must be obtained separately):
- `lib/firebase_options.dart`
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- `.firebaserc`

## Testing

Tests are in `test/` and use the Flutter test framework.

```bash
flutter test                 # Run all tests
flutter test test/widget_test.dart  # Run specific test
```

Current test coverage focuses on:
- Widget rendering (`widget_test.dart`)
- Notification service (`notification_service_test.dart`)
- Notification content, permissions, scheduling, and tap handling

## CI/CD

**GitHub Actions workflow:** `.github/workflows/auto-version-bump.yml`

- Triggers on push to `main`/`master` (ignores `pubspec.yaml`, `.github/**`, `*.md`)
- Automatically increments the build number in `pubspec.yaml` (e.g., `1.0.0+6` → `1.0.0+7`)
- Commits the change back to the repository with `[skip ci]`
- Uses Flutter 3.24.0 stable

## Key Domain Concepts

- **Zodiac signs** are modeled in `zodiac_sign.dart` with Turkish names and astrological metadata
- **Rising sign calculations** use Swiss Ephemeris for real astronomical positions
- **Gemini AI prompts** are crafted for a "candid, cool" Turkish persona (Zodi character)
- **Tarot system** uses 22 Major Arcana cards with custom artwork in `assets/tarot/`
- **Freemium model:** usage limits are tracked by `usage_limit_service.dart`; premium features are gated by `premium_lock_overlay.dart`
- **Streaks:** daily engagement tracking via `streak_service.dart`

## Things to Watch Out For

1. **Turkish locale:** The app hardcodes `Locale('tr', 'TR')` — all date formatting, AI prompts, and UI text are in Turkish.
2. **Firebase config is git-ignored:** `firebase_options.dart`, `google-services.json`, and `GoogleService-Info.plist` must exist locally but are not in the repo.
3. **`.env` is required:** The app will fail at startup without a valid `.env` file containing `GEMINI_API_KEY`.
4. **AstronomyService initialization:** Must be called before any rising sign calculations — it loads Swiss Ephemeris data files.
5. **Singleton services:** `FirebaseService` uses a singleton; don't create multiple instances.
6. **Portrait lock:** The app is locked to portrait orientation in `main.dart`.
7. **Ad service preloading:** Ads (interstitial, rewarded, banner) are preloaded at startup for UX.
8. **Version bumping is automated:** Don't manually edit the version in `pubspec.yaml` on main — CI handles it.
