import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:crypto/crypto.dart';
import '../models/user_profile.dart';
import '../models/interaction_history.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  // iOS requires explicit clientId from GoogleService-Info.plist for Google Sign-In.
  // Android reads it from google-services.json automatically.
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: Platform.isIOS
        ? '810852009885-afjbdh25lncigcc14supeinf30gu3206.apps.googleusercontent.com'
        : null,
  );

  // Getters
  FirebaseAuth get auth => _auth;
  FirebaseFirestore get firestore => _firestore;
  FirebaseAnalytics get analytics => _analytics;
  FirebaseCrashlytics get crashlytics => _crashlytics;
  User? get currentUser => _auth.currentUser;
  bool get isAuthenticated => _auth.currentUser != null;

  // Initialize Firebase Service (Firebase.initializeApp() is called in main.dart)
  static Future<void> initialize() async {
    // NOTE: Do NOT call Firebase.initializeApp() here — it's already
    // called in main.dart. Double initialization causes iOS crashes.

    // Enable Crashlytics — chain with existing FlutterError handler
    final existingHandler = FlutterError.onError;
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
      existingHandler?.call(errorDetails);
    };
  }

  // Authentication
  Future<UserCredential?> signInAnonymously() async {
    try {
      final credential = await _auth.signInAnonymously();
      await _analytics.logLogin(loginMethod: 'anonymous');
      return credential;
    } catch (e) {
      await _crashlytics.recordError(e, StackTrace.current);
      rethrow;
    }
  }

  Future<UserCredential?> signInWithEmailPassword(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _analytics.logLogin(loginMethod: 'email');
      return credential;
    } catch (e) {
      await _crashlytics.recordError(e, StackTrace.current);
      rethrow;
    }
  }

  Future<UserCredential?> signUpWithEmailPassword(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _analytics.logSignUp(signUpMethod: 'email');
      return credential;
    } catch (e) {
      await _crashlytics.recordError(e, StackTrace.current);
      rethrow;
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Önce mevcut oturumu kapat (her seferinde hesap seçtirmek için)
      await _googleSignIn.signOut();
      
      // Google Sign In akışını başlat
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // Kullanıcı iptal etti
        return null;
      }

      // Google authentication detaylarını al
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Firebase credential oluştur
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebase'e giriş yap
      final userCredential = await _auth.signInWithCredential(credential);

      // Yeni kullanıcı mı yoksa geri dönen kullanıcı mı?
      final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
      if (isNewUser) {
        await _analytics.logSignUp(signUpMethod: 'google');
      } else {
        await _analytics.logLogin(loginMethod: 'google');
      }

      return userCredential;
    } catch (e) {
      await _crashlytics.recordError(e, StackTrace.current);
      rethrow;
    }
  }

  /// Apple ile giriş yap (Apple Store gereksinimi — Google Sign-In varsa zorunlu)
  Future<UserCredential?> signInWithApple() async {
    try {
      // Nonce oluştur — replay attack'leri önlemek için
      debugPrint('🍎 [Apple Sign-In] Step 1: Generating nonce...');
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      // Apple Sign In akışını başlat
      debugPrint('🍎 [Apple Sign-In] Step 2: Requesting Apple credential...');
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      debugPrint('🍎 [Apple Sign-In] Step 3: Got Apple credential');
      debugPrint('🍎   - email: ${appleCredential.email}');
      debugPrint('🍎   - identityToken null? ${appleCredential.identityToken == null}');
      debugPrint('🍎   - identityToken length: ${appleCredential.identityToken?.length ?? 0}');
      debugPrint('🍎   - authorizationCode null? ${appleCredential.authorizationCode == null}');

      // identityToken null kontrolü
      if (appleCredential.identityToken == null) {
        throw Exception(
          'Apple identityToken null döndü. '
          'Bundle ID veya Sign In with Apple capability kontrol edin.',
        );
      }

      // Firebase credential oluştur
      debugPrint('🍎 [Apple Sign-In] Step 4: Creating Firebase OAuthCredential...');
      debugPrint('🍎   - authorizationCode null? ${appleCredential.authorizationCode == null}');
      debugPrint('🍎   - authorizationCode length: ${appleCredential.authorizationCode?.length ?? 0}');
      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
        accessToken: appleCredential.authorizationCode,
      );

      // Firebase'e giriş yap
      debugPrint('🍎 [Apple Sign-In] Step 5: Signing in to Firebase...');
      final userCredential = await _auth.signInWithCredential(oauthCredential);
      debugPrint('🍎 [Apple Sign-In] Step 6: Firebase sign-in SUCCESS! uid=${userCredential.user?.uid}');

      // Apple ilk girişte isim veriyor, sonraki girişlerde vermiyor
      // İlk girişte displayName güncelle
      final user = userCredential.user;
      if (user != null &&
          (user.displayName == null || user.displayName!.isEmpty)) {
        final givenName = appleCredential.givenName ?? '';
        final familyName = appleCredential.familyName ?? '';
        final fullName = '$givenName $familyName'.trim();
        if (fullName.isNotEmpty) {
          await user.updateDisplayName(fullName);
          await user.reload();
        }
      }

      // Analytics
      final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
      if (isNewUser) {
        await _analytics.logSignUp(signUpMethod: 'apple');
      } else {
        await _analytics.logLogin(loginMethod: 'apple');
      }

      return userCredential;
    } on SignInWithAppleAuthorizationException catch (e) {
      debugPrint('🍎 [Apple Sign-In] AuthorizationException: code=${e.code}, message=${e.message}');
      if (e.code == AuthorizationErrorCode.canceled) {
        // Kullanıcı iptal etti
        return null;
      }
      await _crashlytics.recordError(e, StackTrace.current);
      rethrow;
    } on FirebaseAuthException catch (e) {
      debugPrint('🍎 [Apple Sign-In] FirebaseAuthException: code=${e.code}, message=${e.message}');
      await _crashlytics.recordError(e, StackTrace.current);
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('🍎 [Apple Sign-In] Unexpected error: ${e.runtimeType}: $e');
      await _crashlytics.recordError(e, stackTrace);
      rethrow;
    }
  }

  /// Rastgele nonce oluştur
  String _generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  /// SHA256 hash
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
      await _analytics.logEvent(name: 'logout');
    } catch (e) {
      await _crashlytics.recordError(e, StackTrace.current);
      rethrow;
    }
  }

  // User Profile
  Future<void> saveUserProfile(UserProfile profile) async {
    if (currentUser == null) return;
    
    try {
      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .set(profile.toJson(), SetOptions(merge: true));
      
      await _analytics.logEvent(
        name: 'profile_updated',
        parameters: {'user_id': currentUser!.uid},
      );
    } catch (e) {
      await _crashlytics.recordError(e, StackTrace.current);
      rethrow;
    }
  }

  Future<UserProfile?> getUserProfile() async {
    if (currentUser == null) return null;
    
    try {
      final doc = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .get();
      
      if (doc.exists && doc.data() != null) {
        return UserProfile.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      await _crashlytics.recordError(e, StackTrace.current);
      return null;
    }
  }

  // Interaction History
  Future<void> saveInteraction(InteractionHistory interaction) async {
    if (currentUser == null) return;
    
    try {
      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('interactions')
          .add(interaction.toJson());
      
      await _analytics.logEvent(
        name: 'interaction_saved',
        parameters: {
          'user_id': currentUser!.uid,
          'type': interaction.interactionType,
        },
      );
    } catch (e) {
      await _crashlytics.recordError(e, StackTrace.current);
      rethrow;
    }
  }

  Future<List<InteractionHistory>> getInteractionHistory({int limit = 100}) async {
    if (currentUser == null) return [];
    
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('interactions')
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();
      
      return snapshot.docs
          .map((doc) => InteractionHistory.fromJson(doc.data()))
          .toList();
    } catch (e) {
      await _crashlytics.recordError(e, StackTrace.current);
      return [];
    }
  }

  // Premium Status
  Future<void> updatePremiumStatus(bool isPremium) async {
    if (currentUser == null) return;
    
    try {
      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .update({'isPremium': isPremium});
      
      await _analytics.logEvent(
        name: isPremium ? 'premium_activated' : 'premium_deactivated',
        parameters: {'user_id': currentUser!.uid},
      );
    } catch (e) {
      await _crashlytics.recordError(e, StackTrace.current);
      rethrow;
    }
  }

  Future<bool> getPremiumStatus() async {
    if (currentUser == null) return false;
    
    try {
      final doc = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .get();
      
      return doc.data()?['isPremium'] ?? false;
    } catch (e) {
      await _crashlytics.recordError(e, StackTrace.current);
      return false;
    }
  }

  // Analytics Events
  Future<void> logHoroscopeView(String zodiacSign, String type) async {
    await _analytics.logEvent(
      name: 'horoscope_view',
      parameters: {
        'zodiac_sign': zodiacSign,
        'type': type,
      },
    );
  }

  Future<void> logCompatibilityCheck(String sign1, String sign2) async {
    await _analytics.logEvent(
      name: 'compatibility_check',
      parameters: {
        'sign1': sign1,
        'sign2': sign2,
      },
    );
  }

  Future<void> logDreamInterpretation() async {
    await _analytics.logEvent(name: 'dream_interpretation');
  }

  Future<void> logAdWatched(
    String adType, {
    String? placement,
    String? outcome,
    String? audienceSegment,
  }) async {
    await _analytics.logEvent(
      name: 'ad_watched',
      parameters: {
        'ad_type': adType,
        if (placement != null) 'placement': placement,
        if (outcome != null) 'outcome': outcome,
        if (audienceSegment != null) 'audience_segment': audienceSegment,
      },
    );
  }

  // User Feedback
  Future<void> saveFeedback(String interactionType, double rating, String? feedback) async {
    if (currentUser == null) return;
    
    try {
      await _firestore
          .collection('feedback')
          .add({
        'userId': currentUser!.uid,
        'interactionType': interactionType,
        'rating': rating,
        'feedback': feedback,
        'timestamp': FieldValue.serverTimestamp(),
      });
      
      await _analytics.logEvent(
        name: 'feedback_submitted',
        parameters: {
          'type': interactionType,
          'rating': rating,
        },
      );
    } catch (e) {
      await _crashlytics.recordError(e, StackTrace.current);
      rethrow;
    }
  }

  // Sync local data to Firebase
  Future<void> syncLocalToFirebase(Map<String, dynamic> localData) async {
    if (currentUser == null) return;
    
    try {
      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .set(localData, SetOptions(merge: true));
    } catch (e) {
      await _crashlytics.recordError(e, StackTrace.current);
      rethrow;
    }
  }

  // Delete user data
  Future<void> deleteUserData() async {
    if (currentUser == null) return;
    
    try {
      // Delete user document
      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .delete();
      
      // Delete interactions subcollection
      final interactions = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('interactions')
          .get();
      
      for (var doc in interactions.docs) {
        await doc.reference.delete();
      }
      
      await _analytics.logEvent(name: 'user_data_deleted');
    } catch (e) {
      await _crashlytics.recordError(e, StackTrace.current);
      rethrow;
    }
  }

  // Delete user account (Firebase Auth)
  Future<void> deleteUserAccount() async {
    if (currentUser == null) return;
    try {
      await currentUser!.delete();
      await _analytics.logEvent(name: 'user_account_deleted');
    } catch (e) {
      await _crashlytics.recordError(e, StackTrace.current);
      rethrow;
    }
  }

  // ============ ZENGIN PROFIL GÜNCELLEMELERİ ============

  // Kullanım istatistiklerini güncelle
  Future<void> incrementFeatureUsage(String featureName) async {
    if (currentUser == null) return;
    
    try {
      final docRef = _firestore.collection('users').doc(currentUser!.uid);
      
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        
        if (!snapshot.exists) return;
        
        final data = snapshot.data()!;
        final featureUsageCount = Map<String, int>.from(data['featureUsageCount'] ?? {});
        featureUsageCount[featureName] = (featureUsageCount[featureName] ?? 0) + 1;
        
        // Toplam kullanım sayılarını da güncelle
        final updates = <String, dynamic>{
          'featureUsageCount': featureUsageCount,
          'lastActiveAt': FieldValue.serverTimestamp(),
        };
        
        // Özelliğe göre toplam sayıları güncelle
        switch (featureName) {
          case 'daily_horoscope':
            updates['totalHoroscopeReads'] = FieldValue.increment(1);
            updates['lastHoroscopeReadDate'] = FieldValue.serverTimestamp();
            break;
          case 'compatibility':
            updates['totalCompatibilityChecks'] = FieldValue.increment(1);
            break;
          case 'dream_interpretation':
            updates['totalDreamInterpretations'] = FieldValue.increment(1);
            break;
          case 'detailed_analysis':
            updates['totalDetailedAnalyses'] = FieldValue.increment(1);
            break;
        }
        
        transaction.update(docRef, updates);
      });
      
      await _analytics.logEvent(
        name: 'feature_used',
        parameters: {'feature': featureName},
      );
    } catch (e) {
      await _crashlytics.recordError(e, StackTrace.current);
    }
  }

  // Ardışık gün sayısını güncelle
  Future<void> updateConsecutiveDays() async {
    if (currentUser == null) return;
    
    try {
      final docRef = _firestore.collection('users').doc(currentUser!.uid);
      
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        
        if (!snapshot.exists) return;
        
        final data = snapshot.data()!;
        final lastHoroscopeReadDate = data['lastHoroscopeReadDate'] != null
            ? (data['lastHoroscopeReadDate'] as Timestamp).toDate()
            : null;
        
        final now = DateTime.now();
        int consecutiveDays = data['consecutiveDays'] ?? 0;
        
        if (lastHoroscopeReadDate != null) {
          final difference = now.difference(lastHoroscopeReadDate).inDays;
          
          if (difference == 1) {
            // Dün okumuş, ardışık gün sayısını artır
            consecutiveDays++;
          } else if (difference > 1) {
            // Ara vermiş, sıfırla
            consecutiveDays = 1;
          }
          // difference == 0 ise bugün zaten okumuş, değiştirme
        } else {
          consecutiveDays = 1;
        }
        
        transaction.update(docRef, {
          'consecutiveDays': consecutiveDays,
          'lastHoroscopeReadDate': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      await _crashlytics.recordError(e, StackTrace.current);
    }
  }

  // Favori uyumluluğu ekle/çıkar
  Future<void> toggleFavoriteCompatibility(String compatibility) async {
    if (currentUser == null) return;
    
    try {
      final docRef = _firestore.collection('users').doc(currentUser!.uid);
      final doc = await docRef.get();
      
      if (!doc.exists) return;
      
      final data = doc.data()!;
      final favorites = List<String>.from(data['favoriteCompatibilities'] ?? []);
      
      if (favorites.contains(compatibility)) {
        favorites.remove(compatibility);
      } else {
        favorites.add(compatibility);
      }
      
      await docRef.update({'favoriteCompatibilities': favorites});
    } catch (e) {
      await _crashlytics.recordError(e, StackTrace.current);
    }
  }

  // Burç yorumunu kaydet/çıkar
  Future<void> toggleSavedHoroscope(String horoscopeId) async {
    if (currentUser == null) return;
    
    try {
      final docRef = _firestore.collection('users').doc(currentUser!.uid);
      final doc = await docRef.get();
      
      if (!doc.exists) return;
      
      final data = doc.data()!;
      final saved = List<String>.from(data['savedHoroscopes'] ?? []);
      
      if (saved.contains(horoscopeId)) {
        saved.remove(horoscopeId);
      } else {
        saved.add(horoscopeId);
        // En fazla 50 kayıt tut
        if (saved.length > 50) {
          saved.removeAt(0);
        }
      }
      
      await docRef.update({'savedHoroscopes': saved});
    } catch (e) {
      await _crashlytics.recordError(e, StackTrace.current);
    }
  }

  // Rüya yorumunu kaydet
  Future<void> saveDreamInterpretation(String dreamId) async {
    if (currentUser == null) return;
    
    try {
      final docRef = _firestore.collection('users').doc(currentUser!.uid);
      
      await docRef.update({
        'savedDreams': FieldValue.arrayUnion([dreamId]),
      });
    } catch (e) {
      await _crashlytics.recordError(e, StackTrace.current);
    }
  }

  // Son görüntülenen burcu güncelle
  Future<void> updateLastViewedZodiacSign(String zodiacSign) async {
    if (currentUser == null) return;
    
    try {
      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .update({
        'lastViewedZodiacSign': zodiacSign,
        'lastActiveAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      await _crashlytics.recordError(e, StackTrace.current);
    }
  }

  // Son aramaları güncelle
  Future<void> addRecentSearch(String search) async {
    if (currentUser == null) return;
    
    try {
      final docRef = _firestore.collection('users').doc(currentUser!.uid);
      final doc = await docRef.get();
      
      if (!doc.exists) return;
      
      final data = doc.data()!;
      final searches = List<String>.from(data['recentSearches'] ?? []);
      
      // Aynı arama varsa çıkar
      searches.remove(search);
      // Başa ekle
      searches.insert(0, search);
      // En fazla 20 arama tut
      if (searches.length > 20) {
        searches.removeLast();
      }
      
      await docRef.update({'recentSearches': searches});
    } catch (e) {
      await _crashlytics.recordError(e, StackTrace.current);
    }
  }

  // İlgi alanlarını güncelle
  Future<void> updateInterests(List<String> interests) async {
    if (currentUser == null) return;
    
    try {
      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .update({'interests': interests});
    } catch (e) {
      await _crashlytics.recordError(e, StackTrace.current);
    }
  }

  // Favori konuları güncelle (otomatik)
  Future<void> updateFavoriteTopics(String topic) async {
    if (currentUser == null) return;
    
    try {
      final docRef = _firestore.collection('users').doc(currentUser!.uid);
      
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        
        if (!snapshot.exists) return;
        
        final data = snapshot.data()!;
        final topics = List<String>.from(data['favoriteTopics'] ?? []);
        
        // Konu zaten varsa çıkar (en sona eklemek için)
        topics.remove(topic);
        topics.add(topic);
        
        // En fazla 10 favori konu tut
        if (topics.length > 10) {
          topics.removeAt(0);
        }
        
        transaction.update(docRef, {'favoriteTopics': topics});
      });
    } catch (e) {
      await _crashlytics.recordError(e, StackTrace.current);
    }
  }

  // İlişki durumunu güncelle
  Future<void> updateRelationshipInfo({
    String? relationshipStatus,
    String? partnerName,
    String? partnerZodiacSign,
    DateTime? partnerBirthDate,
    String? currentCity,
  }) async {
    if (currentUser == null) return;

    try {
      final updates = <String, dynamic>{};

      if (relationshipStatus != null) {
        updates['relationshipStatus'] = relationshipStatus;
      }
      if (partnerName != null) {
        updates['partnerName'] = partnerName;
      }
      if (partnerZodiacSign != null) {
        updates['partnerZodiacSign'] = partnerZodiacSign;
      }
      if (partnerBirthDate != null) {
        updates['partnerBirthDate'] = partnerBirthDate.toIso8601String();
      }
      if (currentCity != null) {
        updates['currentCity'] = currentCity;
      }

      if (updates.isNotEmpty) {
        await _firestore
            .collection('users')
            .doc(currentUser!.uid)
            .update(updates);
      }
    } catch (e) {
      await _crashlytics.recordError(e, StackTrace.current);
    }
  }

  // Kişiselleştirme bilgilerini güncelle (PersonalizationScreen için)
  Future<void> updatePersonalizationInfo({
    String? gender,
    String? relationshipStatus,
    String? partnerName,
    String? employmentStatus,
    String? occupation,
    String? workField,
    String? careerGoal,
    String? lifePhase,
    String? spiritualInterest,
    String? currentCity,
    List<String>? interests,
    List<String>? currentChallenges,
    List<String>? lifeGoals,
  }) async {
    if (currentUser == null) return;

    try {
      final updates = <String, dynamic>{
        'lastActiveAt': DateTime.now().toIso8601String(),
      };

      // Cinsiyet
      if (gender != null) updates['gender'] = gender;

      // İlişki bilgileri
      if (relationshipStatus != null) updates['relationshipStatus'] = relationshipStatus;
      if (partnerName != null) updates['partnerName'] = partnerName;
      
      // Kariyer bilgileri
      if (employmentStatus != null) updates['employmentStatus'] = employmentStatus;
      if (occupation != null) updates['occupation'] = occupation;
      if (workField != null) updates['workField'] = workField;
      if (careerGoal != null) updates['careerGoal'] = careerGoal;
      
      // Yaşam bilgileri
      if (lifePhase != null) updates['lifePhase'] = lifePhase;
      if (spiritualInterest != null) updates['spiritualInterest'] = spiritualInterest;
      if (currentCity != null) updates['currentCity'] = currentCity;
      
      // Listeler
      if (interests != null) updates['interests'] = interests;
      if (currentChallenges != null) updates['currentChallenges'] = currentChallenges;
      if (lifeGoals != null) updates['lifeGoals'] = lifeGoals;

      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .set(updates, SetOptions(merge: true));

      // Analytics event
      await _analytics.logEvent(
        name: 'profile_personalization_updated',
        parameters: {
          'has_relationship_info': (relationshipStatus != null).toString(),
          'has_career_info': (occupation != null || employmentStatus != null).toString(),
          'interests_count': (interests?.length ?? 0).toString(),
          'challenges_count': (currentChallenges?.length ?? 0).toString(),
          'goals_count': (lifeGoals?.length ?? 0).toString(),
        },
      );
    } catch (e) {
      await _crashlytics.recordError(e, StackTrace.current);
      rethrow;
    }
  }

  // Arkadaş burçlarını güncelle
  Future<void> addFriendZodiacSign(String zodiacSign) async {
    if (currentUser == null) return;
    
    try {
      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .update({
        'friendZodiacSigns': FieldValue.arrayUnion([zodiacSign]),
      });
    } catch (e) {
      await _crashlytics.recordError(e, StackTrace.current);
    }
  }

  // Okuma desenlerini güncelle
  Future<void> updateReadingPatterns(String category, int durationSeconds) async {
    if (currentUser == null) return;
    
    try {
      final docRef = _firestore.collection('users').doc(currentUser!.uid);
      
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        
        if (!snapshot.exists) return;
        
        final data = snapshot.data()!;
        final patterns = Map<String, dynamic>.from(data['readingPatterns'] ?? {});
        
        // Kategori için okuma sayısını ve toplam süreyi tut
        if (!patterns.containsKey(category)) {
          patterns[category] = {'count': 0, 'totalDuration': 0};
        }
        
        patterns[category]['count'] = (patterns[category]['count'] ?? 0) + 1;
        patterns[category]['totalDuration'] = 
            (patterns[category]['totalDuration'] ?? 0) + durationSeconds;
        
        // En çok okunan kategorileri güncelle
        final mostRead = List<String>.from(data['mostReadCategories'] ?? []);
        if (!mostRead.contains(category)) {
          mostRead.add(category);
        }
        
        // Kategorileri okuma sayısına göre sırala
        mostRead.sort((a, b) {
          final aCount = patterns[a]?['count'] ?? 0;
          final bCount = patterns[b]?['count'] ?? 0;
          return bCount.compareTo(aCount);
        });
        
        transaction.update(docRef, {
          'readingPatterns': patterns,
          'mostReadCategories': mostRead.take(5).toList(),
        });
      });
    } catch (e) {
      await _crashlytics.recordError(e, StackTrace.current);
    }
  }

  // Oturum bilgilerini güncelle
  Future<void> updateSessionInfo(int durationMinutes) async {
    if (currentUser == null) return;
    
    try {
      final docRef = _firestore.collection('users').doc(currentUser!.uid);
      
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        
        if (!snapshot.exists) return;
        
        final data = snapshot.data()!;
        final totalSessions = (data['totalSessions'] ?? 0) + 1;
        final currentAvg = data['averageSessionDuration'] ?? 0.0;
        
        // Yeni ortalama hesapla
        final newAvg = ((currentAvg * (totalSessions - 1)) + durationMinutes) / totalSessions;
        
        transaction.update(docRef, {
          'totalSessions': totalSessions,
          'averageSessionDuration': newAvg,
          'lastActiveAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      await _crashlytics.recordError(e, StackTrace.current);
    }
  }

  // Geri bildirim puanı kaydet
  Future<void> submitRating(String category, double rating, String? feedbackText) async {
    if (currentUser == null) return;
    
    try {
      final docRef = _firestore.collection('users').doc(currentUser!.uid);
      
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        
        if (!snapshot.exists) return;
        
        final data = snapshot.data()!;
        final totalFeedbacks = (data['totalFeedbacks'] ?? 0) + 1;
        final currentAvg = data['averageRating'] ?? 0.0;
        
        // Genel ortalama güncelle
        final newAvg = ((currentAvg * (totalFeedbacks - 1)) + rating) / totalFeedbacks;
        
        // Kategori bazlı puanları güncelle
        final categoryRatings = Map<String, double>.from(
          (data['categoryRatings'] ?? {}).map(
            (key, value) => MapEntry(key, (value ?? 0.0).toDouble()),
          ),
        );
        
        final categoryCount = (data['categoryFeedbackCount'] ?? {})[category] ?? 0;
        final categoryAvg = categoryRatings[category] ?? 0.0;
        final newCategoryAvg = ((categoryAvg * categoryCount) + rating) / (categoryCount + 1);
        
        categoryRatings[category] = newCategoryAvg;
        
        final categoryFeedbackCount = Map<String, int>.from(
          data['categoryFeedbackCount'] ?? {},
        );
        categoryFeedbackCount[category] = categoryCount + 1;
        
        transaction.update(docRef, {
          'totalFeedbacks': totalFeedbacks,
          'averageRating': newAvg,
          'categoryRatings': categoryRatings,
          'categoryFeedbackCount': categoryFeedbackCount,
        });
      });
      
      // Geri bildirimi ayrı koleksiyona da kaydet
      await saveFeedback(category, rating, feedbackText);
    } catch (e) {
      await _crashlytics.recordError(e, StackTrace.current);
    }
  }

  // Astrolojik profili güncelle (yükselen, ay, vb.)
  Future<void> updateAstrologicalProfile({
    String? risingSign,
    String? moonSign,
    String? venusSign,
    String? marsSign,
    String? mercurySign,
    String? jupiterSign,
    String? saturnSign,
    Map<String, dynamic>? birthChart,
  }) async {
    if (currentUser == null) return;
    
    try {
      final updates = <String, dynamic>{};
      
      if (risingSign != null) updates['risingSign'] = risingSign;
      if (moonSign != null) updates['moonSign'] = moonSign;
      if (venusSign != null) updates['venusSign'] = venusSign;
      if (marsSign != null) updates['marsSign'] = marsSign;
      if (mercurySign != null) updates['mercurySign'] = mercurySign;
      if (jupiterSign != null) updates['jupiterSign'] = jupiterSign;
      if (saturnSign != null) updates['saturnSign'] = saturnSign;
      if (birthChart != null) updates['birthChart'] = birthChart;
      
      if (updates.isNotEmpty) {
        await _firestore
            .collection('users')
            .doc(currentUser!.uid)
            .update(updates);
      }
    } catch (e) {
      await _crashlytics.recordError(e, StackTrace.current);
    }
  }

  // Tercih edilen okuma saatini güncelle (otomatik)
  Future<void> updatePreferredReadingTime() async {
    if (currentUser == null) return;
    
    try {
      final now = DateTime.now();
      final hour = now.hour;
      
      String timeSlot;
      if (hour >= 6 && hour < 12) {
        timeSlot = 'morning';
      } else if (hour >= 12 && hour < 18) {
        timeSlot = 'afternoon';
      } else if (hour >= 18 && hour < 22) {
        timeSlot = 'evening';
      } else {
        timeSlot = 'night';
      }
      
      final docRef = _firestore.collection('users').doc(currentUser!.uid);
      final doc = await docRef.get();
      
      if (!doc.exists) return;
      
      final data = doc.data()!;
      final patterns = Map<String, dynamic>.from(data['readingPatterns'] ?? {});
      
      // Zaman dilimi kullanım sayısını artır
      final timeSlotKey = 'timeSlot_$timeSlot';
      patterns[timeSlotKey] = (patterns[timeSlotKey] ?? 0) + 1;
      
      // En çok kullanılan zaman dilimini bul
      int maxCount = 0;
      String preferredTime = timeSlot;
      
      ['morning', 'afternoon', 'evening', 'night'].forEach((slot) {
        final count = patterns['timeSlot_$slot'] ?? 0;
        if (count > maxCount) {
          maxCount = count;
          preferredTime = slot;
        }
      });
      
      await docRef.update({
        'readingPatterns': patterns,
        'preferredReadingTime': preferredTime,
      });
    } catch (e) {
      await _crashlytics.recordError(e, StackTrace.current);
    }
  }

  // Kullanıcı etiketlerini güncelle (segmentasyon için)
  Future<void> updateUserTags() async {
    if (currentUser == null) return;
    
    try {
      final docRef = _firestore.collection('users').doc(currentUser!.uid);
      final doc = await docRef.get();
      
      if (!doc.exists) return;
      
      final data = doc.data()!;
      final tags = <String>[];
      
      // Otomatik etiketleme
      final isPremium = data['isPremium'] ?? false;
      final consecutiveDays = data['consecutiveDays'] ?? 0;
      final totalSessions = data['totalSessions'] ?? 0;
      final createdAt = data['createdAt'] != null
          ? DateTime.parse(data['createdAt'])
          : DateTime.now();
      final daysSinceCreation = DateTime.now().difference(createdAt).inDays;
      
      if (isPremium) tags.add('premium');
      if (consecutiveDays >= 7) tags.add('loyal');
      if (consecutiveDays >= 30) tags.add('super_loyal');
      if (totalSessions >= 50) tags.add('power_user');
      if (daysSinceCreation <= 7) tags.add('new_user');
      if (daysSinceCreation > 90) tags.add('veteran');
      
      final totalReads = data['totalHoroscopeReads'] ?? 0;
      if (totalReads > 100) tags.add('avid_reader');
      
      final totalCompatibility = data['totalCompatibilityChecks'] ?? 0;
      if (totalCompatibility > 20) tags.add('compatibility_enthusiast');
      
      final totalDreams = data['totalDreamInterpretations'] ?? 0;
      if (totalDreams > 10) tags.add('dream_explorer');
      
      await docRef.update({'tags': tags});
    } catch (e) {
      await _crashlytics.recordError(e, StackTrace.current);
    }
  }

  // Bildirim tercihlerini güncelle
  Future<void> updateNotificationSettings({
    bool? enabled,
    String? time,
  }) async {
    if (currentUser == null) return;
    
    try {
      final updates = <String, dynamic>{};
      
      if (enabled != null) updates['notificationsEnabled'] = enabled;
      if (time != null) updates['notificationTime'] = time;
      
      if (updates.isNotEmpty) {
        await _firestore
            .collection('users')
            .doc(currentUser!.uid)
            .update(updates);
      }
    } catch (e) {
      await _crashlytics.recordError(e, StackTrace.current);
    }
  }

  // Tema tercihini güncelle
  Future<void> updateThemePreference(bool darkMode) async {
    if (currentUser == null) return;
    
    try {
      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .update({'darkMode': darkMode});
    } catch (e) {
      await _crashlytics.recordError(e, StackTrace.current);
    }
  }

  // Özel alanları güncelle
  Future<void> updateCustomFields(Map<String, dynamic> customFields) async {
    if (currentUser == null) return;
    
    try {
      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .update({'customFields': customFields});
    } catch (e) {
      await _crashlytics.recordError(e, StackTrace.current);
    }
  }

  // Tek bir kullanıcı alanını güncelle
  Future<void> updateUserField(String field, dynamic value) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    await _firestore.collection('users').doc(userId).update({field: value});
  }

  // ============ RUH EŞİ ÇİZİMİ — FREE-ONCE TAKİBİ ============

  /// Platinyum kullanıcı ücretsiz hakkını kullanmış mı?
  Future<bool> hasSoulmateSketchFreeUsed() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return true;
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.data()?['soulmateSketchFreeUsed'] ?? false;
    } catch (e) {
      debugPrint('soulmateSketchFreeUsed okuma hatası: $e');
      return true; // Hata durumunda güvenli taraf: ücretsiz hakkı yok say
    }
  }

  /// Ücretsiz hakkı kullanıldı olarak işaretle
  Future<void> markSoulmateSketchFreeUsed() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    try {
      await _firestore.collection('users').doc(userId).update({
        'soulmateSketchFreeUsed': true,
      });
    } catch (e) {
      debugPrint('soulmateSketchFreeUsed yazma hatası: $e');
    }
  }

  // ============ TAROT OKUMA YÖNETİMİ ============

  // Tarot okumasını kaydet
  Future<void> saveTarotReading(
    String userId,
    String readingId,
    Map<String, dynamic> reading,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('tarotReadings')
          .doc(readingId)
          .set(reading);

      await _analytics.logEvent(
        name: 'tarot_reading_saved',
        parameters: {
          'user_id': userId,
          'type': reading['type'],
        },
      );
    } catch (e) {
      await _crashlytics.recordError(e, StackTrace.current);
      rethrow;
    }
  }

  // Kullanıcının tarot okumalarını getir
  Future<List<dynamic>> getTarotReadings(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('tarotReadings')
          .orderBy('date', descending: true)
          .limit(50)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      await _crashlytics.recordError(e, StackTrace.current);
      return [];
    }
  }

  // Belirli bir tarot okumasını getir
  Future<Map<String, dynamic>?> getTarotReading(
    String userId,
    String readingId,
  ) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('tarotReadings')
          .doc(readingId)
          .get();

      return doc.data();
    } catch (e) {
      await _crashlytics.recordError(e, StackTrace.current);
      return null;
    }
  }

  // Tarot kullanım sayısını artır
  Future<void> incrementTarotUsage(String type) async {
    if (currentUser == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .update({
        'totalTarotReadings': FieldValue.increment(1),
        'lastTarotReadingDate': FieldValue.serverTimestamp(),
      });

      await _analytics.logEvent(
        name: 'tarot_reading',
        parameters: {'type': type},
      );
    } catch (e) {
      await _crashlytics.recordError(e, StackTrace.current);
    }
  }
}
