import '../services/notification_service.dart';

/// Helper class for testing notification functionality
/// This is for development/testing purposes only
class NotificationTestHelper {
  static final NotificationService _notificationService = NotificationService();

  /// Trigger an instant test notification to verify tap handling
  /// This notification will navigate to daily horoscope when tapped
  static Future<void> triggerTestNotification() async {
    await _notificationService.showInstantNotification(
      title: '🌟 Test Bildirimi',
      body: 'Günlük falına gitmek için dokun!',
    );
  }

  /// Schedule a test notification for 10 seconds from now
  /// Useful for testing cold start scenario
  static Future<void> scheduleTestNotificationIn10Seconds() async {
    // Note: This uses the instant notification which doesn't support scheduling
    // For actual scheduled notifications, use scheduleDailyHoroscope
    await Future.delayed(const Duration(seconds: 10));
    await triggerTestNotification();
  }

  /// Request notification permissions
  /// Call this before testing notifications
  static Future<bool> requestPermissions() async {
    return await _notificationService.requestPermissions();
  }

  /// Cancel all notifications
  /// Useful for cleaning up after tests
  static Future<void> cancelAllNotifications() async {
    await _notificationService.cancelAll();
  }
}
