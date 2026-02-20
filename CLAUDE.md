# CLAUDE.md — Astro Dozi

## Project Context

- **App**: Astro Dozi (com.bardino.zodi) — AI-powered astrology app
- **Mobile**: Flutter 3.24+ / Dart 3.0+
- **Backend**: Firebase (Firestore, Auth, Crashlytics, Analytics, Storage)
- **AI**: Google Gemini API (content generation, horoscopes, tarot)
- **Astronomy**: Swiss Ephemeris (`sweph` package)
- **Ads**: AdMob (Banner, Rewarded, Interstitial)
- **Admin Panel**: React + Vite + Tailwind (separate repo: `zodi-admin-panel/`)
- **State Management**: Provider (ChangeNotifier pattern)
- **Auth**: Google Sign-In only
- **Language**: Turkish UI, Turkish market (all prices in ₺)
- **Theme**: LIGHT MODE ONLY — no dark mode anywhere

## Rules — Do / Don't

- App is **LIGHT MODE ONLY** — never add dark mode logic. `ThemeProvider` always returns `ThemeMode.light`.
- All prices must be in **₺ (Turkish Lira)**, never $.
- `versionCode` must be incremented before each Play Store upload.
- Never commit `.env`, `key.properties`, `google-services.json`, or `firebase_options.dart`.
- Never replace production AdMob IDs with test IDs.
- Always deploy Firestore rules after editing: `firebase deploy --only firestore:rules --project zodi-cf6b7`
- Gemini AI prompts must be written in Turkish with the Astro Dozi persona.
- Portrait orientation only — locked in `main.dart`.

## Security

- **Firebase Admin UID**: `35K8zAyPooPKh1viMFjfSHHzofw2` (info@dozi.app)
- **Firestore Rules**: `firestore.rules` — `isAdmin()` function gates admin-only reads.
- Users can ONLY read/write their own data (`request.auth.uid == userId`).
- `activity_logs`, `analytics`, `feedback` are write-only for users, read-only for admin.
- Default deny: `match /{document=**} { allow read, write: if false; }`
- AdMob production IDs are in `lib/services/ad_service.dart` — do not overwrite.

## Commands

```bash
# Flutter
flutter pub get                    # Install dependencies
flutter run                        # Run on connected device
flutter build apk --release        # Build Android APK
flutter build appbundle --release   # Build AAB for Play Store
flutter test                       # Run tests

# Install to device
adb -s R5CX30JLBWD install -r "build\app\outputs\flutter-apk\app-release.apk"

# Firebase
firebase deploy --only firestore:rules --project zodi-cf6b7

# Admin Panel
cd zodi-admin-panel && npm run dev   # Dev server
cd zodi-admin-panel && npm run build # Production build

# Icon regeneration
dart run flutter_launcher_icons
```

## Key Files

| File | Purpose |
|------|---------|
| `lib/config/membership_config.dart` | Economy: membership tiers, coin packs, pricing |
| `lib/config/fun_feature_config.dart` | Fun feature costs (aura, past life, chakra, etc.) |
| `lib/providers/auth_provider.dart` | Auth state, login, profile creation |
| `lib/providers/coin_provider.dart` | Coin balance, spending, earning, welcome bonus |
| `lib/providers/horoscope_provider.dart` | 4-tier cache: tomorrow → local → Firebase → AI generation |
| `lib/providers/theme_provider.dart` | Light-only theme (7 lines, always returns light) |
| `lib/services/ad_service.dart` | AdMob integration with production IDs |
| `lib/services/gemini_service.dart` | Gemini AI integration |
| `lib/services/firebase_service.dart` | Firebase operations (singleton) |
| `lib/services/astronomy_service.dart` | Swiss Ephemeris calculations |
| `lib/screens/tarot_screen.dart` | Tarot with coin + ad payment options |
| `lib/screens/explore_screen.dart` | StatefulWidget, auto-fetches horoscope |
| `firestore.rules` | Security rules with isAdmin() function |
| `pubspec.yaml` | Version, dependencies (current: 1.0.0+7) |
| `android/app/build.gradle.kts` | Signing config, application ID |
| `android/app/src/main/AndroidManifest.xml` | AdMob App ID, permissions |

## Economy (₺ Pricing)

### Membership Tiers
| Tier | Price | Daily Bonus | Ad Reward |
|------|-------|-------------|-----------|
| Standart | Free | 5 | 5 |
| Altın | ₺179.99/mo | 15 | 8 |
| Elmas | ₺349.99/mo | 30 | 15 |
| Platinyum | ₺599.99/mo | 50 | 25 |

### Coin Packs
| Coins | Bonus | Total | Price |
|-------|-------|-------|-------|
| 50 | — | 50 | ₺49.99 |
| 150 | +20% | 180 | ₺119.99 |
| 400 | +50% | 600 | ₺249.99 |
| 1000 | +100% | 2000 | ₺449.99 |

### Feature Costs
| Feature | Cost |
|---------|------|
| Detaylı Analiz | 10 coins |
| Burç Uyumu | 5 coins |
| Tarot Falı | 5 coins (or ad) |
| Aura Okuma | 8 coins |
| Geçmiş Yaşam | 12 coins |
| Yaşam Yolu | 10 coins |
| Çakra Analizi | 8 coins |

### Earning
- Welcome bonus: 50 coins
- Daily bonus: 5 coins (Standart)
- Ad reward: 5 coins per ad
- Streak bonus (7 days): 3 coins

## Architecture

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

