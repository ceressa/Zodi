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
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize Firebase Service
  await FirebaseService.initialize();
  
  // Initialize Swiss Ephemeris for astronomical calculations
  await AstronomyService.initialize();
  
  await dotenv.load(fileName: '.env');
  await initializeDateFormatting('tr_TR', null);
  
  // Initialize RevenueCat
  await RevenueCatService().initialize();

  // Initialize Ad Service
  final adService = AdService();
  await adService.initialize();
  
  // Preload ads for better UX
  adService.loadInterstitialAd();
  adService.loadRewardedAd();
  adService.loadBannerAd();
  
  // Initialize Notification Service with navigation callback
  await NotificationService().initialize(
    onNotificationTap: NavigationHelper.handleNotificationPayload,
  );
  
  // Check if app was launched from a notification (cold start)
  await NotificationService().checkLaunchNotification();

  // Restore notifications if previously enabled
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

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
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
