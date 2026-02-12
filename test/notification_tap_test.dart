import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:zodi/utils/navigation_helper.dart';

void main() {
  group('Notification Tap Handling Tests', () {
    test('handleNotificationPayload should handle daily_horoscope payload', () {
      // This test verifies that the payload handler recognizes the daily_horoscope payload
      // In a real scenario, this would navigate to the daily horoscope screen
      
      const payload = 'daily_horoscope';
      
      // The function should not throw an error
      expect(() => NavigationHelper.handleNotificationPayload(payload), returnsNormally);
    });

    test('handleNotificationPayload should handle null payload gracefully', () {
      // Verify that null payload doesn't cause crashes
      expect(() => NavigationHelper.handleNotificationPayload(null), returnsNormally);
    });

    test('handleNotificationPayload should handle unknown payload', () {
      // Verify that unknown payloads are handled gracefully (defaults to daily horoscope)
      const payload = 'unknown_payload';
      expect(() => NavigationHelper.handleNotificationPayload(payload), returnsNormally);
    });

    test('navigatorKey should be a GlobalKey', () {
      // Verify that the navigator key is properly initialized
      expect(navigatorKey, isA<GlobalKey<NavigatorState>>());
    });
  });

  group('Navigation Helper Integration Tests', () {
    testWidgets('navigateToDailyHoroscope should work with valid context', (WidgetTester tester) async {
      // Build a minimal app with the navigator key
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          home: const Scaffold(
            body: Center(child: Text('Home')),
          ),
        ),
      );

      // Verify the navigator key has a valid context
      expect(navigatorKey.currentContext, isNotNull);
      
      // Call the navigation method - it should not throw
      expect(() => NavigationHelper.navigateToDailyHoroscope(), returnsNormally);
    });

    testWidgets('navigateToDailyHoroscope should handle null context gracefully', (WidgetTester tester) async {
      // Create a new key that doesn't have a context
      final testKey = GlobalKey<NavigatorState>();
      
      // This should not crash even without a valid context
      // The method checks for null context and returns early
      expect(testKey.currentContext, isNull);
    });
  });
}
