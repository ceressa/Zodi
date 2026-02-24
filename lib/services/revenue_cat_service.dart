import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import '../config/membership_config.dart';

// NOT: purchases_ui_flutter sadece presentCustomerCenter() için kullanılıyor.
// Paywall kendi UI'ımızda (premium_screen.dart), satın alma RevenueCat SDK ile yapılıyor.

/// RevenueCat SDK entegrasyonu — abonelik ve satın alma yönetimi
///
/// Entitlement: "Astro Dozi Premium"
/// Ürünler: altin_monthly, elmas_monthly, platinyum_monthly, lifetime
/// API Key: RevenueCat Dashboard'dan alınır (platform-specific)
class RevenueCatService {
  static final RevenueCatService _instance = RevenueCatService._internal();
  factory RevenueCatService() => _instance;
  RevenueCatService._internal();

  static const String _googleApiKey = 'goog_lqGgYaZSYFbfjsrSMIKjqqHMifC';
  static const String _appleApiKey = 'appl_KKyQlEFlGXvSuJDBEfjvHejpzPN';
  static const String entitlementId = 'Astro Dozi Premium';

  /// Ürün tanımlayıcıları — Google Play Console'daki subscription/product IDs
  static const String productAltinMonthly = 'altin_monthly';
  static const String productElmasMonthly = 'elmas_monthly';
  static const String productPlatinyumMonthly = 'platinyum_monthly';
  static const String productLifetime = 'lifetime';

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // ─── INITIALIZATION ───────────────────────────────────────────

  /// SDK'yı başlat — main.dart'ta Firebase init'ten sonra çağrılmalı
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final apiKey = Platform.isIOS ? _appleApiKey : _googleApiKey;

      // iOS'ta Apple API key henüz ayarlanmadıysa skip et
      if (apiKey.isEmpty) {
        debugPrint('⚠️ RevenueCat: No API key for ${Platform.operatingSystem}, skipping init');
        return;
      }

      await Purchases.setLogLevel(LogLevel.debug);

      final configuration = PurchasesConfiguration(apiKey);
      await Purchases.configure(configuration);

