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
            theme: AppTheme.lightTheme, // Yeni tema kullan
            themeMode: ThemeMode.light,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
