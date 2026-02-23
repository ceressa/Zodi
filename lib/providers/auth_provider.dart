import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../services/storage_service.dart';
import '../services/firebase_service.dart';
import '../services/fun_feature_service.dart';
import '../services/notification_service.dart';
import '../services/revenue_cat_service.dart';
import '../models/zodiac_sign.dart';
import '../models/user_profile.dart';
import '../config/membership_config.dart';

class AuthProvider with ChangeNotifier {
  final StorageService _storage = StorageService();
  final FirebaseService _firebaseService = FirebaseService();
  final RevenueCatService _revenueCatService = RevenueCatService();

  String? _userName;
  String? _userEmail;
  ZodiacSign? _selectedZodiac;
  MembershipTier _membershipTier = MembershipTier.standard;
  bool _isLoading = true;
  UserProfile? _userProfile;

  String? get userName => _userName;
  String? get userEmail => _userEmail;
  ZodiacSign? get selectedZodiac => _selectedZodiac;

  /// Geriye uyumlu: standard değilse premium sayılır
  bool get isPremium => _membershipTier != MembershipTier.standard;
  MembershipTier get membershipTier => _membershipTier;
  MembershipTierConfig get currentTierConfig => MembershipTierConfig.getConfig(_membershipTier);

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _userName != null && _userEmail != null;
  bool get hasSelectedZodiac => _selectedZodiac != null;
  UserProfile? get userProfile => _userProfile;
  String? get userId => _firebaseService.currentUser?.uid;
  String get userGender => _userProfile?.gender ?? 'belirtilmemiş';

  AuthProvider() {
    _loadUserData();
    _setupRevenueCatListener();
  }

  /// RevenueCat müşteri bilgisi değişikliklerini dinle
  void _setupRevenueCatListener() {
    if (_revenueCatService.isInitialized) {
      _revenueCatService.addCustomerInfoListener(_onCustomerInfoUpdated);
    }
  }

  /// RevenueCat'ten gelen müşteri bilgisi güncellemesi
  void _onCustomerInfoUpdated(CustomerInfo customerInfo) {
    final entitlement = customerInfo.entitlements.all[RevenueCatService.entitlementId];
    final wasActive = isPremium;

    if (entitlement != null && entitlement.isActive) {
      final newTier = _revenueCatService.productToTier(entitlement.productIdentifier);
      if (_membershipTier != newTier) {
        _membershipTier = newTier;
        _syncTierToFirebase();
        notifyListeners();
      }
    } else if (wasActive) {
      // Abonelik sona erdi
      _membershipTier = MembershipTier.standard;
      _syncTierToFirebase();
      notifyListeners();
    }
  }

  /// Tier'ı Firebase'e senkronize et
  Future<void> _syncTierToFirebase() async {
    if (_firebaseService.isAuthenticated) {
      try {
        await _firebaseService.firestore
            .collection('users')
            .doc(_firebaseService.currentUser!.uid)
            .update({
          'membershipTier': _membershipTier.name,
          'isPremium': _membershipTier != MembershipTier.standard,
        });
      } catch (e) {
        debugPrint('⚠️ Tier sync error: $e');
      }
    }
  }

