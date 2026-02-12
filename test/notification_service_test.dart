import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:zodi_flutter/services/notification_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NotificationService', () {
    late NotificationService notificationService;

    setUp(() {
      notificationService = NotificationService();
    });

    test('should be a singleton', () {
      final instance1 = NotificationService();
      final instance2 = NotificationService();
      expect(instance1, equals(instance2));
    });

    test('scheduleDaily should accept TimeOfDay parameter', () async {
      // This test verifies the method signature exists and can be called
      // Actual scheduling would require platform-specific setup
      expect(
        () => notificationService.scheduleDaily(
          time: const TimeOfDay(hour: 9, minute: 0),
          zodiacSign: 'Koç',
        ),
        returnsNormally,
      );
    });

    test('cancelAll should be callable', () async {
      // Verify the method exists and can be called
      expect(
        () => notificationService.cancelAll(),
        returnsNormally,
      );
    });

    test('updateNotificationContent should accept zodiac sign', () async {
      // Verify the method exists and can be called
      expect(
        () => notificationService.updateNotificationContent('Koç'),
        returnsNormally,
      );
    });

    test('generateNotificationPreview should return a string', () async {
      // This test verifies the method signature
      // Actual Gemini call would require API key setup
      final preview = await notificationService.generateNotificationPreview('Koç');
      
      expect(preview, isA<String>());
      expect(preview.isNotEmpty, true);
      
      // Should have fallback message if Gemini fails
      expect(preview.contains('Koç'), true);
    });

    test('generateNotificationPreview should handle different zodiac signs', () async {
      final signs = ['Koç', 'Boğa', 'İkizler', 'Yengeç'];
      
      for (final sign in signs) {
        final preview = await notificationService.generateNotificationPreview(sign);
        expect(preview, isA<String>());
        expect(preview.isNotEmpty, true);
      }
    });

    test('generateNotificationPreview should limit length appropriately', () async {
      final preview = await notificationService.generateNotificationPreview('Koç');
      
      // Should be within reasonable notification length
      expect(preview.length, lessThanOrEqualTo(100));
    });

    test('requestPermissions should return a boolean', () async {
      // This test verifies the method signature
      // Actual permission request would require platform setup
      final result = await notificationService.requestPermissions();
      expect(result, isA<bool>());
    });
  });

  group('NotificationService Integration', () {
    test('should handle zodiac sign changes gracefully', () async {
      final notificationService = NotificationService();
      
      // Schedule for one sign
      await notificationService.scheduleDaily(
        time: const TimeOfDay(hour: 9, minute: 0),
        zodiacSign: 'Koç',
      );
      
      // Update to different sign
      await notificationService.updateNotificationContent('Boğa');
      
      // Reschedule with new sign
      await notificationService.scheduleDaily(
        time: const TimeOfDay(hour: 9, minute: 0),
        zodiacSign: 'Boğa',
      );
      
      // Should complete without errors
      expect(true, true);
    });
  });
}
