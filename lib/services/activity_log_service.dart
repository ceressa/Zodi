import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActivityLogService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Aktivite tipleri
  static const String TYPE_DAILY_HOROSCOPE = 'daily_horoscope';
  static const String TYPE_TAROT_READING = 'tarot_reading';
  static const String TYPE_DREAM_INTERPRETATION = 'dream_interpretation';
  static const String TYPE_RISING_SIGN = 'rising_sign';
  static const String TYPE_COMPATIBILITY = 'compatibility';
  static const String TYPE_WEEKLY_HOROSCOPE = 'weekly_horoscope';
  static const String TYPE_MONTHLY_HOROSCOPE = 'monthly_horoscope';
  static const String TYPE_PREMIUM_PURCHASE = 'premium_purchase';
  static const String TYPE_LOGIN = 'login';
  static const String TYPE_SIGNUP = 'signup';
  
  // Aktivite logla
  Future<void> logActivity({
    required String type,
    required String action,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      final userName = prefs.getString('userName') ?? 'Anonim';
      final zodiacSign = prefs.getString('zodiacSign') ?? '';
      
      if (userId == null) return;
      
      await _firestore.collection('activity_logs').add({
        'userId': userId,
        'userName': userName,
        'zodiacSign': zodiacSign,
        'type': type,
        'action': action,
        'metadata': metadata ?? {},
        'timestamp': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      print('✅ Aktivite loglandı: $action');
    } catch (e) {
      print('❌ Aktivite loglama hatası: $e');
    }
  }
  
  // Günlük yorum okundu
  Future<void> logDailyHoroscope(String zodiacSign) async {
    await logActivity(
      type: TYPE_DAILY_HOROSCOPE,
      action: 'Günlük yorumunu okudu',
      metadata: {'zodiacSign': zodiacSign},
    );
  }
  
  // Tarot kartı çekildi
  Future<void> logTarotReading(String cardName, int cardNumber) async {
    await logActivity(
      type: TYPE_TAROT_READING,
      action: 'Tarot kartı çekti',
      metadata: {
        'cardName': cardName,
        'cardNumber': cardNumber,
      },
    );
  }
  
  // Rüya yorumu yapıldı
  Future<void> logDreamInterpretation(String dreamText) async {
    await logActivity(
      type: TYPE_DREAM_INTERPRETATION,
      action: 'Rüya yorumu yaptırdı',
      metadata: {
        'dreamLength': dreamText.length,
      },
    );
  }
  
  // Yükselen burç hesaplandı
  Future<void> logRisingSign(String risingSign) async {
    await logActivity(
      type: TYPE_RISING_SIGN,
      action: 'Yükselen burç hesapladı',
      metadata: {'risingSign': risingSign},
    );
  }
  
  // Uyumluluk analizi yapıldı
  Future<void> logCompatibility(String sign1, String sign2) async {
    await logActivity(
      type: TYPE_COMPATIBILITY,
      action: 'Uyumluluk analizi yaptı',
      metadata: {
        'sign1': sign1,
        'sign2': sign2,
      },
    );
  }
  
  // Haftalık yorum okundu
  Future<void> logWeeklyHoroscope(String zodiacSign) async {
    await logActivity(
      type: TYPE_WEEKLY_HOROSCOPE,
      action: 'Haftalık yorumunu okudu',
      metadata: {'zodiacSign': zodiacSign},
    );
  }
  
  // Aylık yorum okundu
  Future<void> logMonthlyHoroscope(String zodiacSign) async {
    await logActivity(
      type: TYPE_MONTHLY_HOROSCOPE,
      action: 'Aylık yorumunu okudu',
      metadata: {'zodiacSign': zodiacSign},
    );
  }
  
  // Premium satın alındı
  Future<void> logPremiumPurchase(double price) async {
    await logActivity(
      type: TYPE_PREMIUM_PURCHASE,
      action: 'Premium satın aldı',
      metadata: {
        'price': price,
        'currency': 'TRY',
      },
    );
  }
  
  // Login
  Future<void> logLogin() async {
    await logActivity(
      type: TYPE_LOGIN,
      action: 'Giriş yaptı',
    );
  }
  
  // Signup
  Future<void> logSignup() async {
    await logActivity(
      type: TYPE_SIGNUP,
      action: 'Hesap oluşturdu',
    );
  }
}
