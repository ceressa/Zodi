import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Tüm kullanıcı aktivitelerini Firebase'e loglar.
/// Admin panelde canlı olarak görüntülenir.
class ActivityLogService {
  static final ActivityLogService _instance = ActivityLogService._internal();
  factory ActivityLogService() => _instance;
  ActivityLogService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Aktivite tipleri
  static const String typeLogin = 'login';
  static const String typeSignup = 'signup';
  static const String typeAppOpen = 'app_open';
  static const String typeDailyHoroscope = 'daily_horoscope';
  static const String typeTarotReading = 'tarot_reading';
  static const String typeDreamInterpretation = 'dream_interpretation';
  static const String typeRisingSign = 'rising_sign';
  static const String typeCompatibility = 'compatibility';
  static const String typeWeeklyHoroscope = 'weekly_horoscope';
  static const String typeMonthlyHoroscope = 'monthly_horoscope';
  static const String typeBirthChart = 'birth_chart';
  static const String typePremiumPurchase = 'premium_purchase';
  static const String typeAdWatched = 'ad_watched';

  /// Ana log fonksiyonu — tüm aktiviteler buradan geçer
  Future<void> _log({
    required String type,
    required String action,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Kullanıcı profilinden isim ve burç al
      String userName = user.displayName ?? 'Anonim';
      String zodiacSign = '';

      try {
        final userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists && userDoc.data() != null) {
          userName = userDoc.data()!['name'] ?? userName;
          zodiacSign = userDoc.data()!['zodiacSign'] ?? '';
        }
      } catch (_) {}

      await _firestore.collection('activity_logs').add({
        'userId': user.uid,
        'userName': userName,
        'userEmail': user.email ?? '',
        'zodiacSign': zodiacSign,
        'type': type,
        'action': action,
        'metadata': metadata ?? {},
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Loglama hatası uygulamayı durdurmamalı
      // ignore
    }
  }

  // ==================== AUTH ====================

  /// Kullanıcı giriş yaptı (geri dönen kullanıcı)
  Future<void> logLogin({String method = 'google'}) async {
    await _log(
      type: typeLogin,
      action: 'Giriş yaptı',
      metadata: {'method': method},
    );
  }

  /// Yeni hesap oluşturuldu
  Future<void> logSignup({String method = 'google'}) async {
    await _log(
      type: typeSignup,
      action: 'Hesap oluşturdu',
      metadata: {'method': method},
    );
  }

  /// Uygulama açıldı (mevcut oturumla)
  Future<void> logAppOpen() async {
    await _log(
      type: typeAppOpen,
      action: 'Uygulamayı açtı',
    );
  }

  // ==================== FEATURES ====================

  /// Günlük burç yorumu okundu
  Future<void> logDailyHoroscope(String zodiacSign) async {
    await _log(
      type: typeDailyHoroscope,
      action: 'Günlük yorumunu okudu',
      metadata: {'zodiacSign': zodiacSign},
    );
  }

  /// Tarot kartı çekildi
  Future<void> logTarotReading(String cardName, int cardNumber) async {
    await _log(
      type: typeTarotReading,
      action: 'Tarot kartı çekti',
      metadata: {'cardName': cardName, 'cardNumber': cardNumber},
    );
  }

  /// Rüya yorumlandı
  Future<void> logDreamInterpretation(String dreamText) async {
    await _log(
      type: typeDreamInterpretation,
      action: 'Rüya yorumu yaptırdı',
      metadata: {'dreamLength': dreamText.length},
    );
  }

  /// Yükselen burç hesaplandı
  Future<void> logRisingSign(String risingSign) async {
    await _log(
      type: typeRisingSign,
      action: 'Yükselen burç hesapladı',
      metadata: {'risingSign': risingSign},
    );
  }

  /// Burç uyumluluğu analizi yapıldı
  Future<void> logCompatibility(String sign1, String sign2) async {
    await _log(
      type: typeCompatibility,
      action: 'Uyumluluk analizi yaptı',
      metadata: {'sign1': sign1, 'sign2': sign2},
    );
  }

  /// Haftalık burç yorumu okundu
  Future<void> logWeeklyHoroscope(String zodiacSign) async {
    await _log(
      type: typeWeeklyHoroscope,
      action: 'Haftalık yorumunu okudu',
      metadata: {'zodiacSign': zodiacSign},
    );
  }

  /// Aylık burç yorumu okundu
  Future<void> logMonthlyHoroscope(String zodiacSign) async {
    await _log(
      type: typeMonthlyHoroscope,
      action: 'Aylık yorumunu okudu',
      metadata: {'zodiacSign': zodiacSign},
    );
  }

  /// Doğum haritası hesaplandı
  Future<void> logBirthChart({bool isOwnChart = true}) async {
    await _log(
      type: typeBirthChart,
      action: isOwnChart ? 'Doğum haritası hesapladı' : 'Başkasının haritasını hesapladı',
      metadata: {'isOwnChart': isOwnChart},
    );
  }

  // ==================== MONETIZATION ====================

  /// Premium satın alındı
  Future<void> logPremiumPurchase(double price) async {
    await _log(
      type: typePremiumPurchase,
      action: 'Premium satın aldı',
      metadata: {'price': price, 'currency': 'TRY'},
    );
  }

  /// Reklam izlendi
  Future<void> logAdWatched(String placement) async {
    await _log(
      type: typeAdWatched,
      action: 'Reklam izledi',
      metadata: {'placement': placement},
    );
  }
}
