import 'package:flutter/material.dart';

/// Global navigation key for navigating without context
/// Used by NotificationService to navigate when notification is tapped
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Navigation helper class for handling deep links and notification navigation
class NavigationHelper {
  /// Navigate to daily horoscope screen
  /// This works regardless of app state (foreground, background, or terminated)
  static void navigateToDailyHoroscope() {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    // Navigate to home screen (which contains daily horoscope as first tab)
    // If already on home screen, this will just ensure we're on the daily tab
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  /// Handle notification payload and navigate accordingly
  static void handleNotificationPayload(String? payload) {
    if (payload == null) return;

    switch (payload) {
      case 'daily_horoscope':
        navigateToDailyHoroscope();
        break;
      // Add more cases for other notification types in the future
      default:
        navigateToDailyHoroscope();
    }
  }
}
