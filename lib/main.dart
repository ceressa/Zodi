import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/horoscope_provider.dart';
import 'providers/coin_provider.dart';
import 'screens/splash_screen.dart';
import 'constants/colors.dart';
import 'services/ad_service.dart';
import 'services/firebase_service.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';
import 'services/streak_service.dart';
import 'services/astronomy_service.dart';
import 'services/revenue_cat_service.dart';
import 'utils/navigation_helper.dart';
import 'theme/app_theme.dart'; // Yeni tema

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Global error handlers — catch everything so app never crashes silently
  FlutterError.onError = (FlutterErrorDetails details) {
    debugPrint('🔴 FlutterError: ${details.exceptionAsString()}');
    debugPrint('🔴 Stack: ${details.stack}');
    FlutterError.presentError(details);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('🔴 PlatformError: $error');
    debugPrint('🔴 Stack: $stack');
    return true; // Handled — don't crash
  };

  // Initialize Firebase (critical — must not fail)
  debugPrint('🚀 [1/8] Firebase.initializeApp...');
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ [1/8] Firebase initialized');
  } catch (e, s) {
    debugPrint('❌ [1/8] Firebase FAILED: $e\n$s');
  }

  // Initialize Firebase Service
  debugPrint('🚀 [2/8] FirebaseService.initialize...');
  try {
    await FirebaseService.initialize();
    debugPrint('✅ [2/8] FirebaseService initialized');
  } catch (e, s) {
    debugPrint('❌ [2/8] FirebaseService FAILED: $e\n$s');
  }

  // Load .env file (critical — contains GEMINI_API_KEY)
  debugPrint('🚀 [3/8] Loading .env...');
  try {
    await dotenv.load(fileName: '.env');
    debugPrint('✅ [3/8] .env loaded');
  } catch (e) {
    debugPrint('⚠️ [3/8] .env load failed: $e');
  }

  debugPrint('🚀 [4/8] Date formatting...');
  try {
    await initializeDateFormatting('tr_TR', null);
    debugPrint('✅ [4/8] Date formatting done');
  } catch (e) {
    debugPrint('⚠️ [4/8] Date formatting failed: $e');
  }

  // Initialize Swiss Ephemeris (non-critical for app launch)
  debugPrint('🚀 [5/8] AstronomyService...');
  try {
    await AstronomyService.initialize();
    debugPrint('✅ [5/8] AstronomyService initialized');
  } catch (e) {
    debugPrint('⚠️ [5/8] AstronomyService init failed: $e');
  }

  // Initialize RevenueCat (non-critical for app launch)
  debugPrint('🚀 [6/8] RevenueCat...');
  try {
    await RevenueCatService().initialize();
    debugPrint('✅ [6/8] RevenueCat initialized');
  } catch (e) {
    debugPrint('⚠️ [6/8] RevenueCat init failed: $e');
  }

  // Initialize Ad Service (non-critical for app launch)
  debugPrint('🚀 [7/8] AdService...');
  try {
    final adService = AdService();
    await adService.initialize();
    adService.loadInterstitialAd();
    adService.loadRewardedAd();
    adService.loadBannerAd();
    debugPrint('✅ [7/8] AdService initialized');
  } catch (e) {
    debugPrint('⚠️ [7/8] AdService init failed: $e');
  }

  // Initialize Notification Service
  debugPrint('🚀 [8/8] NotificationService...');
  try {
    await NotificationService().initialize(
      onNotificationTap: NavigationHelper.handleNotificationPayload,
    );
    await NotificationService().checkLaunchNotification();
    debugPrint('✅ [8/8] NotificationService initialized');
  } catch (e) {
    debugPrint('⚠️ [8/8] NotificationService init failed: $e');
  }

  // Restore notifications if previously enabled
  try {
    final storageService = StorageService();
    final notificationsEnabled = await storageService.getNotificationsEnabled();
    if (notificationsEnabled) {
      final timeString = await storageService.getNotificationTime();
      int hour = 9;
      int minute = 0;
      if (timeString != null) {
        final parts = timeString.split(':');
        if (parts.length == 2) {
          hour = int.tryParse(parts[0]) ?? 9;
          minute = int.tryParse(parts[1]) ?? 0;
        }
      }
      final zodiac = await storageService.getSelectedZodiac();
      await NotificationService().restoreNotifications(
        enabled: true,
        hour: hour,
        minute: minute,
        zodiacName: zodiac?.displayName ?? 'Koç',
      );
    }
  } catch (e) {
    debugPrint('⚠️ Notification restore failed: $e');
  }

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  debugPrint('🚀 All services initialized — launching app...');
  runApp(const ZodiApp());
}

class ZodiApp extends StatelessWidget {
  const ZodiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => HoroscopeProvider()),
        ChangeNotifierProvider(create: (_) => CoinProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Astro Dozi',
            debugShowCheckedModeBanner: false,
            navigatorKey: navigatorKey,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('tr', 'TR'),
            ],
            locale: const Locale('tr', 'TR'),
            theme: AppTheme.lightTheme, // Yeni tema kullan
            themeMode: ThemeMode.light,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
