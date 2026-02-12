import 'dart:async';
import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  static const String _firstOpenDateKey = 'first_open_date';
  static const String _lastInterstitialShownAtKey = 'last_interstitial_shown_at';
  static const String _interstitialShownTodayKey = 'interstitial_shown_today';

  static const int _newUserDays = 3;
  static const int _newUserMaxInterstitialsPerDay = 2;
  static const int _regularMaxInterstitialsPerDay = 3;
  static const int _newUserScreensBetweenInterstitials = 4;
  static const int _regularScreensBetweenInterstitials = 3;
  static const int _minMinutesBetweenInterstitials = 4;

  int _screenNavigationCount = 0;
  int _interstitialShownToday = 0;
  DateTime? _lastInterstitialShownAt;
  DateTime? _firstOpenDate;

  // Test Ad Unit IDs - Production'da gerçek ID'lerle değiştir
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111'; // Test ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716'; // Test ID
    }
    throw UnsupportedError('Unsupported platform');
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/5224354917'; // Test ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/1712485313'; // Test ID
    }
    throw UnsupportedError('Unsupported platform');
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/1033173712'; // Test ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4411468910'; // Test ID
    }
    throw UnsupportedError('Unsupported platform');
  }

  BannerAd? _bannerAd;
  RewardedAd? _rewardedAd;
  InterstitialAd? _interstitialAd;

  bool _isBannerAdReady = false;
  bool _isRewardedAdReady = false;
  bool _isInterstitialAdReady = false;

  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    await _loadInterstitialTracking();
  }

  Future<void> _loadInterstitialTracking() async {
    final prefs = await SharedPreferences.getInstance();

    final firstOpenStr = prefs.getString(_firstOpenDateKey);
    if (firstOpenStr == null) {
      _firstOpenDate = DateTime.now();
      await prefs.setString(_firstOpenDateKey, _firstOpenDate!.toIso8601String());
    } else {
      _firstOpenDate = DateTime.parse(firstOpenStr);
    }

    final lastShownAtStr = prefs.getString(_lastInterstitialShownAtKey);
    if (lastShownAtStr != null) {
      _lastInterstitialShownAt = DateTime.parse(lastShownAtStr);
    }

    await _resetDailyCounterIfNeeded();
    _interstitialShownToday = prefs.getInt(_interstitialShownTodayKey) ?? 0;
  }

  Future<void> _resetDailyCounterIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();

    if (_lastInterstitialShownAt == null) {
      _interstitialShownToday = prefs.getInt(_interstitialShownTodayKey) ?? 0;
      return;
    }

    final isDifferentDay = _lastInterstitialShownAt!.day != now.day ||
        _lastInterstitialShownAt!.month != now.month ||
        _lastInterstitialShownAt!.year != now.year;

    if (isDifferentDay) {
      _interstitialShownToday = 0;
      await prefs.setInt(_interstitialShownTodayKey, 0);
    }
  }

  int _daysSinceInstall() {
    if (_firstOpenDate == null) {
      return 999;
    }
    return DateTime.now().difference(_firstOpenDate!).inDays;
  }

  bool _isNewUser() => _daysSinceInstall() < _newUserDays;

  int _maxInterstitialsPerDay() {
    return _isNewUser()
        ? _newUserMaxInterstitialsPerDay
        : _regularMaxInterstitialsPerDay;
  }

  int _screensBetweenInterstitials() {
    return _isNewUser()
        ? _newUserScreensBetweenInterstitials
        : _regularScreensBetweenInterstitials;
  }

  void trackScreenNavigation() {
    _screenNavigationCount++;
    print('📱 Screen navigation count: $_screenNavigationCount');
  }

  Future<bool> shouldShowInterstitial() async {
    await _resetDailyCounterIfNeeded();

    final maxPerDay = _maxInterstitialsPerDay();
    final screensThreshold = _screensBetweenInterstitials();

    if (_interstitialShownToday >= maxPerDay) {
      print('❌ Daily interstitial limit reached: $_interstitialShownToday/$maxPerDay');
      return false;
    }

    if (_screenNavigationCount < screensThreshold) {
      print('❌ Not enough screens: $_screenNavigationCount/$screensThreshold');
      return false;
    }

    if (_lastInterstitialShownAt != null) {
      final minutesSinceLast = DateTime.now().difference(_lastInterstitialShownAt!).inMinutes;
      if (minutesSinceLast < _minMinutesBetweenInterstitials) {
        print('❌ Cooldown active: $minutesSinceLast/$_minMinutesBetweenInterstitials minutes');
        return false;
      }
    }

    print('✅ Should show interstitial (newUser=${_isNewUser()}, daily=$_interstitialShownToday/$maxPerDay)');
    return true;
  }

  Future<void> _markInterstitialShown() async {
    _screenNavigationCount = 0;
    _interstitialShownToday++;
    _lastInterstitialShownAt = DateTime.now();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_interstitialShownTodayKey, _interstitialShownToday);
    await prefs.setString(_lastInterstitialShownAtKey, _lastInterstitialShownAt!.toIso8601String());

    print('✅ Interstitial marked as shown. Today: $_interstitialShownToday/${_maxInterstitialsPerDay()}');
  }

  void loadBannerAd() {
    print('📱 AdService: Starting to load banner ad...');
    _bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          print('✅ Banner ad loaded successfully');
          _isBannerAdReady = true;
        },
        onAdFailedToLoad: (ad, error) {
          print('❌ Banner ad failed to load: ${error.message}');
          print('   Error code: ${error.code}');
          print('   Error domain: ${error.domain}');
          _isBannerAdReady = false;
          ad.dispose();
          _bannerAd = null;
        },
        onAdOpened: (ad) {
          print('📱 Banner ad opened');
        },
        onAdClosed: (ad) {
          print('📱 Banner ad closed');
        },
      ),
    );
    _bannerAd?.load();
    print('📱 AdService: Banner ad load() called');
  }

  BannerAd? get bannerAd => _isBannerAdReady ? _bannerAd : null;
  bool get isBannerAdReady => _isBannerAdReady;

  void loadRewardedAd() {
    print('📺 Loading rewarded ad...');
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          print('✅ Rewarded ad loaded successfully');
          _rewardedAd = ad;
          _isRewardedAdReady = true;
        },
        onAdFailedToLoad: (error) {
          print('❌ Rewarded ad failed to load: $error');
          _isRewardedAdReady = false;
        },
      ),
    );
  }

  Future<bool> showRewardedAd() async {
    print('🎬 showRewardedAd called - isReady: $_isRewardedAdReady, ad: ${_rewardedAd != null}');

    if (!_isRewardedAdReady || _rewardedAd == null) {
      print('❌ Rewarded ad not ready - loading new ad');
      loadRewardedAd();
      return false;
    }

    final Completer<bool> completer = Completer<bool>();
    bool rewarded = false;

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        print('✅ Ad showed full screen content');
      },
      onAdDismissedFullScreenContent: (ad) {
        print('✅ Ad dismissed - User was rewarded: $rewarded');
        ad.dispose();
        _isRewardedAdReady = false;
        _rewardedAd = null;
        loadRewardedAd();
        if (!completer.isCompleted) {
          completer.complete(rewarded);
        }
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('❌ Ad failed to show full screen: $error');
        ad.dispose();
        _isRewardedAdReady = false;
        _rewardedAd = null;
        loadRewardedAd();
        if (!completer.isCompleted) {
          completer.complete(false);
        }
      },
    );

    try {
      await _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          print('🎉 USER EARNED REWARD: ${reward.amount} ${reward.type}');
          rewarded = true;
        },
      );
    } catch (e) {
      print('❌ Exception while showing ad: $e');
      if (!completer.isCompleted) {
        completer.complete(false);
      }
    }

    final result = await completer.future;
    print('✅ Ad flow completed with result: $result');
    return result;
  }

  void loadInterstitialAd() {
    print('📱 AdService: Loading interstitial ad...');
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          print('✅ Interstitial ad loaded successfully');
          _interstitialAd = ad;
          _isInterstitialAdReady = true;
        },
        onAdFailedToLoad: (error) {
          print('❌ Interstitial ad failed to load: ${error.message}');
          _isInterstitialAdReady = false;
        },
      ),
    );
  }

  Future<bool> showInterstitialAd() async {
    if (!_isInterstitialAdReady || _interstitialAd == null) {
      print('❌ Interstitial ad not ready');
      loadInterstitialAd();
      return false;
    }

    final completer = Completer<bool>();

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        print('✅ Interstitial ad showed');
      },
      onAdDismissedFullScreenContent: (ad) {
        print('✅ Interstitial ad dismissed');
        ad.dispose();
        _isInterstitialAdReady = false;
        _interstitialAd = null;
        _markInterstitialShown();
        loadInterstitialAd();
        if (!completer.isCompleted) completer.complete(true);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('❌ Interstitial ad failed to show: ${error.message}');
        ad.dispose();
        _isInterstitialAdReady = false;
        _interstitialAd = null;
        loadInterstitialAd();
        if (!completer.isCompleted) completer.complete(false);
      },
    );

    await _interstitialAd!.show();
    return completer.future;
  }

  Future<bool> showInterstitialIfNeeded() async {
    if (!await shouldShowInterstitial()) {
      return false;
    }

    return showInterstitialAd();
  }

  void dispose() {
    _bannerAd?.dispose();
    _rewardedAd?.dispose();
    _interstitialAd?.dispose();
  }
}
