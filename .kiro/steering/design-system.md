---
inclusion: always
---

# Zodi Design System Rules

This document defines the design system structure and integration patterns for converting Figma designs to Flutter code in the Zodi astrology application.

## 1. Token Definitions

### Color Tokens
Colors are defined in `lib/constants/colors.dart` using the `AppColors` class:

```dart
// Primary theme colors
AppColors.bgLight          // Light background: #FFE4EC (vibrant pink)
AppColors.cardLight        // Card background: #FFFFFF
AppColors.surfaceLight     // Surface: #FFCCE2

// Accent colors
AppColors.primaryPink      // #FF1493 (Deep Pink)
AppColors.accentPurple     // #9400D3 (Dark Violet)
AppColors.accentBlue       // #00BFFF (Deep Sky Blue)
AppColors.gold             // #FFD700

// Status colors
AppColors.positive         // #00FA9A (success states)
AppColors.negative         // #FF1493 (error states)
AppColors.warning          // #FF8C00

// Text colors
AppColors.textPrimary      // #8B008B (Dark Magenta)
AppColors.textSecondary    // #C71585
AppColors.textDark         // #4B0082 (Indigo)
AppColors.textLight        // #FFFFFF
```

### Gradient Tokens
Predefined gradients for consistent visual effects:

```dart
AppColors.pinkGradient     // Pink gradient for primary actions
AppColors.purpleGradient   // Purple gradient for premium features
AppColors.cosmicGradient   // Multi-color cosmic effect
AppColors.goldGradient     // Gold gradient for VIP features
```

### Zodiac-Specific Colors
Each zodiac sign has a dedicated color scheme in `lib/services/theme_service.dart`:

```dart
ThemeService.zodiacColors['aries']      // Red/Orange theme
ThemeService.zodiacColors['taurus']     // Green theme
ThemeService.zodiacColors['gemini']     // Yellow/Orange theme
// ... 12 zodiac signs total
```

### Typography Tokens
Text styles are defined inline but follow these patterns:

- **Headings**: Bold, 24-32px, `AppColors.textDark`
- **Body**: Regular, 16px, `AppColors.textPrimary`
- **Captions**: Regular, 14px, `AppColors.textSecondary`
- **Labels**: Medium, 12px, `AppColors.textMuted`

### Spacing Tokens
Standard spacing scale (use multiples of 4):

- **xs**: 4px - Tight spacing
- **sm**: 8px - Small gaps
- **md**: 16px - Default spacing
- **lg**: 24px - Section padding
- **xl**: 32px - Large sections
- **2xl**: 48px - Major sections

## 2. Component Library

### Component Architecture
Components are organized by type:

**Screens** (`lib/screens/`):
- Full-page components
- Handle navigation and state
- Examples: `daily_screen.dart`, `tarot_screen.dart`, `premium_screen.dart`

**Widgets** (`lib/widgets/`):
- Reusable UI components
- Stateless when possible
- Examples: `animated_card.dart`, `shimmer_loading.dart`, `premium_lock_overlay.dart`

### Key Components

#### Cards
```dart
Container(
  decoration: BoxDecoration(
    color: AppColors.cardLight,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: AppColors.borderLight, width: 2),
  ),
  padding: EdgeInsets.all(20),
  child: // content
)
```

#### Buttons
```dart
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.primaryPink,
    foregroundColor: AppColors.textLight,
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
  child: Text('Button Text', style: TextStyle(fontWeight: FontWeight.bold)),
)
```

#### Premium Lock Overlay
```dart
// Use PremiumLockOverlay widget for locked features
PremiumLockOverlay(
  isLocked: !isPremium,
  onUpgrade: () => Navigator.push(...),
  child: // locked content
)
```

#### Loading States
```dart
// Use ShimmerLoading widget for skeleton screens
ShimmerLoading(
  width: double.infinity,
  height: 100,
  borderRadius: 20,
)
```

## 3. Frameworks & Libraries

