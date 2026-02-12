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
  static const String _rewardedShownTodayKey = 'rewarded_shown_today';
  static const String _lastRewardedShownAtKey = 'last_rewarded_shown_at';

  static int get _newUserDays => int.fromEnvironment('ADS_NEW_USER_DAYS', defaultValue: 3);
  static int get _newUserMaxInterstitialsPerDay =>
      int.fromEnvironment('ADS_NEW_USER_MAX_INTERSTITIALS_PER_DAY', defaultValue: 2);
  static int get _regularMaxInterstitialsPerDay =>
      int.fromEnvironment('ADS_REGULAR_MAX_INTERSTITIALS_PER_DAY', defaultValue: 3);
  static int get _warmingDays =>
      int.fromEnvironment('ADS_WARMING_DAYS', defaultValue: 14);
  static int get _warmingMaxInterstitialsPerDay =>
      int.fromEnvironment('ADS_WARMING_MAX_INTERSTITIALS_PER_DAY', defaultValue: 3);
  static int get _newUserScreensBetweenInterstitials =>
      int.fromEnvironment('ADS_NEW_USER_SCREENS_BETWEEN_INTERSTITIALS', defaultValue: 4);
  static int get _regularScreensBetweenInterstitials =>
      int.fromEnvironment('ADS_REGULAR_SCREENS_BETWEEN_INTERSTITIALS', defaultValue: 3);
  static int get _warmingScreensBetweenInterstitials =>
      int.fromEnvironment('ADS_WARMING_SCREENS_BETWEEN_INTERSTITIALS', defaultValue: 3);
  static int get _minMinutesBetweenInterstitials =>
      int.fromEnvironment('ADS_MIN_MINUTES_BETWEEN_INTERSTITIALS', defaultValue: 4);
  static int get _minMinutesAfterSessionStartForInterstitial =>
      int.fromEnvironment('ADS_MIN_MINUTES_AFTER_SESSION_START_FOR_INTERSTITIAL', defaultValue: 2);

  static int get _maxRewardedPerDay =>
      int.fromEnvironment('ADS_MAX_REWARDED_PER_DAY', defaultValue: 5);
  static int get _minMinutesBetweenRewarded =>
      int.fromEnvironment('ADS_MIN_MINUTES_BETWEEN_REWARDED', defaultValue: 2);

  int _screenNavigationCount = 0;
  int _interstitialShownToday = 0;
  DateTime? _lastInterstitialShownAt;
  DateTime? _firstOpenDate;

  int _rewardedShownToday = 0;
  DateTime? _lastRewardedShownAt;
  DateTime _sessionStartedAt = DateTime.now();

  String _lastInterstitialDecision = 'not_checked';
  String _lastRewardedDecision = 'not_checked';

  String get lastInterstitialDecision => _lastInterstitialDecision;
  String get lastRewardedDecision => _lastRewardedDecision;

  String get audienceSegment {
    final days = _daysSinceInstall();
    if (days < _newUserDays) return 'new_user';
    if (days < _warmingDays) return 'warming';
    return 'regular';
  }

  static String _resolveAdUnit({
    required String androidTest,
    required String iosTest,
    required String androidEnv,
    required String iosEnv,
  }) {
    if (Platform.isAndroid) {
      if (androidEnv == 'ADMOB_BANNER_ANDROID') {
        const configuredBanner = String.fromEnvironment('ADMOB_BANNER_ANDROID', defaultValue: '');
        if (configuredBanner.isNotEmpty) return configuredBanner;
      }
      if (androidEnv == 'ADMOB_REWARDED_ANDROID') {
        const configuredRewarded = String.fromEnvironment('ADMOB_REWARDED_ANDROID', defaultValue: '');
        if (configuredRewarded.isNotEmpty) return configuredRewarded;
      }
      if (androidEnv == 'ADMOB_INTERSTITIAL_ANDROID') {
        const configuredInterstitial =
            String.fromEnvironment('ADMOB_INTERSTITIAL_ANDROID', defaultValue: '');
        if (configuredInterstitial.isNotEmpty) return configuredInterstitial;
      }
      return androidTest;
    }

    if (Platform.isIOS) {
      if (iosEnv == 'ADMOB_BANNER_IOS') {
        const configuredBanner = String.fromEnvironment('ADMOB_BANNER_IOS', defaultValue: '');
        if (configuredBanner.isNotEmpty) return configuredBanner;
      }
      if (iosEnv == 'ADMOB_REWARDED_IOS') {
        const configuredRewarded = String.fromEnvironment('ADMOB_REWARDED_IOS', defaultValue: '');
        if (configuredRewarded.isNotEmpty) return configuredRewarded;
      }
      if (iosEnv == 'ADMOB_INTERSTITIAL_IOS') {
        const configuredInterstitial =
            String.fromEnvironment('ADMOB_INTERSTITIAL_IOS', defaultValue: '');
        if (configuredInterstitial.isNotEmpty) return configuredInterstitial;
      }
      return iosTest;
    }

    throw UnsupportedError('Unsupported platform');
  }

  // Test Ad Unit IDs - Production'da gerçek ID'lerle değiştir
  static String get bannerAdUnitId => _resolveAdUnit(
        androidTest: 'ca-app-pub-3940256099942544/6300978111',
        iosTest: 'ca-app-pub-3940256099942544/2934735716',
        androidEnv: 'ADMOB_BANNER_ANDROID',
        iosEnv: 'ADMOB_BANNER_IOS',
      );

  static String get rewardedAdUnitId => _resolveAdUnit(
        androidTest: 'ca-app-pub-3940256099942544/5224354917',
        iosTest: 'ca-app-pub-3940256099942544/1712485313',
        androidEnv: 'ADMOB_REWARDED_ANDROID',
        iosEnv: 'ADMOB_REWARDED_IOS',
      );

  static String get interstitialAdUnitId => _resolveAdUnit(
        androidTest: 'ca-app-pub-3940256099942544/1033173712',
        iosTest: 'ca-app-pub-3940256099942544/4411468910',
        androidEnv: 'ADMOB_INTERSTITIAL_ANDROID',
        iosEnv: 'ADMOB_INTERSTITIAL_IOS',
      );

  BannerAd? _bannerAd;
  RewardedAd? _rewardedAd;
  InterstitialAd? _interstitialAd;

  bool _isBannerAdReady = false;
  bool _isRewardedAdReady = false;
  bool _isInterstitialAdReady = false;

  Future<void> initialize() async {
    _sessionStartedAt = DateTime.now();
    await MobileAds.instance.initialize();
    await _loadInterstitialTracking();
    await _loadRewardedTracking();
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

  Future<void> _loadRewardedTracking() async {
    final prefs = await SharedPreferences.getInstance();

    final lastRewardedStr = prefs.getString(_lastRewardedShownAtKey);
    if (lastRewardedStr != null) {
      _lastRewardedShownAt = DateTime.parse(lastRewardedStr);
    }

    await _resetRewardedCounterIfNeeded();
    _rewardedShownToday = prefs.getInt(_rewardedShownTodayKey) ?? 0;
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

  Future<void> _resetRewardedCounterIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();

    if (_lastRewardedShownAt == null) {
      _rewardedShownToday = prefs.getInt(_rewardedShownTodayKey) ?? 0;
      return;
    }

    final isDifferentDay = _lastRewardedShownAt!.day != now.day ||
        _lastRewardedShownAt!.month != now.month ||
        _lastRewardedShownAt!.year != now.year;

    if (isDifferentDay) {
      _rewardedShownToday = 0;
      await prefs.setInt(_rewardedShownTodayKey, 0);
    }
  }

  int _daysSinceInstall() {
    if (_firstOpenDate == null) return 999;
    return DateTime.now().difference(_firstOpenDate!).inDays;
  }


  int _maxInterstitialsPerDay() {
    final days = _daysSinceInstall();
    if (days < _newUserDays) return _newUserMaxInterstitialsPerDay;
    if (days < _warmingDays) return _warmingMaxInterstitialsPerDay;
    return _regularMaxInterstitialsPerDay;
  }

  int _screensBetweenInterstitials() {
    final days = _daysSinceInstall();
    if (days < _newUserDays) return _newUserScreensBetweenInterstitials;
    if (days < _warmingDays) return _warmingScreensBetweenInterstitials;
    return _regularScreensBetweenInterstitials;
  }

  Future<bool> _canShowRewarded() async {
    await _resetRewardedCounterIfNeeded();

    if (_rewardedShownToday >= _maxRewardedPerDay) {
      _lastRewardedDecision = 'blocked_daily_limit';
      return false;
    }

    if (_lastRewardedShownAt != null) {
      final mins = DateTime.now().difference(_lastRewardedShownAt!).inMinutes;
      if (mins < _minMinutesBetweenRewarded) {
        _lastRewardedDecision = 'blocked_cooldown';
        return false;
      }
    }

    _lastRewardedDecision = 'eligible';
    return true;
  }

  Future<void> _markRewardedShown() async {
    _rewardedShownToday++;
    _lastRewardedShownAt = DateTime.now();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_rewardedShownTodayKey, _rewardedShownToday);
    await prefs.setString(_lastRewardedShownAtKey, _lastRewardedShownAt!.toIso8601String());
  }

  void trackScreenNavigation() {
    _screenNavigationCount++;
  }

  Future<bool> shouldShowInterstitial() async {
    await _resetDailyCounterIfNeeded();

    final maxPerDay = _maxInterstitialsPerDay();
    final screensThreshold = _screensBetweenInterstitials();

    if (_interstitialShownToday >= maxPerDay) {
      _lastInterstitialDecision = 'blocked_daily_limit';
      return false;
    }

    if (_screenNavigationCount < screensThreshold) {
      _lastInterstitialDecision = 'blocked_navigation_threshold';
      return false;
    }

    final sessionMinutes = DateTime.now().difference(_sessionStartedAt).inMinutes;
    if (sessionMinutes < _minMinutesAfterSessionStartForInterstitial) {
      _lastInterstitialDecision = 'blocked_session_warmup';
      return false;
    }

    if (_lastInterstitialShownAt != null) {
      final minutesSinceLast = DateTime.now().difference(_lastInterstitialShownAt!).inMinutes;
      if (minutesSinceLast < _minMinutesBetweenInterstitials) {
        _lastInterstitialDecision = 'blocked_cooldown';
        return false;
      }
    }

    _lastInterstitialDecision = 'eligible';
    return true;
  }

  Future<void> _markInterstitialShown() async {
    _screenNavigationCount = 0;
    _interstitialShownToday++;
    _lastInterstitialShownAt = DateTime.now();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_interstitialShownTodayKey, _interstitialShownToday);
    await prefs.setString(_lastInterstitialShownAtKey, _lastInterstitialShownAt!.toIso8601String());
  }

  void loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _isBannerAdReady = true;
        },
        onAdFailedToLoad: (ad, error) {
          _isBannerAdReady = false;
          ad.dispose();
          _bannerAd = null;
        },
      ),
    );
    _bannerAd?.load();
  }

  BannerAd? get bannerAd => _isBannerAdReady ? _bannerAd : null;
  bool get isBannerAdReady => _isBannerAdReady;

  void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdReady = true;
        },
        onAdFailedToLoad: (error) {
          _isRewardedAdReady = false;
        },
      ),
    );
  }

  Future<bool> showRewardedAd({String placement = 'generic'}) async {
    if (!await _canShowRewarded()) {
      return false;
    }

    if (!_isRewardedAdReady || _rewardedAd == null) {
      _lastRewardedDecision = 'not_ready';
      loadRewardedAd();
      return false;
    }

    final completer = Completer<bool>();
    var rewarded = false;

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _markRewardedShown();
        _lastRewardedDecision = 'shown';
      },
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _isRewardedAdReady = false;
        _rewardedAd = null;
        loadRewardedAd();
        _lastRewardedDecision = rewarded ? 'completed' : 'dismissed_without_reward';
        if (!completer.isCompleted) completer.complete(rewarded);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _isRewardedAdReady = false;
        _rewardedAd = null;
        loadRewardedAd();
        _lastRewardedDecision = 'failed_to_show';
        if (!completer.isCompleted) completer.complete(false);
      },
    );

    try {
      await _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          rewarded = true;
        },
      );
    } catch (_) {
      _lastRewardedDecision = 'exception';
      if (!completer.isCompleted) completer.complete(false);
    }

    return completer.future;
  }

  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;
        },
        onAdFailedToLoad: (error) {
          _isInterstitialAdReady = false;
        },
      ),
    );
  }

  Future<bool> showInterstitialAd() async {
    if (!_isInterstitialAdReady || _interstitialAd == null) {
      _lastInterstitialDecision = 'not_ready';
      loadInterstitialAd();
      return false;
    }

    final completer = Completer<bool>();

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _isInterstitialAdReady = false;
        _interstitialAd = null;
        _lastInterstitialDecision = 'shown';
        _markInterstitialShown();
        loadInterstitialAd();
        if (!completer.isCompleted) completer.complete(true);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _isInterstitialAdReady = false;
        _interstitialAd = null;
        loadInterstitialAd();
        _lastInterstitialDecision = 'failed_to_show';
        if (!completer.isCompleted) completer.complete(false);
      },
    );

    await _interstitialAd!.show();
    return completer.future;
  }

  Future<bool> showInterstitialIfNeeded() async {
    if (!await shouldShowInterstitial()) return false;
    return showInterstitialAd();
  }

  void dispose() {
    _bannerAd?.dispose();
    _rewardedAd?.dispose();
    _interstitialAd?.dispose();
  }
}