      _isInitialized = true;
      debugPrint('✅ RevenueCat initialized (${Platform.operatingSystem})');
    } catch (e) {
      debugPrint('❌ RevenueCat init error: $e');
    }
  }

  // ─── USER MANAGEMENT ──────────────────────────────────────────

  /// Firebase UID ile RevenueCat kullanıcısını eşleştir
  Future<void> loginUser(String userId) async {
    try {
      final result = await Purchases.logIn(userId);
      debugPrint('✅ RevenueCat user logged in: ${result.customerInfo.originalAppUserId}');
    } catch (e) {
      debugPrint('❌ RevenueCat login error: $e');
    }
  }

  /// Kullanıcı çıkış — anonim kullanıcıya dön
  Future<void> logoutUser() async {
    try {
      final isAnonymous = await Purchases.isAnonymous;
      if (!isAnonymous) {
        await Purchases.logOut();
        debugPrint('✅ RevenueCat user logged out');
      }
    } catch (e) {
      debugPrint('❌ RevenueCat logout error: $e');
    }
  }

  // ─── ENTITLEMENT CHECK ────────────────────────────────────────

  /// Kullanıcının aktif premium aboneliği var mı kontrol et
  Future<bool> isPremiumActive() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.all[entitlementId]?.isActive ?? false;
    } catch (e) {
      debugPrint('❌ RevenueCat entitlement check error: $e');
      return false;
    }
  }

  /// Detaylı müşteri bilgisi al
  Future<CustomerInfo?> getCustomerInfo() async {
    try {
      return await Purchases.getCustomerInfo();
    } catch (e) {
      debugPrint('❌ RevenueCat customer info error: $e');
      return null;
    }
  }

  /// Aktif abonelik tier'ını belirle (RevenueCat product → MembershipTier)
  Future<MembershipTier> getActiveTier() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final entitlement = customerInfo.entitlements.all[entitlementId];

      if (entitlement == null || !entitlement.isActive) {
        return MembershipTier.standard;
      }

      // Product identifier'a göre tier belirle
      final productId = entitlement.productIdentifier;
      return productToTier(productId);
    } catch (e) {
      debugPrint('❌ RevenueCat tier check error: $e');
      return MembershipTier.standard;
    }
  }

  /// Product identifier → MembershipTier eşleme
  MembershipTier productToTier(String productId) {
    final id = productId.toLowerCase();

    // Platinyum ürünleri
    if (id.contains('platinyum') || id.contains('lifetime')) {
      return MembershipTier.platinyum;
    }
    // Elmas ürünleri
    if (id.contains('elmas')) {
      return MembershipTier.elmas;
    }
    // Altın ürünleri
    if (id.contains('altin')) {
      return MembershipTier.altin;
    }

    // Varsayılan: aktif entitlement varsa en az altın
    return MembershipTier.altin;
  }

  // ─── OFFERINGS ────────────────────────────────────────────────

  /// Mevcut teklifleri (offerings) al
  Future<Offerings?> getOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      if (offerings.current != null) {
        debugPrint('✅ RevenueCat offerings loaded: ${offerings.current!.availablePackages.length} packages');
      }
      return offerings;
    } catch (e) {
      debugPrint('❌ RevenueCat offerings error: $e');
      return null;
    }
  }

  /// Belirli bir offering al
  Future<Offering?> getOffering(String offeringId) async {
    try {
      final offerings = await Purchases.getOfferings();
      return offerings.getOffering(offeringId);
    } catch (e) {
      debugPrint('❌ RevenueCat offering error: $e');
      return null;
    }
  }

  // ─── PURCHASES ────────────────────────────────────────────────

  /// Paket satın al
  Future<PurchaseResult?> purchasePackage(Package package) async {
    try {
      final purchaseParams = PurchaseParams.package(package);
      final result = await Purchases.purchase(purchaseParams);
      debugPrint('✅ Purchase successful: ${package.storeProduct.identifier}');
      return result;
    } on PurchasesErrorCode catch (e) {
      if (e == PurchasesErrorCode.purchaseCancelledError) {
        debugPrint('ℹ️ Purchase cancelled by user');
      } else {
        debugPrint('❌ Purchase error: $e');
      }
      return null;
    } catch (e) {
      debugPrint('❌ Purchase error: $e');
      return null;
    }
  }

  /// Satın alımları geri yükle
  Future<CustomerInfo?> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      debugPrint('✅ Purchases restored');
      return customerInfo;
    } catch (e) {
      debugPrint('❌ Restore error: $e');
      return null;
    }
  }

  // ─── CUSTOMER CENTER ──────────────────────────────────────────

  /// Customer Center'ı göster — abonelik yönetimi
  Future<void> presentCustomerCenter() async {
    try {
      await RevenueCatUI.presentCustomerCenter();
      debugPrint('✅ Customer Center presented');
    } catch (e) {
      debugPrint('❌ Customer Center error: $e');
    }
  }

  // ─── LISTENERS ────────────────────────────────────────────────

  /// Müşteri bilgisi değişikliklerini dinle
  void addCustomerInfoListener(void Function(CustomerInfo) listener) {
    Purchases.addCustomerInfoUpdateListener(listener);
  }

  // ─── HELPERS ──────────────────────────────────────────────────

  /// Abonelik bitiş tarihini al
  Future<DateTime?> getExpirationDate() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final entitlement = customerInfo.entitlements.all[entitlementId];

      if (entitlement != null && entitlement.expirationDate != null) {
        return DateTime.parse(entitlement.expirationDate!);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Expiration date error: $e');
      return null;
    }
  }

  /// Aktif abonelik tipini string olarak al
  Future<String?> getActiveSubscriptionType() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final entitlement = customerInfo.entitlements.all[entitlementId];

      if (entitlement == null || !entitlement.isActive) return null;

      final productId = entitlement.productIdentifier.toLowerCase();
      if (productId.contains('platinyum')) return 'platinyum';
      if (productId.contains('lifetime')) return 'lifetime';
      if (productId.contains('elmas')) return 'elmas';
      if (productId.contains('altin')) return 'altin';
      return productId;
    } catch (e) {
      debugPrint('❌ Subscription type error: $e');
      return null;
    }
  }
}
