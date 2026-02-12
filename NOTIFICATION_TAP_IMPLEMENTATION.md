# Notification Tap Handling Implementation

## Overview

This document describes the implementation of notification tap handling for the Zodi Flutter app. When users tap on a daily horoscope notification, the app opens directly to the daily horoscope screen, regardless of the app's current state (not running, background, or foreground).

## Implementation Details

### 1. NotificationService Updates

**File**: `lib/services/notification_service.dart`

#### Key Changes:

1. **Added callback support in initialize()**:
   - Added optional `onNotificationTap` parameter to `initialize()` method
   - Stores the callback for later use when notifications are tapped
   - Registers `_handleNotificationTap` as the notification response handler

2. **Added notification tap handler**:
   - `_handleNotificationTap()` method processes notification taps
   - Extracts payload from notification response
   - Calls the registered callback with the payload

3. **Added cold start detection**:
   - `checkLaunchNotification()` method checks if app was launched from a notification
   - Handles the scenario where the app was completely terminated
   - Should be called after `initialize()` in main.dart

4. **Added payload to all notifications**:
   - All notification scheduling methods now include `payload: 'daily_horoscope'`
   - Payload is used to determine navigation destination
   - Supports future expansion for different notification types

### 2. Navigation Helper

**File**: `lib/utils/navigation_helper.dart`

#### Components:

1. **Global Navigator Key**:
   ```dart
   final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
   ```
   - Allows navigation without BuildContext
   - Registered in MaterialApp in main.dart
   - Used by NotificationService to navigate from anywhere

2. **NavigationHelper Class**:
   - `navigateToDailyHoroscope()`: Navigates to the daily horoscope screen
   - `handleNotificationPayload()`: Routes based on notification payload
   - Extensible for future notification types

#### Navigation Logic:

- Uses `Navigator.popUntil()` to return to the root route (HomeScreen)
- HomeScreen's first tab is the DailyScreen, so users land on daily horoscope
- Safe null checking ensures no crashes if context is unavailable

### 3. Main App Integration

**File**: `lib/main.dart`

#### Changes:

1. **Import statements**:
   - Added `notification_service.dart` import
   - Added `navigation_helper.dart` import

2. **Notification initialization in main()**:
   ```dart
   await NotificationService().initialize(
     onNotificationTap: NavigationHelper.handleNotificationPayload,
   );
   await NotificationService().checkLaunchNotification();
   ```

3. **Navigator key registration**:
   - Added `navigatorKey: navigatorKey` to MaterialApp
   - Enables global navigation access

## How It Works

### Scenario 1: App Not Running (Cold Start)

1. User taps notification
2. App launches and runs `main()`
3. `NotificationService().initialize()` is called with callback
4. `checkLaunchNotification()` detects the launch notification
5. Callback is invoked with payload
6. `NavigationHelper.handleNotificationPayload()` is called
7. App navigates to daily horoscope screen once UI is ready

### Scenario 2: App in Background

1. User taps notification
2. App comes to foreground
3. `_handleNotificationTap()` is called automatically by flutter_local_notifications
4. Callback is invoked with payload
5. `NavigationHelper.handleNotificationPayload()` is called
6. App navigates to daily horoscope screen immediately

### Scenario 3: App in Foreground

1. User taps notification (if shown)
2. `_handleNotificationTap()` is called
3. Same flow as background scenario
4. App navigates to daily horoscope screen

## Testing

### Unit Tests

**File**: `test/notification_tap_test.dart`

Tests cover:
- Payload handling for 'daily_horoscope'
- Null payload handling
- Unknown payload handling
- Navigator key initialization
- Navigation with valid context
- Navigation with null context (graceful failure)

### Manual Testing Checklist

- [ ] **Cold Start Test**:
  1. Force close the app completely
  2. Schedule a notification for 1 minute from now
  3. Wait for notification to appear
  4. Tap the notification
  5. Verify app opens to daily horoscope screen

- [ ] **Background Test**:
  1. Open the app
  2. Navigate to a different screen (e.g., Settings)
  3. Press home button to background the app
  4. Trigger a test notification
  5. Tap the notification
  6. Verify app returns to daily horoscope screen

- [ ] **Foreground Test**:
  1. Keep app open on any screen
  2. Trigger a test notification
  3. Tap the notification
  4. Verify navigation to daily horoscope screen

### Test Notification Trigger

You can trigger a test notification using the instant notification method:

```dart
await NotificationService().showInstantNotification(
  title: '🌟 Test Notification',
  body: 'Tap to test navigation',
);
```

## Future Enhancements

### Multiple Notification Types

The payload system supports different notification types:

```dart
// In NotificationService
payload: 'natal_chart'  // Navigate to natal chart screen
payload: 'tarot_reading'  // Navigate to tarot screen
payload: 'achievement_unlocked'  // Navigate to achievements screen

// In NavigationHelper
static void handleNotificationPayload(String? payload) {
  switch (payload) {
    case 'daily_horoscope':
      navigateToDailyHoroscope();
      break;
    case 'natal_chart':
      navigateToNatalChart();
      break;
    case 'tarot_reading':
      navigateToTarot();
      break;
    // ... more cases
  }
}
```

### Deep Linking

For more complex navigation scenarios, consider:
- Passing additional data in payload (JSON string)
- Using deep link URLs as payload
- Implementing a routing system for complex navigation flows

## Dependencies

- `flutter_local_notifications`: ^17.0.0 (or latest)
- No additional dependencies required

## Platform-Specific Notes

### Android

- Notification channels are configured in `AndroidManifest.xml`
- Exact alarm permissions required for precise scheduling
- Works on Android 5.0+ (API 21+)

### iOS

- Notification permissions requested at runtime
- Works on iOS 10.0+
- Background notification handling requires proper entitlements

## Troubleshooting

### Navigation Not Working

1. **Check navigator key is registered**:
   - Verify `navigatorKey` is set in MaterialApp
   - Check import statement in main.dart

2. **Check callback is registered**:
   - Verify `onNotificationTap` is passed to `initialize()`
   - Check `checkLaunchNotification()` is called after initialize

3. **Check payload is set**:
   - Verify all notification methods include `payload` parameter
   - Check payload value matches switch cases in NavigationHelper

### App Crashes on Notification Tap

1. **Check for null context**:
   - NavigationHelper includes null checks
   - Verify navigator key has valid context

2. **Check navigation stack**:
   - Ensure HomeScreen is in the navigation stack
   - Verify route structure matches expected flow

## Code Quality

- ✅ Null safety compliant
- ✅ Error handling for edge cases
- ✅ Extensible design for future notification types
- ✅ Clean separation of concerns
- ✅ Well-documented code
- ✅ Unit tests included

## Related Files

- `lib/services/notification_service.dart` - Core notification logic
- `lib/utils/navigation_helper.dart` - Navigation handling
- `lib/main.dart` - App initialization
- `test/notification_tap_test.dart` - Unit tests
- `.kiro/specs/premium-features-enhancement/tasks.md` - Task tracking

## Task Completion

This implementation completes task 1.4 and its subtasks:

- ✅ 1.4.1 Configure notification tap to open daily horoscope screen
- ✅ 1.4.2 Handle app launch from notification (cold start)
- ✅ 1.4.3 Handle notification tap when app is in background

All three scenarios (cold start, background, foreground) are handled by the implementation.