  Future<void> _loadUserData() async {
    _isLoading = true;
    notifyListeners();

    _userName = await _storage.getUserName();
    _userEmail = await _storage.getUserEmail();
    _selectedZodiac = await _storage.getSelectedZodiac();
    final oldIsPremium = await _storage.getIsPremium();

    // Firebase'den profil yükle
    if (_firebaseService.isAuthenticated) {
      _userProfile = await _firebaseService.getUserProfile();

      // Firebase'den gelen profil ile local storage'ı senkronize et
      if (_userProfile != null) {
        await _syncProfileToLocal(_userProfile!);
      }

      // RevenueCat kullanıcısını eşleştir
      if (_revenueCatService.isInitialized) {
        await _revenueCatService.loginUser(_firebaseService.currentUser!.uid);
      }

      // RevenueCat'ten gerçek abonelik durumunu kontrol et
      if (_revenueCatService.isInitialized) {
        final rcTier = await _revenueCatService.getActiveTier();
        if (rcTier != MembershipTier.standard) {
          _membershipTier = rcTier;
        } else if (_userProfile != null) {
          // RevenueCat'te aktif abonelik yoksa Firebase'e bak (legacy uyumluluk)
          _loadTierFromFirebase(oldIsPremium);
        }
      } else if (_userProfile != null) {
        // RevenueCat başlatılamamışsa Firebase'den yükle (fallback)
        _loadTierFromFirebase(oldIsPremium);
      }

      // Tier local storage'a kaydet
      await _storage.saveIsPremium(_membershipTier != MembershipTier.standard);
      await _storage.saveMembershipTier(_membershipTier.name);

      // Zodiac sign senkronizasyonu
      if (_userProfile != null && _userProfile!.zodiacSign.isNotEmpty) {
        try {
          _selectedZodiac = ZodiacSign.values.firstWhere(
            (z) => z.name == _userProfile!.zodiacSign,
          );
          await _storage.saveSelectedZodiac(_selectedZodiac!);
        } catch (e) {
          // Zodiac sign bulunamazsa local storage'dakini kullan
        }
      }
    } else if (oldIsPremium) {
      // Local'den tier'ı oku (sadece boolean yerine gerçek tier)
      final savedTier = await _storage.getMembershipTier();
      if (savedTier != null) {
        _membershipTier = MembershipTierConfig.parseTier(savedTier);
      } else {
        _membershipTier = MembershipTier.platinyum;
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Firebase profilini local storage ile senkronize et
  Future<void> _syncProfileToLocal(UserProfile profile) async {
    // Temel bilgileri local'e kaydet
    if (profile.name.isNotEmpty) {
      _userName = profile.name;
      await _storage.saveUserName(profile.name);
    }
    if (profile.email.isNotEmpty) {
      _userEmail = profile.email;
      await _storage.saveUserEmail(profile.email);
    }

    // Bildirim ayarlarını Firebase'den local'e senkronize et
    if (profile.notificationsEnabled) {
      await _storage.setNotificationsEnabled(true);
      if (profile.notificationTime.isNotEmpty) {
        await _storage.setNotificationTime(profile.notificationTime);
      }
    }
  }

  /// Firebase'den tier yükle (RevenueCat yoksa veya aktif abonelik yoksa)
  void _loadTierFromFirebase(bool oldIsPremium) {
    final tierStr = _userProfile!.membershipTier;
    if (tierStr != 'standard' && tierStr.isNotEmpty) {
      _membershipTier = MembershipTierConfig.parseTier(tierStr);
    } else if (_userProfile!.isPremium || oldIsPremium) {
      _membershipTier = MembershipTier.platinyum;
    } else {
      _membershipTier = MembershipTier.standard;
    }
  }

  Future<void> login(String name, String email) async {
    await _storage.saveUserName(name);
    await _storage.saveUserEmail(email);
    _userName = name;
    _userEmail = email;

    // Firebase profil yönetimi
    if (_firebaseService.isAuthenticated) {
      // Önce mevcut profil var mı kontrol et
      final existingProfile = await _firebaseService.getUserProfile();

      if (existingProfile != null) {
        // Profil zaten var — sadece temel bilgileri güncelle, doğum bilgilerini koruma
        await _firebaseService.firestore
            .collection('users')
            .doc(_firebaseService.currentUser!.uid)
            .set({
          'name': name,
          'email': email,
          'lastActiveAt': DateTime.now().toIso8601String(),
          'zodiacSign': _selectedZodiac?.name ?? existingProfile.zodiacSign,
          'isPremium': isPremium,
        }, SetOptions(merge: true));

        _userProfile = await _firebaseService.getUserProfile();
      } else {
        // Yeni kullanıcı — ilk profil oluştur
        final profile = UserProfile(
          userId: _firebaseService.currentUser!.uid,
          name: name,
          email: email,
          createdAt: DateTime.now(),
          lastActiveAt: DateTime.now(),
          birthDate: DateTime(1900, 1, 1),
          birthTime: '',
          birthPlace: '',
          zodiacSign: _selectedZodiac?.name ?? '',
          isPremium: isPremium,
        );

        await _firebaseService.saveUserProfile(profile);
        _userProfile = profile;
      }
    }

    notifyListeners();
  }

  Future<void> selectZodiac(ZodiacSign sign) async {
    await _storage.saveSelectedZodiac(sign);
    _selectedZodiac = sign;
    
    // Firebase'e burç bilgisini kaydet
    if (_firebaseService.isAuthenticated) {
      await _firebaseService.firestore
          .collection('users')
          .doc(_firebaseService.currentUser!.uid)
          .update({
        'zodiacSign': sign.name,
        'lastActiveAt': DateTime.now().toIso8601String(),
      });
    }
    
    notifyListeners();
  }

  Future<void> clearZodiac() async {
    await _storage.clearSelectedZodiac();
    _selectedZodiac = null;
    notifyListeners();
  }

  /// Premium'a yükselt — RevenueCat satın alma sonrası veya manuel
  Future<void> upgradeToPremium({
    MembershipTier tier = MembershipTier.platinyum,
    String subscriptionType = 'monthly',
  }) async {
    _membershipTier = tier;
    await _storage.saveIsPremium(tier != MembershipTier.standard);

    // Firebase'e premium durumunu kaydet
    if (_firebaseService.isAuthenticated) {
      await _firebaseService.updatePremiumStatus(tier != MembershipTier.standard);

      await _firebaseService.firestore
          .collection('users')
          .doc(_firebaseService.currentUser!.uid)
          .update({
        'membershipTier': tier.name,
        'isPremium': tier != MembershipTier.standard,
        'premiumStartDate': DateTime.now().toIso8601String(),
        'subscriptionType': subscriptionType,
      });

      // Analytics event
      await _firebaseService.analytics.logEvent(
        name: 'premium_purchased',
        parameters: {
          'user_id': _firebaseService.currentUser!.uid,
          'subscription_type': subscriptionType,
          'tier': tier.name,
        },
      );
    }

    notifyListeners();
  }

  /// RevenueCat'ten premium durumunu yenile
  Future<void> refreshPremiumStatus() async {
    if (!_revenueCatService.isInitialized) return;

    final tier = await _revenueCatService.getActiveTier();
    if (tier != _membershipTier) {
      _membershipTier = tier;
      await _storage.saveIsPremium(tier != MembershipTier.standard);
      await _syncTierToFirebase();
      notifyListeners();
    }
  }

  Future<void> updateUserName(String name) async {
    await _storage.saveUserName(name);
    _userName = name;
    if (_firebaseService.isAuthenticated) {
      await _firebaseService.firestore
          .collection('users')
          .doc(_firebaseService.currentUser!.uid)
          .update({'name': name});
    }
    notifyListeners();
  }

  /// Hesabı tamamen sil — Firestore verileri + Firebase Auth kullanıcısı
  Future<void> deleteAccount() async {
    try {
      // 1. Firestore verilerini sil
      await _firebaseService.deleteUserData();
      // 2. Firebase Auth hesabını sil
      await _firebaseService.deleteUserAccount();
    } catch (e) {
      debugPrint('❌ Hesap silme hatası: $e');
      rethrow;
    } finally {
      // 3. Local state temizle
      await _storage.clearAll();
      _userName = null;
      _userEmail = null;
      _selectedZodiac = null;
      _membershipTier = MembershipTier.standard;
      _userProfile = null;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _storage.clearAll();

    // Cancel all notifications
    await NotificationService().cancelAll();

    // RevenueCat'ten çıkış yap
    await _revenueCatService.logoutUser();

    // Firebase'den çıkış yap
    if (_firebaseService.isAuthenticated) {
      await _firebaseService.signOut();
    }

    _userName = null;
    _userEmail = null;
    _selectedZodiac = null;
    _membershipTier = MembershipTier.standard;
    _userProfile = null;
    notifyListeners();
  }
  
  // Profil güncelleme metodu
  Future<void> updateProfile({
    String? name,
    DateTime? birthDate,
    String? birthTime,
    String? birthPlace,
    double? birthLatitude,
    double? birthLongitude,
  }) async {
    if (_firebaseService.isAuthenticated && _userProfile != null) {
      final updates = <String, dynamic>{};
      
      if (name != null) {
        updates['name'] = name;
        _userName = name;
        await _storage.saveUserName(name);
      }
      if (birthDate != null) updates['birthDate'] = birthDate.toIso8601String();
      if (birthTime != null) updates['birthTime'] = birthTime;
      if (birthPlace != null) updates['birthPlace'] = birthPlace;
      if (birthLatitude != null) updates['birthLatitude'] = birthLatitude;
      if (birthLongitude != null) updates['birthLongitude'] = birthLongitude;
      
      if (updates.isNotEmpty) {
        updates['lastActiveAt'] = DateTime.now().toIso8601String();

        await _firebaseService.firestore
            .collection('users')
            .doc(_firebaseService.currentUser!.uid)
            .set(updates, SetOptions(merge: true));

        // Dogum bilgisi degistiyse fun feature cache'lerini temizle
        if (birthDate != null || birthTime != null || birthPlace != null) {
          final funService = FunFeatureService();
          await funService.clearAllCaches();
        }

        // Profili yeniden yükle
        _userProfile = await _firebaseService.getUserProfile();
      }

      notifyListeners();
    }
  }
  
  /// Firebase'den profili yeniden yükle — dışarıdan (PersonalizationScreen vb.) çağrılabilir
  Future<void> reloadProfile() async {
    if (_firebaseService.isAuthenticated) {
      _userProfile = await _firebaseService.getUserProfile();
      notifyListeners();
    }
  }

  /// Doğum tarihi değiştiğinde burç değişiyorsa TÜM burç bazlı verileri sıfırla
  Future<void> changeZodiacSign(ZodiacSign newSign, DateTime newBirthDate, {String? birthTime, String? birthPlace}) async {
    if (!_firebaseService.isAuthenticated) return;
    final uid = _firebaseService.currentUser!.uid;

    // 1. Local horoscope cache'lerini temizle
    await _storage.clearAllHoroscopeCache();

    // 2. Fun feature cache'lerini temizle
    final funService = FunFeatureService();
    await funService.clearAllCaches();

    // 3. Firebase'deki eski astrolojik verileri sıfırla
    final resetData = <String, dynamic>{
      'zodiacSign': newSign.name,
      'birthDate': newBirthDate.toIso8601String(),
      'lastActiveAt': DateTime.now().toIso8601String(),
      // Astrolojik profil sıfırla — eski burca göre hesaplanmıştı
      'risingSign': '',
      'moonSign': '',
      'venusSign': '',
      'marsSign': '',
    };
    if (birthTime != null) resetData['birthTime'] = birthTime;
    if (birthPlace != null) resetData['birthPlace'] = birthPlace;

    await _firebaseService.firestore
        .collection('users')
        .doc(uid)
        .set(resetData, SetOptions(merge: true));

    // 4. Firebase sub-collections temizle (horoscopes, interactions, fun_features)
    try {
      final batch = _firebaseService.firestore.batch();

      final horoscopeSnap = await _firebaseService.firestore
          .collection('users').doc(uid)
          .collection('horoscopes')
          .get();
      for (final doc in horoscopeSnap.docs) {
        batch.delete(doc.reference);
      }

      final interactionSnap = await _firebaseService.firestore
          .collection('users').doc(uid)
          .collection('interactions')
          .get();
      for (final doc in interactionSnap.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      debugPrint('⚠️ Sub-collection temizleme hatası: $e');
    }

    // 5. Local state güncelle
    _selectedZodiac = newSign;
    await _storage.saveSelectedZodiac(newSign);

    // 6. Profili yeniden yükle
    _userProfile = await _firebaseService.getUserProfile();

    notifyListeners();
  }

  /// Doğum tarihinden burç hesapla
  static ZodiacSign calculateZodiacFromDate(DateTime date) {
    final month = date.month;
    final day = date.day;
    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) return ZodiacSign.aries;
    if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) return ZodiacSign.taurus;
    if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) return ZodiacSign.gemini;
    if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) return ZodiacSign.cancer;
    if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) return ZodiacSign.leo;
    if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) return ZodiacSign.virgo;
    if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) return ZodiacSign.libra;
    if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) return ZodiacSign.scorpio;
    if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) return ZodiacSign.sagittarius;
    if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) return ZodiacSign.capricorn;
    if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) return ZodiacSign.aquarius;
    return ZodiacSign.pisces;
  }

  // Astrolojik profil güncelleme
  Future<void> updateAstrologicalProfile({
    String? risingSign,
    String? moonSign,
    String? venusSign,
    String? marsSign,
  }) async {
    if (_firebaseService.isAuthenticated) {
      await _firebaseService.updateAstrologicalProfile(
        risingSign: risingSign,
        moonSign: moonSign,
        venusSign: venusSign,
        marsSign: marsSign,
      );
      
      // Profili yeniden yükle
      _userProfile = await _firebaseService.getUserProfile();
      notifyListeners();
    }
  }
}
