import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../services/storage_service.dart';
import '../services/firebase_service.dart';
import '../models/zodiac_sign.dart';
import '../models/user_profile.dart';

class AuthProvider with ChangeNotifier {
  final StorageService _storage = StorageService();
  final FirebaseService _firebaseService = FirebaseService();
  StreamSubscription<User?>? _authStateSubscription;

  String? _userName;
  String? _userEmail;
  ZodiacSign? _selectedZodiac;
  bool _isPremium = false;
  bool _isLoading = true;
  UserProfile? _userProfile;

  String? get userName => _userName;
  String? get userEmail => _userEmail;
  ZodiacSign? get selectedZodiac => _selectedZodiac;
  bool get isPremium => _isPremium;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _userName != null && _userEmail != null;
  bool get hasSelectedZodiac => _selectedZodiac != null;
  UserProfile? get userProfile => _userProfile;
  String? get userId => _firebaseService.currentUser?.uid;

  AuthProvider() {
    _loadUserData();
    _listenToAuthState();
  }

  void _listenToAuthState() {
    _authStateSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null && _userName != null) {
        // User signed out externally
        _userName = null;
        _userEmail = null;
        _isPremium = false;
        _userProfile = null;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    _isLoading = true;
    notifyListeners();

    _userName = await _storage.getUserName();
    _userEmail = await _storage.getUserEmail();
    _selectedZodiac = await _storage.getSelectedZodiac();
    _isPremium = await _storage.getIsPremium();

    // Firebase'den profil yükle
    if (_firebaseService.isAuthenticated) {
      _userProfile = await _firebaseService.getUserProfile();
      
      // Firebase'deki verilerle local storage'ı senkronize et
      if (_userProfile != null) {
        _isPremium = _userProfile!.isPremium;
        if (_userProfile!.zodiacSign.isNotEmpty) {
          try {
            _selectedZodiac = ZodiacSign.values.firstWhere(
              (z) => z.name == _userProfile!.zodiacSign,
            );
          } catch (e) {
            // Zodiac sign bulunamazsa local storage'dakini kullan
          }
        }
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> login(String name, String email) async {
    await _storage.saveUserName(name);
    await _storage.saveUserEmail(email);
    _userName = name;
    _userEmail = email;
    
    // Firebase'e profil oluştur/güncelle
    if (_firebaseService.isAuthenticated) {
      final profile = UserProfile(
        userId: _firebaseService.currentUser!.uid,
        name: name,
        email: email,
        createdAt: DateTime.now(),
        lastActiveAt: DateTime.now(),
        birthDate: DateTime(1900, 1, 1), // Placeholder - profil kurulumunda güncellenecek
        birthTime: '',
        birthPlace: '',
        zodiacSign: _selectedZodiac?.name ?? '',
        isPremium: _isPremium,
      );
      
      await _firebaseService.saveUserProfile(profile);
      _userProfile = profile;
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

  Future<void> upgradeToPremium({String subscriptionType = 'lifetime'}) async {
    _isPremium = true;

    // Firebase'e premium durumunu kaydet (source of truth)
    if (_firebaseService.isAuthenticated) {
      await _storage.saveIsPremium(true);
      await _firebaseService.updatePremiumStatus(true);
      
      // Premium başlangıç tarihini kaydet
      await _firebaseService.firestore
          .collection('users')
          .doc(_firebaseService.currentUser!.uid)
          .update({
        'premiumStartDate': DateTime.now().toIso8601String(),
        'subscriptionType': subscriptionType
      });
      
      // Analytics event
      await _firebaseService.analytics.logEvent(
        name: 'premium_purchased',
        parameters: {'user_id': _firebaseService.currentUser!.uid, 'subscription_type': subscriptionType},
      );
    }
    
    notifyListeners();
  }

  Future<void> logout() async {
    await _storage.clearAll();
    
    // Firebase'den çıkış yap
    if (_firebaseService.isAuthenticated) {
      await _firebaseService.signOut();
    }
    
    _userName = null;
    _userEmail = null;
    _selectedZodiac = null;
    _isPremium = false;
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
            .update(updates);
        
        // Profili yeniden yükle
        _userProfile = await _firebaseService.getUserProfile();
      }
      
      notifyListeners();
    }
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
