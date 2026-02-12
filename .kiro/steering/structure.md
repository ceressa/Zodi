# Project Structure

## Root Files

- `App.tsx` - Main application component with routing logic and state management
- `index.tsx` - Application entry point
- `index.html` - HTML template
- `types.ts` - TypeScript type definitions (ZodiacSign, DailyHoroscope, AppView, etc.)
- `constants.tsx` - Zodiac data, icons, colors, and app-wide constants
- `geminiService.ts` - Google Gemini AI service integration layer

## Directories

### `/components`
Reusable UI components:
- `Layout.tsx` - Main app layout with header, navigation, and content area
- `ProgressBar.tsx` - Progress/metric visualization
- `AdBanner.tsx` - Advertisement component

### `/views`
Full-page view components corresponding to app sections:
- `SplashView.tsx` - Initial loading screen
- `AuthView.tsx` - User authentication/login
- `SelectionView.tsx` - Zodiac sign selection
- `DailyView.tsx` - Daily horoscope display
- `AnalysisView.tsx` - Detailed astrological analysis
- `MatchView.tsx` - Compatibility matching
- `SettingsView.tsx` - User settings and preferences
- `PremiumView.tsx` - Premium upgrade flow

### Android Files (Root Level)
- `MainActivity.kt` - Android app entry point
- `GeminiRepository.kt` - Android data layer
- `Models.kt` - Kotlin data models
- `android_build.gradle` - Android build configuration

## Architecture Patterns

### State Management
- React hooks (`useState`, `useEffect`) for local state
- LocalStorage for persistence (user data, theme, zodiac selection, premium status)
- No external state management library

### Routing
- View-based navigation using enum (`AppView`)
- Conditional rendering in `App.tsx` based on active view
- No router library (single-page state machine)

### Data Flow
1. User selects zodiac → stored in localStorage
2. App fetches horoscope from Gemini API via `geminiService.ts`
3. Data flows down through props to view components
4. User actions bubble up via callbacks

### Styling
- CSS custom properties for theming (dark/light mode)
- Utility classes for common patterns
- Inline styles for dynamic values
- No CSS framework (custom styling)

## File Naming Conventions

- React components: PascalCase with `.tsx` extension
- Services/utilities: camelCase with `.ts` extension
- Kotlin files: PascalCase with `.kt` extension
- Types and constants: Descriptive names matching content
