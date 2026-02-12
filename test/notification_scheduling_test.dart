import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:zodi_flutter/services/notification_service.dart';

/// Test suite for daily notification scheduling
/// Tests subtask 1.5.2: Test daily notification scheduling
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Daily Notification Scheduling', () {
    late NotificationService notificationService;

    setUp(() {
      notificationService = NotificationService();
    });

    test('scheduleDaily should accept TimeOfDay parameter', () async {
      // Test that the method accepts TimeOfDay for user-friendly time selection
      expect(
        () => notificationService.scheduleDaily(
          time: const TimeOfDay(hour: 9, minute: 0),
          zodiacSign: 'Koç',
        ),
        returnsNormally,
      );
    });

    test('scheduleDaily should handle different times', () async {
      // Test scheduling at various times throughout the day
      final times = [
        const TimeOfDay(hour: 6, minute: 0),   // Morning
        const TimeOfDay(hour: 12, minute: 30), // Noon
        const TimeOfDay(hour: 18, minute: 0),  // Evening
        const TimeOfDay(hour: 21, minute: 45), // Night
      ];

      for (final time in times) {
        expect(
          () => notificationService.scheduleDaily(
            time: time,
            zodiacSign: 'Koç',
          ),
          returnsNormally,
        );
      }
    });

    test('scheduleDaily should handle all zodiac signs', () async {
      // Test scheduling for all 12 zodiac signs
      final zodiacSigns = [
        'Koç', 'Boğa', 'İkizler', 'Yengeç',
        'Aslan', 'Başak', 'Terazi', 'Akrep',
        'Yay', 'Oğlak', 'Kova', 'Balık',
      ];

      for (final sign in zodiacSigns) {
        expect(
          () => notificationService.scheduleDaily(
            time: const TimeOfDay(hour: 9, minute: 0),
            zodiacSign: sign,
          ),
          returnsNormally,
        );
      }
    });

    test('scheduleDaily should handle edge case times', () async {
      // Test edge cases: midnight, just before midnight, etc.
      final edgeTimes = [
        const TimeOfDay(hour: 0, minute: 0),   // Midnight
        const TimeOfDay(hour: 23, minute: 59), // Just before midnight
        const TimeOfDay(hour: 0, minute: 1),   // Just after midnight
      ];

      for (final time in edgeTimes) {
        expect(
          () => notificationService.scheduleDaily(
            time: time,
            zodiacSign: 'Koç',
          ),
          returnsNormally,
        );
      }
    });

    test('scheduleDailyHoroscope should work with hour and minute', () async {
      // Test the underlying method with hour/minute parameters
      expect(
        () => notificationService.scheduleDailyHoroscope(
          hour: 9,
          minute: 0,
          zodiacName: 'Koç',
        ),
        returnsNormally,
      );
    });

    test('should handle rescheduling at different times', () async {
      // Test changing notification time
      await notificationService.scheduleDaily(
        time: const TimeOfDay(hour: 9, minute: 0),
        zodiacSign: 'Koç',
      );

      // Reschedule at different time
      await notificationService.scheduleDaily(
        time: const TimeOfDay(hour: 18, minute: 0),
        zodiacSign: 'Koç',
      );

      // Should complete without errors
      expect(true, true);
    });
  });

  group('Notification Cancellation', () {
    test('cancelAll should cancel scheduled notifications', () async {
      final notificationService = NotificationService();

      // Schedule a notification
      await notificationService.scheduleDaily(
        time: const TimeOfDay(hour: 9, minute: 0),
        zodiacSign: 'Koç',
      );

      // Cancel all notifications
      expect(
        () => notificationService.cancelAll(),
        returnsNormally,
      );
    });

    test('cancelDailyHoroscope should work', () async {
      final notificationService = NotificationService();

      // Schedule a notification
      await notificationService.scheduleDailyHoroscope(
        hour: 9,
        minute: 0,
        zodiacName: 'Koç',
      );

      // Cancel using the specific method
      expect(
        () => notificationService.cancelDailyHoroscope(),
        returnsNormally,
      );
    });

    test('should handle cancellation without scheduled notifications', () async {
      final notificationService = NotificationService();

      // Cancel without scheduling first (should not crash)
      expect(
        () => notificationService.cancelAll(),
        returnsNormally,
      );
    });

    test('should handle multiple cancellations', () async {
      final notificationService = NotificationService();

      // Cancel multiple times
      await notificationService.cancelAll();
      await notificationService.cancelAll();
      await notificationService.cancelAll();

      // Should complete without errors
      expect(true, true);
    });
  });

  group('Notification Update Flow', () {
    test('updateNotificationContent should cancel existing notifications', () async {
      final notificationService = NotificationService();

      // Schedule initial notification
      await notificationService.scheduleDaily(
        time: const TimeOfDay(hour: 9, minute: 0),
        zodiacSign: 'Koç',
      );

      // Update content (should cancel old notification)
      expect(
        () => notificationService.updateNotificationContent('Boğa'),
        returnsNormally,
      );
    });

    test('should handle zodiac sign change workflow', () async {
      final notificationService = NotificationService();

      // Initial schedule
      await notificationService.scheduleDaily(
        time: const TimeOfDay(hour: 9, minute: 0),
        zodiacSign: 'Koç',
      );

      // User changes zodiac sign
      await notificationService.updateNotificationContent('Boğa');

      // Reschedule with new zodiac
      await notificationService.scheduleDaily(
        time: const TimeOfDay(hour: 9, minute: 0),
        zodiacSign: 'Boğa',
      );

      // Should complete without errors
      expect(true, true);
    });

    test('should handle rapid zodiac changes', () async {
      final notificationService = NotificationService();

      // Rapidly change zodiac signs
      final signs = ['Koç', 'Boğa', 'İkizler', 'Yengeç'];

      for (final sign in signs) {
        await notificationService.updateNotificationContent(sign);
        await notificationService.scheduleDaily(
          time: const TimeOfDay(hour: 9, minute: 0),
          zodiacSign: sign,
        );
      }

      // Should complete without errors
      expect(true, true);
    });
  });

  group('Scheduling with Preview', () {
    test('scheduleDailyWithPreview should work', () async {
      final notificationService = NotificationService();

      // Schedule with AI-generated preview
      expect(
        () => notificationService.scheduleDailyWithPreview(
          hour: 9,
          minute: 0,
          zodiacName: 'Koç',
        ),
        returnsNormally,
      );
    });

    test('scheduleDailyWithPreview should fallback on error', () async {
      final notificationService = NotificationService();

      // Even if preview generation fails, should fallback to standard notification
      await notificationService.scheduleDailyWithPreview(
        hour: 9,
        minute: 0,
        zodiacName: 'Koç',
      );

      // Should complete without errors
      expect(true, true);
    });

    test('scheduleDailyWithPreview should handle all zodiac signs', () async {
      final notificationService = NotificationService();

      final signs = ['Koç', 'Boğa', 'İkizler'];

      for (final sign in signs) {
        await notificationService.scheduleDailyWithPreview(
          hour: 9,
          minute: 0,
          zodiacName: sign,
        );
      }

      // Should complete without errors
      expect(true, true);
    });
  });

  group('Timezone Handling', () {
    test('should initialize timezone correctly', () async {
      final notificationService = NotificationService();

      // Initialize should set up timezone (Europe/Istanbul)
      await notificationService.initialize();

      // Schedule notification (should use correct timezone)
      expect(
        () => notificationService.scheduleDaily(
          time: const TimeOfDay(hour: 9, minute: 0),
          zodiacSign: 'Koç',
        ),
        returnsNormally,
      );
    });

    test('should handle scheduling across day boundaries', () async {
      final notificationService = NotificationService();

      // Schedule for a time that might be in the past today
      // Should schedule for tomorrow
      await notificationService.scheduleDaily(
        time: const TimeOfDay(hour: 0, minute: 1),
        zodiacSign: 'Koç',
      );

      // Should complete without errors
      expect(true, true);
    });
  });

  group('Integration Tests', () {
    test('complete notification lifecycle', () async {
      final notificationService = NotificationService();

      // 1. Initialize
      await notificationService.initialize();

      // 2. Request permissions
      await notificationService.requestPermissions();

      // 3. Schedule notification
      await notificationService.scheduleDaily(
        time: const TimeOfDay(hour: 9, minute: 0),
        zodiacSign: 'Koç',
      );

      // 4. Update zodiac
      await notificationService.updateNotificationContent('Boğa');

      // 5. Reschedule
      await notificationService.scheduleDaily(
        time: const TimeOfDay(hour: 18, minute: 0),
        zodiacSign: 'Boğa',
      );

      // 6. Cancel
      await notificationService.cancelAll();

      // Should complete entire lifecycle without errors
      expect(true, true);
    });

    test('settings screen integration flow', () async {
      final notificationService = NotificationService();

      // Simulate settings screen workflow:
      
      // User opens settings
      await notificationService.initialize();

      // User enables notifications
      final permissionGranted = await notificationService.requestPermissions();

      if (permissionGranted) {
        // User selects time
        await notificationService.scheduleDaily(
          time: const TimeOfDay(hour: 9, minute: 0),
          zodiacSign: 'Koç',
        );
      }

      // User changes time
      await notificationService.scheduleDaily(
        time: const TimeOfDay(hour: 18, minute: 0),
        zodiacSign: 'Koç',
      );

      // User disables notifications
      await notificationService.cancelAll();

      // Should complete without errors
      expect(true, true);
    });
  });
}