### UI Framework
- **Flutter SDK**: Cross-platform mobile framework
- **Material 3**: Design system (useMaterial3: true)
- **Provider**: State management pattern

### Key Dependencies
```yaml
flutter:
  sdk: flutter
provider: ^6.0.0              # State management
shared_preferences: ^2.0.0    # Local storage
google_generative_ai: ^0.2.0  # Gemini AI
flutter_dotenv: ^5.0.0        # Environment variables
```

### State Management Pattern
```dart
// Provider pattern for app-wide state
class HoroscopeProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  
  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Load data
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

## 4. Asset Management

### Asset Structure
```
assets/
├── tarot/           # Tarot card images (0.webp - 21.webp)
├── zodi_logo.webp   # App logo
├── zodi_splash.mp4  # Splash animation
└── dozi_char.webp   # Character illustration
```

### Asset Declaration
All assets must be declared in `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/
    - assets/tarot/
    - .env
```

### Asset Usage
```dart
// Images
Image.asset('assets/zodi_logo.webp', width: 120, height: 120)

// Tarot cards (numbered 0-21)
Image.asset('assets/tarot/${cardNumber}.webp', fit: BoxFit.cover)
```

### Asset Optimization
- Use WebP format for images (smaller size, good quality)
- Provide appropriate dimensions in Image widgets
- Use `fit: BoxFit.cover` for cards, `fit: BoxFit.contain` for logos

## 5. Icon System

### Icon Library
Using Material Icons (built-in with Flutter):

```dart
import 'package:flutter/material.dart';

// Common icons
Icons.star              // Ratings, favorites
Icons.favorite          // Love/heart
Icons.attach_money      // Money/finance
Icons.health_and_safety // Health
Icons.work              // Career
Icons.settings          // Settings
Icons.person            // Profile
Icons.lock              // Premium/locked features
```

### Icon Sizing
- **Small**: 16-20px (inline with text)
- **Medium**: 24px (default UI icons)
- **Large**: 32-40px (feature icons)
- **Hero**: 48-64px (splash/empty states)

### Icon Colors
```dart
Icon(Icons.star, color: AppColors.gold, size: 24)
Icon(Icons.favorite, color: AppColors.primaryPink, size: 24)
Icon(Icons.lock, color: AppColors.accentPurple, size: 20)
```

## 6. Styling Approach

### Material 3 Theme
Theme is defined in `main.dart` and `lib/services/theme_service.dart`:

```dart
ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.primaryPink,
    brightness: Brightness.light,
  ),
  scaffoldBackgroundColor: AppColors.bgLight,
  cardColor: AppColors.cardLight,
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
  ),
)
```

### Responsive Design
```dart
// Use MediaQuery for responsive layouts
final screenWidth = MediaQuery.of(context).size.width;
final isSmallScreen = screenWidth < 360;

// Adjust spacing/sizing based on screen size
padding: EdgeInsets.all(isSmallScreen ? 16 : 24)
```

### Animation Patterns
```dart
// Animated backgrounds (premium feature)
AnimatedBackground(
  animationType: AnimationType.particles,
  child: // content
)

// Card animations
AnimatedCard(
  delay: Duration(milliseconds: 100),
  child: // card content
)
```

## 7. Figma Integration Patterns

### Converting Figma to Flutter

When receiving Figma designs via MCP:

1. **Replace Tailwind with Flutter Widgets**
   - `className="flex"` → `Row()` or `Column()`
   - `className="p-4"` → `padding: EdgeInsets.all(16)`
   - `className="rounded-lg"` → `borderRadius: BorderRadius.circular(16)`

2. **Map Colors to AppColors**
   - Extract hex colors from Figma
   - Map to existing `AppColors` constants
   - Create new constants if needed for consistency

3. **Use Existing Components**
   - Check `lib/widgets/` for reusable components
   - Prefer `AnimatedCard` over plain `Container`
   - Use `ShimmerLoading` for loading states
   - Use `PremiumLockOverlay` for locked features

4. **Maintain Zodiac Theming**
   - Apply zodiac-specific colors via `ThemeService`
   - Use `getZodiacColors()` for dynamic theming
   - Respect user's selected zodiac sign

5. **Preserve Turkish Language**
   - All UI text must be in Turkish
   - Use `AppStrings` constants when available
   - Add new strings to `lib/constants/strings.dart`

### Example Conversion

**Figma Output (React/Tailwind):**
```jsx
<div className="bg-white rounded-2xl p-6 shadow-lg">
  <h2 className="text-2xl font-bold text-purple-900">Günlük Yorum</h2>
  <p className="text-gray-600 mt-2">Bugün şanslı gününüz!</p>
