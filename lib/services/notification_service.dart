import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/material.dart';
import 'gemini_service.dart';
import '../models/zodiac_sign.dart';
import '../constants/astro_data.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  final GeminiService _geminiService = GeminiService();
  bool _initialized = false;
  final _random = Random();

  // Callback for handling notification taps
  Function(String?)? _onNotificationTap;

  // ===== HOOK BİLDİRİMLERİ — Merak Tetikleyici Mesajlar =====
  static const List<Map<String, String>> _hookTemplates = [
    // Günlük genel hook'lar
    {'title': '🔮 Bugün dikkat!', 'body': '{sign} için kritik bir gezegensel geçiş var...'},
    {'title': '⚡ Kozmik uyarı!', 'body': '{sign}, bugün beklenmedik bir haber alabilirsin...'},
    {'title': '💫 Yıldızlar konuşuyor!', 'body': '{sign} burcu bugün özel bir enerjiye sahip...'},
    {'title': '✨ Bugünkü falın hazır!', 'body': '{sign}, bugün aşk hayatında sürprizler olabilir...'},
    {'title': '🌙 Ay burcu etkisi!', 'body': 'Bugünkü Ay pozisyonu {sign} burcunu doğrudan etkiliyor...'},
    {'title': '🪐 Gezegen hareketleri!', 'body': '{sign}, bu hafta büyük bir dönüşümün eşiğindesin...'},
    {'title': '🌟 Kaçırma!', 'body': '{sign} için bugün şans kapısı aralanıyor...'},
    {'title': '💕 Aşk enerjisi yükseliyor!', 'body': '{sign}, bugün romantik sürprizlere hazır ol...'},
    {'title': '💰 Bolluk enerjisi!', 'body': '{sign} burcu için maddi fırsatlar beliriyor...'},
    {'title': '🔥 Ateşli bir gün!', 'body': '{sign}, enerjin bugün tavan yapacak...'},
    // Merak uyandıran hook'lar
    {'title': '👀 Bunu bilmen lazım!', 'body': '{sign} burcu için bugün çok önemli bir detay var...'},
    {'title': '🎯 Tam zamanı!', 'body': '{sign}, bugün bir karar vermen gerekebilir...'},
    {'title': '🌈 İyi haber!', 'body': 'Astro Dozi {sign} burcu için güzel şeyler görüyor...'},
    {'title': '⭐ Günün sürprizi!', 'body': '{sign} burcu bugün neyle karşılaşacak? Hemen bak!'},
    {'title': '🎪 Kozmik sahne senin!', 'body': '{sign}, bugün spot ışığı sende olabilir...'},
  ];

  // Öğle saati hook'ları (hatırlatma)
  static const List<Map<String, String>> _middayHooks = [
    {'title': '☀️ Öğle enerjisi!', 'body': '{sign}, günün ikinci yarısı için falına baktın mı?'},
    {'title': '🔄 Güncellemen var!', 'body': '{sign} burcu için öğleden sonra enerjiler değişiyor...'},
    {'title': '💡 Hızlı bir bakış!', 'body': 'Bugünkü şanslı sayın ve rengin ne? Astro Dozi\'de bak!'},
    {'title': '🎴 Tarot hatırlatma!', 'body': '{sign}, günlük tarot kartını çekmeyi unuttun mu?'},
  ];

  // Akşam hook'ları
  static const List<Map<String, String>> _eveningHooks = [
    {'title': '🌙 Gece enerjisi!', 'body': '{sign}, yarın için kozmik önizleme hazır...'},
    {'title': '✨ Yarına hazır mısın?', 'body': '{sign} burcu için yarın neler olacak? İpucu bıraktık...'},
    {'title': '🌠 Yıldızların mesajı!', 'body': '{sign}, gece gökyüzü sana bir şey fısıldıyor...'},
    {'title': '💤 Uyumadan önce!', 'body': '{sign}, rüyanda göreceğin sembol hakkında bir ipucu var...'},
  ];

  Map<String, String> _getRandomHook(String zodiacName, {String period = 'morning'}) {
    final List<Map<String, String>> templates;
    switch (period) {
      case 'midday':
        templates = _middayHooks;
        break;
      case 'evening':
        templates = _eveningHooks;
        break;
      default:
        templates = _hookTemplates;
    }
    final template = templates[_random.nextInt(templates.length)];
    return {
      'title': template['title']!,
      'body': template['body']!.replaceAll('{sign}', zodiacName),
    };
  }

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
    // Önce mevcut sabah bildirimini iptal et
    await _notifications.cancel(1);

    await _notifications.zonedSchedule(
      1, // daily horoscope notification id
      '🌟 Günlük Falın Hazır!',
      '$zodiacName burcu için bugünün falı seni bekliyor. Astro Dozi ne diyor bakalım?',
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_horoscope',
          'Günlük Burç',
          channelDescription: 'Günlük burç yorumları',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          fullScreenIntent: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'daily_horoscope',
    );
  }

  Future<void> cancelDailyHoroscope() async {
    await _notifications.cancel(1);
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
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
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
        1, // daily horoscope notification id
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

  // ===== HOOK BİLDİRİM SİSTEMİ =====

  /// Tüm hook bildirimlerini planla (sabah + öğle + akşam)
  Future<void> scheduleHookNotifications({
    required int morningHour,
    required int morningMinute,
    required String zodiacName,
    bool enableMidday = true,
    bool enableEvening = true,
  }) async {
    // 1. Sabah ana bildirimi — merak uyandırıcı hook ile
    final morningHook = _getRandomHook(zodiacName, period: 'morning');
    await _notifications.zonedSchedule(
      0, // sabah bildirimi ID=0
      morningHook['title']!,
      morningHook['body']!,
      _nextInstanceOfTime(morningHour, morningMinute),
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
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'daily_horoscope',
    );

    // 2. Öğle hatırlatması (13:00)
    if (enableMidday) {
      final middayHook = _getRandomHook(zodiacName, period: 'midday');
      await _notifications.zonedSchedule(
        10, // öğle bildirimi ID=10
        middayHook['title']!,
        middayHook['body']!,
        _nextInstanceOfTime(13, 0),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'midday_reminder',
            'Öğle Hatırlatması',
            channelDescription: 'Öğle saati hatırlatmaları',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
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

    // 3. Akşam bildirimi (21:00) — yarın için merak
    if (enableEvening) {
      final eveningHook = _getRandomHook(zodiacName, period: 'evening');
      await _notifications.zonedSchedule(
        20, // akşam bildirimi ID=20
        eveningHook['title']!,
        eveningHook['body']!,
        _nextInstanceOfTime(21, 0),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'evening_preview',
            'Akşam Önizleme',
            channelDescription: 'Akşam önizleme bildirimleri',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
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
  }

  /// Öğle ve akşam bildirimlerini iptal et
  Future<void> cancelExtraNotifications() async {
    await _notifications.cancel(10); // öğle
    await _notifications.cancel(20); // akşam
  }

  /// Kozmik kutu hatırlatması (günde 1 kez, sabah 10:00)
  Future<void> scheduleCosmicBoxReminder({required String zodiacName}) async {
    await _notifications.zonedSchedule(
      30, // kozmik kutu ID=30
      '🎁 Kozmik Kutun Hazır!',
      '$zodiacName, günlük şans kutunu açmayı unutma! Bugün ne çıkacak? ✨',
      _nextInstanceOfTime(10, 0),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'cosmic_box',
          'Kozmik Kutu',
          channelDescription: 'Günlük kozmik kutu hatırlatması',
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
      payload: 'cosmic_box',
    );
  }

  // ===== MONETİZASYON BİLDİRİMLERİ =====

  /// Coin azaldığında hatırlatma (bakiye < 10)
  Future<void> showLowCoinReminder({required String zodiacName}) async {
    await _notifications.show(
      50,
      '💰 Yıldız Tozların azalıyor!',
      '$zodiacName, bugün reklam izleyerek veya arkadaşını davet ederek Yıldız Tozu kazanabilirsin!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'monetization',
          'Hatırlatmalar',
          channelDescription: 'Yıldız Tozu ve premium hatırlatmaları',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: 'low_coin',
    );
  }

  /// Streak kırılma riski hatırlatması (akşam 20:00)
  Future<void> scheduleStreakReminder({required String zodiacName}) async {
    await _notifications.zonedSchedule(
      55, // streak hatırlatma ID=55
      '🔥 Serini kaybetme!',
      '$zodiacName, bugün falına bakmayı unuttun! Giriş serini koru ve bonus kazan.',
      _nextInstanceOfTime(20, 0),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'streak_reminder',
          'Seri Hatırlatma',
          channelDescription: 'Giriş serisi hatırlatması',
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
      payload: 'streak_reminder',
    );
  }

  /// Premium upsell bildirimi (haftalık, Pazar 11:00)
  Future<void> schedulePremiumUpsell({required String zodiacName}) async {
    // Pazar günü 11:00'da göster
    final now = tz.TZDateTime.now(tz.local);
    var nextSunday = tz.TZDateTime(tz.local, now.year, now.month, now.day, 11, 0);
    while (nextSunday.weekday != DateTime.sunday || nextSunday.isBefore(now)) {
      nextSunday = nextSunday.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      60, // premium upsell ID=60
      '👑 Bu haftanın fırsatı!',
      '$zodiacName, Premium ile sınırsız yorum, reklamsız deneyim ve çok daha fazlası!',
      nextSunday,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'premium_upsell',
          'Premium Teklifler',
          channelDescription: 'Premium üyelik teklifleri',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
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
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      payload: 'premium_upsell',
    );
  }

  /// Geri dönüş (re-engagement) bildirimi — 3 gün giriş yapmayanlar için
  Future<void> scheduleReEngagement({required String zodiacName}) async {
    final triggerDate = tz.TZDateTime.now(tz.local).add(const Duration(days: 3));
    final scheduledDate = tz.TZDateTime(
      tz.local,
      triggerDate.year,
      triggerDate.month,
      triggerDate.day,
      10,
      0,
    );

    await _notifications.zonedSchedule(
      70, // re-engagement ID=70
      '🌟 Seni özledik!',
      '$zodiacName, yıldızlar seni bekliyor! 3 gündür bakmadığın falında önemli mesajlar var...',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          're_engagement',
          'Geri Dönüş',
          channelDescription: 'Geri dönüş hatırlatmaları',
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
      payload: 're_engagement',
    );
  }

  /// Re-engagement bildirimini iptal et (kullanıcı uygulamaya girdiğinde)
  Future<void> cancelReEngagement() async {
    await _notifications.cancel(70);
  }

  /// Retro gezegen uyarısı (tek seferlik bildirim)
  Future<void> showRetroAlert({
    required String planetName,
    required int daysUntil,
  }) async {
    await _notifications.show(
      40 + DateTime.now().millisecondsSinceEpoch % 100,
      '⚠️ $planetName Retrosu Yaklaşıyor!',
      '$daysUntil gün sonra $planetName retrosu başlıyor. Hazırlıklı ol!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'retro_alert',
          'Retro Uyarıları',
          channelDescription: 'Gezegen retrosu uyarıları',
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
      payload: 'retro_alert',
    );
  }

  /// Tek bir bildirimi ID ile iptal et
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  /// Gezegen transit bildirimlerini planla
  Future<void> scheduleTransitNotifications() async {
    // İlk olarak eski transit bildirimlerini iptal et (ID range: 100-199)
    for (int i = 100; i < 200; i++) {
      await _notifications.cancel(i);
    }

    final now = DateTime.now();
    final events = AstroData.getAllEvents();

    // Gelecek 30 gün içindeki olayları filtrele
    final upcomingEvents = events.where((event) {
      final diff = event.date.difference(now).inDays;
      return diff >= 0 && diff <= 30;
    }).toList();

    int notificationId = 100;
    for (final event in upcomingEvents) {
      if (notificationId >= 200) break; // Max 100 transit notifications

      // Olaydan 1 gün önce bildirim gönder
      final notifyDate = event.date.subtract(const Duration(days: 1));
      if (notifyDate.isBefore(now)) continue;

      final scheduledDate = tz.TZDateTime(
        tz.local,
        notifyDate.year,
        notifyDate.month,
        notifyDate.day,
        10, // Sabah 10:00
        0,
      );

      if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) continue;

      await _notifications.zonedSchedule(
        notificationId,
        '${event.emoji} ${event.title} Yarın!',
        event.description,
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'transit_channel',
            'Gezegen Transitleri',
            channelDescription: 'Önemli astrolojik olay bildirimleri',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            color: Color(0xFF7C3AED),
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
        payload: 'transit_event',
      );

      notificationId++;
    }
  }

  /// Restore notifications on app startup if they were previously enabled
  Future<void> restoreNotifications({
    required bool enabled,
    required int hour,
    required int minute,
    required String zodiacName,
  }) async {
    if (!enabled) return;

    try {
      // Check and request permission on Android 13+
      final granted = await requestPermissions();
      if (!granted) return;

      // Schedule the daily horoscope notification
      await scheduleDailyHoroscope(
        hour: hour,
        minute: minute,
        zodiacName: zodiacName,
      );

      // Also schedule hook notifications
      await scheduleHookNotifications(
        morningHour: hour,
        morningMinute: minute,
        zodiacName: zodiacName,
      );

      // Schedule streak reminder
      await scheduleStreakReminder(zodiacName: zodiacName);

      // Schedule cosmic box reminder
      await scheduleCosmicBoxReminder(zodiacName: zodiacName);

      // Schedule re-engagement (will be cancelled when user opens app)
      await scheduleReEngagement(zodiacName: zodiacName);
    } catch (e) {
      // Silently fail — notifications are not critical
      debugPrint('⚠️ Notification restore failed: $e');
    }
  }
}
