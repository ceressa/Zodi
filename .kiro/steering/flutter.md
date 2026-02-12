# Flutter Development Guide

## Project Overview

Zodi Flutter app - Cross-platform mobile application (iOS & Android) built with Flutter, replacing the previous React web and Kotlin Android implementations.

## Architecture

### State Management
- **Provider** pattern for app-wide state
- Three main providers:
  - `AuthProvider`: User authentication and profile
  - `ThemeProvider`: Dark/light theme switching
  - `HoroscopeProvider`: AI-generated horoscope data

### Data Persistence
- `shared_preferences` for local storage
- Stores: user info, zodiac selection, premium status, theme preference

### Navigation
- Simple push/pop navigation
- No router package (keeping it minimal)
- Screen transitions: Splash → Auth → Selection → Home

## Key Conventions

### File Structure
- `screens/`: Full-page screens
- `widgets/`: Reusable UI components
- `models/`: Data classes
- `services/`: Business logic and API calls
- `providers/`: State management
- `constants/`: App-wide constants

### Naming
- Files: snake_case (e.g., `daily_screen.dart`)
- Classes: PascalCase (e.g., `DailyScreen`)
- Variables: camelCase (e.g., `selectedZodiac`)
- Constants: SCREAMING_SNAKE_CASE (e.g., `APP_NAME`)

### Code Style
- Use `const` constructors where possible
- Prefer single quotes for strings
- Extract widgets for reusability
- Keep build methods clean and readable

## Gemini AI Integration

### Service Pattern
```dart
final response = await _model.generateContent([Content.text(prompt)]);
final text = response.text ?? '{}';
final json = jsonDecode(text);
```

### JSON Extraction
- Gemini may wrap JSON in markdown code blocks
- Use regex to extract: `RegExp(r'```json\s*([\s\S]*?)\s*```')`

### Error Handling
- Try-catch in provider methods
- Set error state and notify listeners
- Show user-friendly error messages

## UI/UX Guidelines

### Colors
- Dark theme: `bgDark`, `cardDark`
- Light theme: `bgLight`, `cardLight`
- Accents: `accentPurple`, `accentBlue`, `gold`
- Status: `positive`, `negative`, `warning`

### Spacing
- Standard padding: 24px
- Card padding: 16-20px
- Element spacing: 8-16px
- Section spacing: 24-32px

### Components
- Cards: Rounded corners (16-20px), subtle borders
- Buttons: 16px padding, bold text
- Icons: 20-24px for UI, 40+ for features
- Gradients: Purple to Blue for premium features

## Common Patterns

### Loading States
```dart
if (provider.isLoading)
  CircularProgressIndicator(color: AppColors.accentPurple)
```

### Error States
```dart
if (provider.error != null)
  // Show error message with retry button
```

### Premium Checks
```dart
if (!authProvider.isPremium) {
  _showPremiumDialog();
  return;
}
```

### Refresh Pattern
```dart
RefreshIndicator(
  onRefresh: _loadData,
  child: SingleChildScrollView(...)
)
```

## Testing Checklist

- [ ] Splash screen animation works
- [ ] Auth form validation
- [ ] Zodiac selection saves correctly
- [ ] Daily horoscope loads from Gemini
- [ ] Theme toggle persists
- [ ] Premium upgrade flow works
- [ ] Compatibility analysis works
- [ ] Settings changes save
- [ ] Logout clears all data

## Build Commands

```bash
# Get dependencies
flutter pub get

# Run on device/emulator
flutter run

# Build APK
flutter build apk --release

# Build iOS
flutter build ios --release

# Clean build
flutter clean
```

## Environment Setup

1. Create `.env` file in root
2. Add `GEMINI_API_KEY=your_key_here`
3. Never commit `.env` to git
4. Use `flutter_dotenv` to load at runtime

## Performance Tips

- Use `const` constructors for static widgets
- Avoid rebuilding entire trees (use `Consumer` wisely)
- Extract complex widgets to separate classes
- Use `ListView.builder` for long lists
- Optimize images and assets

## Common Issues

### API Key Not Found
- Check `.env` file exists
- Verify `flutter_dotenv` is loaded in `main.dart`
- Ensure `.env` is in `pubspec.yaml` assets

### State Not Updating
- Call `notifyListeners()` in provider
- Use `context.watch<Provider>()` in build method
- Check provider is registered in `MultiProvider`

### Navigation Issues
- Use `Navigator.of(context).pushReplacement()` for auth flows
- Check `mounted` before navigation in async callbacks
- Use `MaterialPageRoute` for transitions