</div>
```

**Flutter Conversion:**
```dart
Container(
  decoration: BoxDecoration(
    color: AppColors.cardLight,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 10,
        offset: Offset(0, 4),
      ),
    ],
  ),
  padding: EdgeInsets.all(24),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Günlük Yorum',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
        ),
      ),
      SizedBox(height: 8),
      Text(
        'Bugün şanslı gününüz!',
        style: TextStyle(
          fontSize: 16,
          color: AppColors.textSecondary,
        ),
      ),
    ],
  ),
)
```

## 8. Code Connect Workflow

### Mapping Figma Components to Flutter

When a Figma component is identified:

1. **Check for existing Flutter widget** in `lib/widgets/` or `lib/screens/`
2. **Use `add_code_connect_map` tool** to link Figma node to Flutter file
3. **Maintain consistency** between design and implementation

Example mapping:
```dart
// Figma node: "Daily Card Component"
// Flutter file: lib/widgets/daily_card.dart
// Component name: DailyCard
```

### Premium Feature Indicators

Always wrap premium features with lock overlay:

```dart
if (!isPremium) {
  return PremiumLockOverlay(
    isLocked: true,
    onUpgrade: () => _showPremiumScreen(),
    child: _buildLockedContent(),
  );
}
```

## 9. Best Practices

### Performance
- Use `const` constructors wherever possible
- Extract complex widgets to separate files
- Use `ListView.builder` for long lists
- Optimize images (WebP format, appropriate sizes)

### Accessibility
- Provide semantic labels for icons
- Ensure sufficient color contrast (already high in Zodi theme)
- Support text scaling
- Add tooltips for icon-only buttons

### Consistency
- Always use `AppColors` constants (never hardcode colors)
- Follow spacing scale (multiples of 4)
- Use existing widgets before creating new ones
- Maintain Turkish language throughout

### Error Handling
- Show user-friendly error messages in Turkish
- Provide retry mechanisms
- Use `ShimmerLoading` during data fetch
- Handle offline states gracefully

## 10. Gemini AI Integration

### Prompt Structure
All AI-generated content follows this pattern:

```dart
final prompt = '''
Sen Zodi'sin, samimi ve dürüst bir astroloji asistanı.
Kullanıcının burcu: $zodiacSign
Tarih: ${DateTime.now()}

[Specific request details]

JSON formatında yanıt ver:
{
  "content": "...",
  "metrics": {...}
}
''';
```

### Response Handling
```dart
final response = await geminiService.generateContent(prompt);
final jsonText = _extractJson(response.text);
final data = jsonDecode(jsonText);
```

### Content Tone
- Casual and friendly ("sen" form, not "siz")
- Honest and sometimes blunt
- Modern Turkish (avoid archaic terms)
- Emoji usage for emphasis 🌟✨💫

---

## Summary

When integrating Figma designs into Zodi:

1. ✅ Use `AppColors` constants for all colors
2. ✅ Follow spacing scale (4, 8, 16, 24, 32, 48)
3. ✅ Reuse existing widgets from `lib/widgets/`
4. ✅ Apply zodiac theming via `ThemeService`
5. ✅ Maintain Turkish language
6. ✅ Wrap premium features with `PremiumLockOverlay`
7. ✅ Use Material 3 components
8. ✅ Optimize assets (WebP format)
9. ✅ Handle loading/error states
10. ✅ Test on multiple screen sizes
