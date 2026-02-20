import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Arkadaş davet sistemi — her iki tarafa da 25 coin ödül
class ReferralService {
  static final ReferralService _instance = ReferralService._internal();
  factory ReferralService() => _instance;
  ReferralService._internal();

  static const String _keyReferralCode = 'my_referral_code';
  static const String _keyReferralCount = 'referral_count';
  static const String _keyUsedReferralCode = 'used_referral_code';

  static const int referralReward = 25; // Her iki tarafa da 25 coin
  static const int maxReferrals = 10; // Max 10 davet
  static const int codeLength = 6;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Kullanıcının kendi referral kodunu al/oluştur
  Future<String> getOrCreateReferralCode(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_keyReferralCode);
    if (existing != null && existing.isNotEmpty) return existing;

    // Yeni kod oluştur
    final code = _generateCode();

    // Firebase'e kaydet
    await _firestore.collection('referrals').doc(code).set({
      'ownerUserId': userId,
      'createdAt': FieldValue.serverTimestamp(),
      'usedBy': [],
      'usedCount': 0,
    });

    await prefs.setString(_keyReferralCode, code);
    return code;
  }

  /// Referral kodu kullan (davet edilen kişi bu metodu çağırır)
  Future<ReferralResult> useReferralCode(String code, String currentUserId) async {
    final prefs = await SharedPreferences.getInstance();

    // Daha önce kod kullanmış mı?
    final usedCode = prefs.getString(_keyUsedReferralCode);
    if (usedCode != null && usedCode.isNotEmpty) {
      return ReferralResult(success: false, message: 'Daha önce bir davet kodu kullandın.');
    }

    // Kendi kodu mu?
    final myCode = prefs.getString(_keyReferralCode);
    if (myCode == code) {
      return ReferralResult(success: false, message: 'Kendi davet kodunu kullanamazsın.');
    }

    // Firebase'den kodu kontrol et
    final doc = await _firestore.collection('referrals').doc(code).get();
    if (!doc.exists) {
      return ReferralResult(success: false, message: 'Geçersiz davet kodu.');
    }

    final data = doc.data()!;
    final ownerUserId = data['ownerUserId'] as String;
    final usedCount = data['usedCount'] as int? ?? 0;
    final usedBy = List<String>.from(data['usedBy'] ?? []);

    // Kendi kendine davet?
    if (ownerUserId == currentUserId) {
      return ReferralResult(success: false, message: 'Kendi davet kodunu kullanamazsın.');
    }

    // Max limit?
    if (usedCount >= maxReferrals) {
      return ReferralResult(success: false, message: 'Bu davet kodu maksimum kullanıma ulaşmış.');
    }

    // Daha önce aynı kişi kullanmış mı?
    if (usedBy.contains(currentUserId)) {
      return ReferralResult(success: false, message: 'Bu kodu zaten kullandın.');
    }

    // Başarılı — Firebase güncelle
    await _firestore.collection('referrals').doc(code).update({
      'usedBy': FieldValue.arrayUnion([currentUserId]),
      'usedCount': FieldValue.increment(1),
    });

    // Kullanıcının used_referral_code'unu kaydet
    await prefs.setString(_keyUsedReferralCode, code);

    return ReferralResult(
      success: true,
      message: 'Davet kodu başarıyla uygulandı! $referralReward altın kazandın.',
      ownerUserId: ownerUserId,
      reward: referralReward,
    );
  }

  /// Kaç kişi davet edildiğini getir
  Future<int> getReferralCount() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_keyReferralCode);
    if (code == null || code.isEmpty) return 0;

    try {
      final doc = await _firestore.collection('referrals').doc(code).get();
      if (!doc.exists) return 0;
      return doc.data()?['usedCount'] as int? ?? 0;
    } catch (_) {
      return 0;
    }
  }

  /// Daha önce referral kodu kullanılmış mı?
  Future<bool> hasUsedReferralCode() async {
    final prefs = await SharedPreferences.getInstance();
    final usedCode = prefs.getString(_keyUsedReferralCode);
    return usedCode != null && usedCode.isNotEmpty;
  }

  /// Kalan davet hakkı
  Future<int> getRemainingReferrals() async {
    final count = await getReferralCount();
    return (maxReferrals - count).clamp(0, maxReferrals);
  }

  /// Paylaşım metni oluştur
  String getShareText(String code) {
    return 'Astro Dozi\'yi dene! Davet kodum: $code\n'
        'Kodumu kullanarak 25 altın kazan!\n'
        'https://play.google.com/store/apps/details?id=com.bardino.zodi';
  }

  String _generateCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // Karışıklığı azalt: I,O,0,1 yok
    final rng = Random.secure();
    return List.generate(codeLength, (_) => chars[rng.nextInt(chars.length)]).join();
  }
}

/// Referral sonucu
class ReferralResult {
  final bool success;
  final String message;
  final String? ownerUserId;
  final int? reward;

  const ReferralResult({
    required this.success,
    required this.message,
    this.ownerUserId,
    this.reward,
  });
}
