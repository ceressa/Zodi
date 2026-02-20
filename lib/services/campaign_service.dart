import 'package:shared_preferences/shared_preferences.dart';

/// FOMO & Kampanya yönetim servisi
/// Zamana bağlı indirimler, premium deneme, başlangıç paketi
class CampaignService {
  static final CampaignService _instance = CampaignService._internal();
  factory CampaignService() => _instance;
  CampaignService._internal();

  static const String _keyFirstOpenDate = 'campaign_first_open';
  static const String _keyStarterPackShown = 'starter_pack_shown';
  static const String _keyStarterPackPurchased = 'starter_pack_purchased';
  static const String _keyTrialUsed = 'premium_trial_used';
  static const String _keyTrialStartDate = 'premium_trial_start';
  static const String _keyLastCampaignDismiss = 'last_campaign_dismiss';
  static const String _keySessionCount = 'campaign_session_count';

  // Başlangıç paketi config
  static const double starterPackPrice = 29.99; // ₺29.99
  static const int starterPackCoins = 100;
  static const int starterPackPremiumDays = 3;
  static const int starterPackOfferHours = 48; // 48 saat geçerli

  // Premium deneme config
  static const int trialDays = 3;

  /// Uygulamanın ilk açılış tarihini kaydet
  Future<void> markFirstOpen() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_keyFirstOpenDate)) {
      await prefs.setString(_keyFirstOpenDate, DateTime.now().toIso8601String());
    }
    // Oturum sayısını artır
    final count = prefs.getInt(_keySessionCount) ?? 0;
    await prefs.setInt(_keySessionCount, count + 1);
  }

  /// Oturum sayısını getir
  Future<int> getSessionCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keySessionCount) ?? 0;
  }

  // ─── Başlangıç Paketi ─────────────────────────────────

  /// Başlangıç paketi teklifi gösterilmeli mi?
  /// İlk 48 saat içinde + henüz alınmadıysa + en az 2 oturum
  Future<bool> shouldShowStarterPack() async {
    final prefs = await SharedPreferences.getInstance();

    // Zaten satın alınmış mı?
    if (prefs.getBool(_keyStarterPackPurchased) ?? false) return false;

    // İlk açılış tarihini kontrol et
    final firstOpenStr = prefs.getString(_keyFirstOpenDate);
    if (firstOpenStr == null) return false;

    final firstOpen = DateTime.parse(firstOpenStr);
    final now = DateTime.now();
    final hoursSinceFirstOpen = now.difference(firstOpen).inHours;

    // 48 saat süresi dolmuş mu?
    if (hoursSinceFirstOpen > starterPackOfferHours) return false;

    // En az 2. oturumda mı?
    final sessionCount = prefs.getInt(_keySessionCount) ?? 0;
    if (sessionCount < 2) return false;

    // Son dismiss'ten beri en az 1 saat geçmiş mi?
    final lastDismiss = prefs.getString(_keyLastCampaignDismiss);
    if (lastDismiss != null) {
      final dismissDate = DateTime.parse(lastDismiss);
      if (now.difference(dismissDate).inHours < 1) return false;
    }

    return true;
  }

  /// Başlangıç paketi kalan süre (saat)
  Future<int> getStarterPackRemainingHours() async {
    final prefs = await SharedPreferences.getInstance();
    final firstOpenStr = prefs.getString(_keyFirstOpenDate);
    if (firstOpenStr == null) return 0;

    final firstOpen = DateTime.parse(firstOpenStr);
    final deadline = firstOpen.add(const Duration(hours: starterPackOfferHours));
    final remaining = deadline.difference(DateTime.now()).inHours;
    return remaining.clamp(0, starterPackOfferHours);
  }

  /// Başlangıç paketi satın alındı olarak işaretle
  Future<void> markStarterPackPurchased() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyStarterPackPurchased, true);
  }

  /// Kampanya dismiss'i kaydet
  Future<void> dismissCampaign() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastCampaignDismiss, DateTime.now().toIso8601String());
  }

  // ─── Premium Deneme ─────────────────────────────────

  /// Premium deneme kullanılmış mı?
  Future<bool> hasUsedTrial() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyTrialUsed) ?? false;
  }

  /// Premium deneme başlat
  Future<void> startPremiumTrial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyTrialUsed, true);
    await prefs.setString(_keyTrialStartDate, DateTime.now().toIso8601String());
  }

  /// Premium deneme aktif mi? (3 gün)
  Future<bool> isTrialActive() async {
    final prefs = await SharedPreferences.getInstance();
    final trialStartStr = prefs.getString(_keyTrialStartDate);
    if (trialStartStr == null) return false;

    final trialStart = DateTime.parse(trialStartStr);
    final trialEnd = trialStart.add(const Duration(days: trialDays));
    return DateTime.now().isBefore(trialEnd);
  }

  /// Deneme kalan gün
  Future<int> getTrialRemainingDays() async {
    final prefs = await SharedPreferences.getInstance();
    final trialStartStr = prefs.getString(_keyTrialStartDate);
    if (trialStartStr == null) return 0;

    final trialStart = DateTime.parse(trialStartStr);
    final trialEnd = trialStart.add(const Duration(days: trialDays));
    final remaining = trialEnd.difference(DateTime.now()).inDays;
    return remaining.clamp(0, trialDays);
  }

  // ─── FOMO Tetikleyicileri ─────────────────────────────────

  /// Coin'leri azaldığında uyarı gösterilmeli mi? (bakiye < 10)
  bool shouldShowLowCoinWarning(int balance) {
    return balance < 10 && balance > 0;
  }

  /// Premium upsell gösterilmeli mi? (3. oturumdan sonra, haftada max 1)
  Future<bool> shouldShowPremiumUpsell() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionCount = prefs.getInt(_keySessionCount) ?? 0;
    if (sessionCount < 3) return false;

    // Zaten deneme kullanmış ve premium ise gösterme
    if (await isTrialActive()) return false;

    return true;
  }
}
