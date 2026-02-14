import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/material.dart';
import 'gemini_service.dart';
import '../models/zodiac_sign.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  final GeminiService _geminiService = GeminiService();
  bool _initialized = false;

  // Callback for handling notification taps
  Function(String?)? _onNotificationTap;

  Future<void> initialize({Function(String?)? onNotificationTap}) async {
    if (_initialized) return;

    // Store the callback for notification taps
    _onNotificationTap = onNotificationTap;

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

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _handleNotificationTap,
    );
    _initialized = true;
  }

  /// Handle notification tap - called when user taps on a notification
  /// Works for both cold start (app not running) and background scenarios
  void _handleNotificationTap(NotificationResponse response) {
    // The payload can contain routing information
    // For daily horoscope notifications, we'll use 'daily_horoscope' as payload
    final payload = response.payload;
    
    // Call the registered callback if available
    if (_onNotificationTap != null) {
      _onNotificationTap!(payload);
    }
  }

  /// Check if the app was launched from a notification
  /// This should be called after initialize() to handle cold start scenarios
  Future<void> checkLaunchNotification() async {
    final details = await _notifications.getNotificationAppLaunchDetails();
    if (details != null && details.didNotificationLaunchApp) {
      final response = details.notificationResponse;
      if (response != null) {
        _handleNotificationTap(response);
      }
    }
  }

  Future<bool> requestPermissions() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      if (granted != null) {
        return granted;
      }

      // Android 12 and lower versions return null because runtime notification
      // permission does not exist. In that case fall back to current setting.
      final isEnabled = await androidPlugin.areNotificationsEnabled();
      return isEnabled ?? true;
    }

    final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    if (iosPlugin != null) {
      final granted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return false;
  }

  Future<void> scheduleDailyHoroscope({
    required int hour,
    required int minute,
    required String zodiacName,
  }) async {
    await _notifications.zonedSchedule(
      0, // notification id
      '🌟 Günlük Falın Hazır!',
      '$zodiacName burcu için bugünün falı seni bekliyor. Zodi ne diyor bakalım?',
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_horoscope',
          'Günlük Burç',
          channelDescription: 'Günlük burç yorumları',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'daily_horoscope',
    );
  }

  Future<void> cancelDailyHoroscope() async {
    await _notifications.cancel(0);
  }

  Future<void> showInstantNotification({
    required String title,
    required String body,
  }) async {
    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'instant',
          'Anlık Bildirimler',
          channelDescription: 'Anlık bildirimler',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: 'daily_horoscope', // Add payload for navigation
    );
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  // Interface methods matching design document

  /// Schedule daily notification at specified time
  /// Wrapper for scheduleDailyHoroscope with TimeOfDay parameter
  Future<void> scheduleDaily({
    required TimeOfDay time,
    required String zodiacSign,
  }) async {
    await scheduleDailyHoroscope(
      hour: time.hour,
      minute: time.minute,
      zodiacName: zodiacSign,
    );
  }

  /// Cancel all scheduled notifications
  /// Wrapper for cancelDailyHoroscope
  Future<void> cancelAll() async {
    await cancelDailyHoroscope();
  }

  /// Update notification content when user changes zodiac sign
  /// Reschedules the notification with new zodiac information
  Future<void> updateNotificationContent(String zodiacSign) async {
    // Get the currently scheduled notification time (if any)
    // Since we can't retrieve the scheduled time from the plugin,
    // we'll need to reschedule with a default time or the caller should
    // provide the time. For now, we'll cancel and let the caller reschedule.
    await cancelAll();
    
    // Note: The caller should call scheduleDaily() after this with the new zodiac
    // and their preferred time. This method just ensures old notifications are cleared.
  }

  /// Generate a short preview text for notification using Gemini AI
  /// Returns a 50-80 character preview of the daily horoscope
  Future<String> generateNotificationPreview(String zodiacSignName) async {
    try {
      // Find the zodiac sign enum from the name
      final zodiacSign = ZodiacSign.values.firstWhere(
        (sign) => sign.displayName == zodiacSignName,
        orElse: () => ZodiacSign.aries, // Default fallback
      );

      // Use Gemini service to generate a short preview
      final preview = await _geminiService.fetchTomorrowPreview(zodiacSign);
      
      // Ensure the preview is within 50-80 characters for notification
      if (preview.length > 80) {
        return '${preview.substring(0, 77)}...';
      } else if (preview.length < 50) {
        // If too short, add a generic suffix
        return '$preview ✨';
      }
      
      return preview;
    } catch (e) {
      // Fallback to a generic message if Gemini fails
      return '$zodiacSignName burcu için bugünün falı hazır! 🌟';
    }
  }

  /// Schedule daily notification with AI-generated preview content
  /// This is an enhanced version that generates personalized content
  Future<void> scheduleDailyWithPreview({
    required int hour,
    required int minute,
    required String zodiacName,
  }) async {
    try {
      // Generate personalized preview
      final preview = await generateNotificationPreview(zodiacName);
      
      await _notifications.zonedSchedule(
        0, // notification id
        '🌟 Günlük Falın Hazır!',
        preview,
        _nextInstanceOfTime(hour, minute),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_horoscope',
            'Günlük Burç',
            channelDescription: 'Günlük burç yorumları',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'daily_horoscope',
      );
    } catch (e) {
      // Fallback to standard notification if preview generation fails
      await scheduleDailyHoroscope(
        hour: hour,
        minute: minute,
        zodiacName: zodiacName,
      );
    }
  }
}
