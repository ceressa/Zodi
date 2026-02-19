import 'dart:async';
import 'package:flutter/foundation.dart';
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
import 'screens/splash_screen.dart';
import 'constants/colors.dart';
import 'services/ad_service.dart';
import 'services/firebase_service.dart';
import 'services/notification_service.dart';
import 'services/streak_service.dart';
import 'services/astronomy_service.dart';
import 'utils/navigation_helper.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Global error handler for Flutter framework errors
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    if (kDebugMode) {
      debugPrint('FlutterError: ${details.exception}');
    }
  };

  // Catch async errors not handled by Flutter framework
  runZonedGuarded(() async {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize Firebase Service
    await FirebaseService.initialize();

    // Initialize Swiss Ephemeris (non-critical, app can work without it)
    try {
      await AstronomyService.initialize();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AstronomyService init failed (non-critical): $e');
      }
    }

    try {
      await dotenv.load(fileName: '.env');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('.env load failed: $e');
      }
    }

    await initializeDateFormatting('tr_TR', null);

    // Initialize Ad Service (non-critical)
    try {
      final adService = AdService();
      await adService.initialize();
      adService.loadInterstitialAd();
      adService.loadRewardedAd();
      adService.loadBannerAd();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AdService init failed (non-critical): $e');
      }
    }

    // Initialize Notification Service (non-critical)
    try {
      await NotificationService().initialize(
        onNotificationTap: NavigationHelper.handleNotificationPayload,
      );
      await NotificationService().checkLaunchNotification();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('NotificationService init failed (non-critical): $e');
      }
    }

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    runApp(const ZodiApp());
  }, (error, stackTrace) {
    if (kDebugMode) {
      debugPrint('Uncaught error: $error');
      debugPrint('Stack trace: $stackTrace');
    }
  });
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
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Zodi',
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
            theme: AppTheme.lightTheme,
            themeMode: ThemeMode.light,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
