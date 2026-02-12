# NotificationService Usage Guide

## Overview

The `NotificationService` class provides a complete notification system for the Zodi app, including:
- Permission management for Android and iOS
- Daily notification scheduling with timezone support
- AI-generated notification previews using Gemini
- Notification content updates when zodiac changes

## Implementation Summary

### Completed Methods

#### 1. `requestPermissions()` ✅
Requests notification permissions from the user on both Android and iOS platforms.

```dart
final notificationService = NotificationService();
await notificationService.initialize();

final granted = await notificationService.requestPermissions();
if (granted) {
  print('Notifications enabled!');
} else {
  print('User denied notification permissions');
}
```

#### 2. `scheduleDaily()` ✅
Schedules a daily notification at the specified time with the user's zodiac sign.

```dart
await notificationService.scheduleDaily(
  time: TimeOfDay(hour: 9, minute: 0),
  zodiacSign: 'Koç',
);
```

#### 3. `cancelAll()` ✅
Cancels all scheduled notifications.

```dart
await notificationService.cancelAll();
```

#### 4. `updateNotificationContent()` ✅
Updates notification content when the user changes their zodiac sign. This method cancels existing notifications, and the caller should reschedule with the new zodiac.

```dart
// User changed zodiac from Koç to Boğa
await notificationService.updateNotificationContent('Boğa');

// Reschedule with new zodiac
await notificationService.scheduleDaily(
  time: TimeOfDay(hour: 9, minute: 0),
  zodiacSign: 'Boğa',
);
```

#### 5. `generateNotificationPreview()` ✅
Generates a personalized notification preview using Gemini AI. Returns a 50-80 character preview text.

```dart
final preview = await notificationService.generateNotificationPreview('Koç');
print(preview); // "Bugün enerjin yüksek! Yeni başlangıçlar seni bekliyor ✨"
```

### Bonus Method: `scheduleDailyWithPreview()`

An enhanced scheduling method that automatically generates AI-powered preview content:

```dart
await notificationService.scheduleDailyWithPreview(
  hour: 9,
  minute: 0,
  zodiacName: 'Koç',
);
```

This method:
1. Generates a personalized preview using Gemini
2. Schedules the notification with the AI-generated content
3. Falls back to standard notification if preview generation fails

## Integration with Settings Screen

Here's how to integrate the NotificationService into the settings screen:

```dart
class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final NotificationService _notificationService = NotificationService();
  bool _notificationsEnabled = false;
  TimeOfDay _notificationTime = TimeOfDay(hour: 9, minute: 0);
  String _zodiacSign = 'Koç';

  @override
  void initState() {
    super.initState();
    _notificationService.initialize();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    // Load from SharedPreferences or Firebase
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? false;
      _zodiacSign = prefs.getString('zodiac_sign') ?? 'Koç';
    });
  }

  Future<void> _toggleNotifications(bool enabled) async {
    if (enabled) {
      // Request permissions
      final granted = await _notificationService.requestPermissions();
      if (!granted) {
        // Show error dialog
        return;
      }

      // Schedule notification
      await _notificationService.scheduleDaily(
        time: _notificationTime,
        zodiacSign: _zodiacSign,
      );
    } else {
      // Cancel notifications
      await _notificationService.cancelAll();
    }

    setState(() {
      _notificationsEnabled = enabled;
    });

    // Save to preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', enabled);
  }

  Future<void> _changeNotificationTime() async {
    final newTime = await showTimePicker(
      context: context,
      initialTime: _notificationTime,
    );

    if (newTime != null) {
      setState(() {
        _notificationTime = newTime;
      });

      // Reschedule if notifications are enabled
      if (_notificationsEnabled) {
        await _notificationService.scheduleDaily(
          time: newTime,
          zodiacSign: _zodiacSign,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ayarlar')),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text('Günlük Bildirimler'),
            subtitle: Text('Her gün falını bildirim olarak al'),
            value: _notificationsEnabled,
            onChanged: _toggleNotifications,
          ),
          if (_notificationsEnabled)
            ListTile(
              title: Text('Bildirim Saati'),
              subtitle: Text('${_notificationTime.format(context)}'),
              trailing: Icon(Icons.access_time),
              onTap: _changeNotificationTime,
            ),
        ],
      ),
    );
  }
}
```

## Handling Zodiac Changes

When a user changes their zodiac sign, update the notification content:

```dart
Future<void> _changeZodiacSign(String newZodiacSign) async {
  // Update notification content
  await _notificationService.updateNotificationContent(newZodiacSign);

  // Reschedule with new zodiac if notifications are enabled
  if (_notificationsEnabled) {
    await _notificationService.scheduleDaily(
      time: _notificationTime,
      zodiacSign: newZodiacSign,
    );
  }

  // Save to preferences
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('zodiac_sign', newZodiacSign);
}
```

## Notification Tap Handling

To handle notification taps and navigate to the daily horoscope screen, you need to configure the notification initialization:

```dart
Future<void> initialize() async {
  if (_initialized) return;

  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));

  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosSettings = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  const initSettings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );

  // Add notification tap callback
  await _notifications.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      // Navigate to daily horoscope screen
      // This will be handled in task 1.4
    },
  );

  _initialized = true;
}
```

## Testing

Run the test suite to verify the implementation:

```bash
flutter test test/notification_service_test.dart
```

The test suite covers:
- Singleton pattern verification
- Method signature validation
- Zodiac sign handling
- Preview generation
- Integration scenarios

## Features

### ✅ Timezone Support
- Uses `timezone` package for accurate scheduling
- Configured for Turkey timezone (Europe/Istanbul)
- Handles daylight saving time automatically

### ✅ AI-Generated Previews
- Integrates with Gemini Service
- Generates personalized 50-80 character previews
- Falls back to generic message if AI fails
- Uses `fetchTomorrowPreview()` for relevant content

### ✅ Cross-Platform Support
- Android: Uses notification channels with high priority
- iOS: Requests alert, badge, and sound permissions
- Handles platform-specific permission flows

### ✅ Error Handling
- Graceful fallbacks for AI failures
- Safe zodiac sign lookups with defaults
- Try-catch blocks for all async operations

## Next Steps

The following tasks remain to complete the notification feature:

1. **Task 1.3**: Create notification settings UI
   - Add notification toggle to settings screen
   - Add time picker for scheduling
   - Add notification preview display
   - Persist preferences to Firebase

2. **Task 1.4**: Implement notification tap handling
   - Configure tap to open daily horoscope screen
   - Handle app launch from notification
   - Handle background notification taps

3. **Task 1.5**: Test notification functionality
   - Test permission request flow
   - Test daily notification scheduling
   - Test content generation
   - Test tap navigation

## Dependencies

The NotificationService requires the following packages (already in pubspec.yaml):
- `flutter_local_notifications` - Local notification support
- `timezone` - Timezone-aware scheduling
- `google_generative_ai` - Gemini AI integration (via GeminiService)

## Notes

- The service uses a singleton pattern for consistent state
- Notification ID 0 is reserved for daily horoscope notifications
- The service must be initialized before use
- Permissions should be requested before scheduling
- Preview generation is async and may take 1-2 seconds
