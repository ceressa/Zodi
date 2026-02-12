import 'dart:io';
import 'dart:async';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  // Interstitial ad tracking
  int _screenNavigationCount = 0;
  int _interstitialShownToday = 0;
  DateTime? _lastInterstitialDate;
  
  static const int _maxInterstitialsPerDay = 3;
  static const int _screensBetweenInterstitials = 3;

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

  // Interstitial tracking yükle
  Future<void> _loadInterstitialTracking() async {
    final prefs = await SharedPreferences.getInstance();
    final lastDateStr = prefs.getString('last_interstitial_date');
    
    if (lastDateStr != null) {
      _lastInterstitialDate = DateTime.parse(lastDateStr);
      
      // Yeni gün mü kontrol et
      final now = DateTime.now();
      if (_lastInterstitialDate!.day != now.day ||
          _lastInterstitialDate!.month != now.month ||
          _lastInterstitialDate!.year != now.year) {
        // Yeni gün, sayacı sıfırla
        _interstitialShownToday = 0;
        await prefs.setInt('interstitial_shown_today', 0);
      } else {
        _interstitialShownToday = prefs.getInt('interstitial_shown_today') ?? 0;
      }
    }
  }

  // Ekran navigasyonunu kaydet
  void trackScreenNavigation() {
    _screenNavigationCount++;
    print('📱 Screen navigation count: $_screenNavigationCount');
  }

  // Interstitial gösterilmeli mi?
  bool shouldShowInterstitial() {
    // Günlük limit kontrolü
    if (_interstitialShownToday >= _maxInterstitialsPerDay) {
      print('❌ Daily interstitial limit reached: $_interstitialShownToday/$_maxInterstitialsPerDay');
      return false;
    }

    // Ekran sayısı kontrolü
    if (_screenNavigationCount < _screensBetweenInterstitials) {
      print('❌ Not enough screens: $_screenNavigationCount/$_screensBetweenInterstitials');
      return false;
    }

    print('✅ Should show interstitial');
    return true;
  }

  // Interstitial gösterildi olarak işaretle
  Future<void> _markInterstitialShown() async {
    _screenNavigationCount = 0;
    _interstitialShownToday++;
    _lastInterstitialDate = DateTime.now();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('interstitial_shown_today', _interstitialShownToday);
    await prefs.setString('last_interstitial_date', _lastInterstitialDate!.toIso8601String());
    
    print('✅ Interstitial marked as shown. Today: $_interstitialShownToday/$_maxInterstitialsPerDay');
  }

  // Banner Ad
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

  // Rewarded Ad
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
      loadRewardedAd(); // Yeni reklam yükle
      return false;
    }

    final Completer<bool> completer = Completer<bool>();
    bool rewarded = false;
    
    print('📺 Setting up ad callbacks...');
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        print('✅ Ad showed full screen content');
      },
      onAdDismissedFullScreenContent: (ad) {
        print('✅ Ad dismissed - User was rewarded: $rewarded');
        ad.dispose();
        _isRewardedAdReady = false;
        _rewardedAd = null;
        loadRewardedAd(); // Yeni reklam yükle
        if (!completer.isCompleted) {
          print('🔄 Completing future with: $rewarded');
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
          print('🔄 Completing future with: false (error)');
          completer.complete(false);
        }
      },
    );

    try {
      print('📺 Calling show() on rewarded ad...');
      await _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          print('🎉🎉🎉 USER EARNED REWARD: ${reward.amount} ${reward.type}');
          rewarded = true;
        },
      );
      print('📺 show() method completed');
    } catch (e) {
      print('❌ Exception while showing ad: $e');
      if (!completer.isCompleted) {
        print('🔄 Completing future with: false (exception)');
        completer.complete(false);
      }
    }

    print('⏳ Waiting for ad to complete...');
    final result = await completer.future;
    print('✅ Ad flow completed with result: $result');
    return result;
  }

  // Interstitial Ad
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
      loadInterstitialAd(); // Yeni reklam yükle
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
        loadInterstitialAd(); // Yeni reklam yükle
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

  // Akıllı interstitial gösterme
  Future<void> showInterstitialIfNeeded() async {
    if (!shouldShowInterstitial()) {
      return;
    }

    await showInterstitialAd();
  }

  void dispose() {
    _bannerAd?.dispose();
    _rewardedAd?.dispose();
    _interstitialAd?.dispose();
  }
}