### Initialization Order (main.dart)
1. `Firebase.initializeApp()`
2. `FirebaseService.initialize()` (singleton)
3. `AstronomyService.initialize()` (loads Swiss Ephemeris data)
4. `dotenv.load()` (loads `.env` with `GEMINI_API_KEY`)
5. `initializeDateFormatting('tr_TR')`
6. `AdService().initialize()` + preload ads
7. `NotificationService().initialize()`
8. Lock portrait orientation
9. `runApp()`

### Horoscope Cache (4-Tier)
1. Tomorrow cache (pre-fetched)
2. Local cache (SharedPreferences)
3. Firebase cache (`users/{uid}/dailyCache/{cacheId}`)
4. AI generation (Gemini) — only if all caches miss

## Project Structure

```
lib/
├── main.dart                    # Entry point
├── config/                      # App configuration
│   ├── membership_config.dart   #   Tiers, coin packs, pricing
│   └── fun_feature_config.dart  #   Fun feature costs
├── models/                      # Data models (15+ files)
├── providers/                   # State management
│   ├── auth_provider.dart
│   ├── coin_provider.dart
│   ├── horoscope_provider.dart
│   └── theme_provider.dart
├── services/                    # Business logic
│   ├── gemini_service.dart
│   ├── firebase_service.dart
│   ├── astronomy_service.dart
│   ├── ad_service.dart
│   ├── notification_service.dart
│   ├── streak_service.dart
│   └── usage_limit_service.dart
├── screens/                     # Full-page UI (27+ files)
├── widgets/                     # Reusable UI components (20+ files)
├── theme/                       # Theming (light-only)
└── utils/                       # Helpers

android/
├── app/build.gradle.kts         # Signing, app ID
├── app/src/main/AndroidManifest.xml  # AdMob App ID
└── key.properties               # Upload keystore (git-ignored)

assets/
├── tarot/                       # 22 Major Arcana card images
└── astro_dozi_icon_fg.webp      # Adaptive icon foreground (padded)
```

## Code Conventions

- **File naming**: `snake_case.dart`
- **Classes**: `PascalCase`
- **Variables/functions**: `camelCase`
- **Private members**: prefixed with `_`
- **Quotes**: single quotes preferred
- **Const constructors**: required where possible
- **Imports**: Dart SDK → packages → relative project imports
- **All UI text**: Turkish

## Things to Watch Out For

1. **Turkish locale**: Hardcoded `Locale('tr', 'TR')` — all dates, AI prompts, UI text in Turkish.
2. **Firebase config is git-ignored**: `firebase_options.dart`, `google-services.json` must exist locally.
3. **`.env` is required**: App crashes without `GEMINI_API_KEY`.
4. **AstronomyService**: Must initialize before any rising sign calculations.
5. **Singleton services**: `FirebaseService` — don't create multiple instances.
6. **Auth login**: Checks for existing profile before creating — preserves birth info.
7. **isDark ternaries**: ~68 files have `isDark` checks that harmlessly resolve to light branch. ThemeProvider is locked to light.
8. **AdMob**: Production IDs are live. Test IDs are `ca-app-pub-3940256099942544/*`.

---

## Engineering Preferences

Review this plan thoroughly before making any code changes. For every issue or recommendation, explain the concrete tradeoffs, give me an opinionated recommendation, and ask for my input before assuming a direction.

* **DRY** is important — flag repetition aggressively.
* Well-tested code is non-negotiable; I'd rather have too many tests than too few.
* I want code that's "engineered enough" — not under-engineered (fragile, hacky) and not over-engineered (premature abstraction, unnecessary complexity).
* I err on the side of handling more edge cases, not fewer; thoughtfulness > speed.
* Bias toward explicit over clever.

## Review Protocol

### 1. Architecture Review
Evaluate:
* Overall system design and component boundaries.
* Dependency graph and coupling concerns.
* Data flow patterns and potential bottlenecks.
* Scaling characteristics and single points of failure.
* Security architecture (auth, data access, API boundaries).

### 2. Code Quality Review
Evaluate:
* Code organization and module structure.
* DRY violations — be aggressive here.
* Error handling patterns and missing edge cases (call these out explicitly).
* Technical debt hotspots.
* Areas that are over-engineered or under-engineered relative to my preferences.

### 3. Test Review
Evaluate:
* Test coverage gaps (unit, integration, e2e).
* Test quality and assertion strength.
* Missing edge case coverage — be thorough.
* Untested failure modes and error paths.

### 4. Performance Review
Evaluate:
* N+1 queries and database access patterns.
* Memory-usage concerns.
* Caching opportunities.
* Slow or high-complexity code paths.

### For Each Issue Found
For every specific issue (bug, smell, design concern, or risk):
* Describe the problem concretely, with file and line references.
* Present 2–3 options, including "do nothing" where that's reasonable.
* For each option, specify:
   * Implementation effort
   * Risk
   * Impact on other code
   * Maintenance burden
* Give your recommended option and why, mapped to my preferences above.
* Then explicitly ask whether I agree or want to choose a different direction before proceeding.

### Workflow and Interaction
* Do not assume my priorities on timeline or scale.
* After each section, pause and ask for my feedback before moving on.

### Before Starting a Review
Ask if I want one of two options:
1. **BIG CHANGE** — Work through interactively, one section at a time (Architecture → Code Quality → Tests → Performance) with at most 4 top issues in each section.
2. **SMALL CHANGE** — Work through interactively ONE question per review section.

### Output Format Rules
* NUMBER issues.
* Use LETTERS for options.
* When asking, clearly label each option with the issue NUMBER and option LETTER.
* Make the recommended option always the first option.
