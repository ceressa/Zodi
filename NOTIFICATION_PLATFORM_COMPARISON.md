# Notification Configuration Platform Comparison

## Overview

This document provides a side-by-side comparison of notification configurations for Android and iOS platforms in the Zodi Flutter application.

## Configuration Summary

### Android (AndroidManifest.xml)
✅ **Completed in Task 1.1.3**

**Key Configurations:**
- Runtime notification permission (Android 13+)
- Exact alarm scheduling permissions
- Notification channels (daily_horoscope, instant)
- Boot receivers for persistence
- Wake lock for background delivery
- Notification tap handling

### iOS (Info.plist)
✅ **Completed in Task 1.1.4**

**Key Configurations:**
- Background modes (fetch, remote-notification)
- User notification permission description
- Local network usage description
- iOS 10+ UserNotifications framework
- Automatic notification persistence

## Detailed Comparison

| Aspect | Android | iOS |
|--------|---------|-----|
| **Configuration File** | `android/app/src/main/AndroidManifest.xml` | `ios/Runner/Info.plist` |
| **Minimum Version** | Android 8.0 (API 26) | iOS 10.0 |
| **Permission Model** | Runtime (Android 13+), Automatic (Android 12-) | Runtime (iOS 10+) |
| **Permission Description** | Not required | Required (NSUserNotificationsUsageDescription) |
| **Exact Scheduling** | SCHEDULE_EXACT_ALARM + USE_EXACT_ALARM | Built-in support |
| **Background Delivery** | WAKE_LOCK + Receivers | UIBackgroundModes |
| **Boot Persistence** | ScheduledNotificationBootReceiver | iOS handles automatically |
| **Notification Channels** | Required (API 26+) | Not used (uses categories instead) |
| **Vibration** | Separate VIBRATE permission | Included in notification permission |
| **Lock Screen** | showWhenLocked + turnScreenOn | Automatic |
| **Tap Handling** | Intent filter for FLUTTER_NOTIFICATION_CLICK | Automatic via flutter_local_notifications |

## Permission Descriptions

### Android
**Not Required** - Android doesn't require a user-facing description for notification permissions. The system handles the permission dialog automatically.

### iOS
**Required** - Must provide clear explanation in user's language:

```xml
<key>NSUserNotificationsUsageDescription</key>
<string>Zodi günlük burç yorumlarını ve kişiselleştirilmiş astroloji bildirimlerini göndermek için bildirim izni istiyor.</string>
```

**Translation**: "Zodi requests notification permission to send daily horoscope readings and personalized astrology notifications."

## Background Modes

### Android
Uses multiple components:
- **WAKE_LOCK**: Keeps device awake for notification delivery
- **ScheduledNotificationReceiver**: Handles scheduled notifications
- **ScheduledNotificationBootReceiver**: Restores notifications after reboot

### iOS
Uses single configuration:
```xml
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
```

## Notification Channels

### Android
**Required for API 26+**

Two channels configured in NotificationService:
1. **daily_horoscope**: High importance, for daily horoscope reminders
2. **instant**: High importance, for instant notifications (achievements, streaks)

Users can customize each channel independently in Android settings.

### iOS
**Not Used**

iOS uses notification categories instead of channels. Categories are optional and used for grouping notifications with similar actions.

## Exact Alarm Scheduling

### Android
**Requires Explicit Permissions**

```xml
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.USE_EXACT_ALARM"/>
```

Needed for precise daily notification timing (e.g., exactly 9:00 AM).

### iOS
**Built-in Support**

iOS automatically supports exact scheduling through the UserNotifications framework. No special permissions needed.

## Boot Persistence

### Android
**Manual Configuration Required**

```xml
<receiver 
    android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver"
    android:exported="false">
    <intent-filter>
        <action android:name="android.intent.action.BOOT_COMPLETED"/>
        <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
        <!-- Additional manufacturer-specific actions -->
    </intent-filter>
</receiver>
```

Handles multiple boot scenarios including device restart and app updates.

### iOS
**Automatic**

iOS automatically persists scheduled notifications across device restarts. No additional configuration needed.

## User Experience Differences

### Permission Request

**Android 13+:**
- System dialog: "Allow Zodi to send you notifications?"
- Options: "Allow" or "Don't allow"
- No custom description shown

**Android 12 and below:**
- No permission dialog (notifications enabled by default)
- Users can disable in settings

**iOS:**
- System dialog with custom description
- Shows: "Zodi günlük burç yorumlarını ve kişiselleştirilmiş astroloji bildirimlerini göndermek için bildirim izni istiyor."
- Options: "Allow" or "Don't Allow"
- More prominent and user-friendly

### Notification Appearance

**Android:**
- Notification icon (app launcher icon)
- Title and body text
- Expandable for longer content
- Action buttons (if configured)
- Grouped by channel

**iOS:**
- App icon badge
- Title and body text
- Banner or alert style (user preference)
- Lock screen display
- Notification center grouping

### Settings Management

**Android:**
- Settings > Apps > Zodi > Notifications
- Per-channel control (daily_horoscope, instant)
- Granular control (sound, vibration, badge, etc.)

**iOS:**
- Settings > Zodi > Notifications
- Global notification toggle
- Banner style selection
- Sounds, badges, lock screen options

## Code Integration

Both platforms use the same Dart code via `flutter_local_notifications`:

```dart
// Works identically on both platforms
await notificationService.requestPermissions();
await notificationService.scheduleDailyHoroscope(
  hour: 9,
  minute: 0,
  zodiacName: 'Koç',
);
```

Platform-specific behavior is handled automatically by the plugin based on the configuration files.

## Testing Considerations

### Android Testing
- Test on Android 13+ for runtime permission
- Test on Android 12 for exact alarm permission
- Test on Android 8-11 for channel behavior
- Test boot persistence by restarting device
- Test with different manufacturers (Samsung, Xiaomi, etc.)

### iOS Testing
- Test on iOS 10+ devices
- Test permission dialog shows correct Turkish text
- Test on iOS Simulator (most features work)
- Test on physical device for production validation
- Test with different Focus modes (Do Not Disturb, Sleep, etc.)

## Future Enhancements

### Remote Push Notifications

**Android:**
- Add Firebase Cloud Messaging (FCM)
- Configure google-services.json
- Add FCM service to AndroidManifest.xml

**iOS:**
- Enable Push Notifications capability in Xcode
- Configure APNs certificates
- UIBackgroundModes already includes 'remote-notification' ✅

### Rich Notifications

**Android:**
- Add BigPictureStyle for images
- Add BigTextStyle for long text
- Add custom notification layouts

**iOS:**
- Add Notification Service Extension
- Support images, videos, audio
- Add notification actions

## Best Practices Applied

### ✅ Security
- Android receivers not exported (android:exported="false")
- Minimal permissions requested
- No unnecessary background access

### ✅ Privacy
- Clear permission descriptions (iOS)
- User control over notification preferences
- Local notifications only (no tracking)

### ✅ User Experience
- Turkish language descriptions
- Clear purpose explanation
- Respect system settings (Do Not Disturb, Focus modes)

### ✅ Reliability
- Boot persistence on both platforms
- Exact timing for daily notifications
- Background delivery when app is closed

### ✅ Compatibility
- Android 8.0+ support
- iOS 10+ support
- Handles platform-specific requirements

## Summary

Both Android and iOS notification configurations are now complete and production-ready:

| Platform | Status | Configuration File | Key Features |
|----------|--------|-------------------|--------------|
| **Android** | ✅ Complete | AndroidManifest.xml | Runtime permissions, channels, boot persistence |
| **iOS** | ✅ Complete | Info.plist | Background modes, permission description, automatic persistence |

**Next Steps:**
1. Implement notification settings UI (Task 1.3)
2. Implement notification tap handling (Task 1.4)
3. Test on physical devices (Task 1.5)
4. Integrate with user preferences in Firebase

**Documentation:**
- Android: `NOTIFICATION_ANDROID_CONFIG.md`
- iOS: `NOTIFICATION_IOS_CONFIG.md`
- Comparison: `NOTIFICATION_PLATFORM_COMPARISON.md` (this file)
