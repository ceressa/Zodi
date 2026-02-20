import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import '../config/membership_config.dart';

/// RevenueCat SDK entegrasyonu — abonelik ve satın alma yönetimi
///
/// Entitlement: "Astro Dozi Premium"
/// Ürünler: weekly, monthly, yearly, lifetime
/// API Key: RevenueCat Dashboard'dan alınır
class RevenueCatService {
  static final RevenueCatService _instance = RevenueCatService._internal();
  factory RevenueCatService() => _instance;
  RevenueCatService._internal();

  static const String _apiKey = 'goog_lqGgYaZSYFbfjsrSMIKjqqHMifC';
  static const String entitlementId = 'Astro Dozi Premium';

  /// Ürün tanımlayıcıları — RevenueCat Dashboard'daki product identifiers
  static const String productWeekly = 'weekly';
  static const String productMonthly = 'monthly';
  static const String productYearly = 'yearly';
  static const String productLifetime = 'lifetime';

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // ─── INITIALIZATION ───────────────────────────────────────────

  /// SDK'yı başlat — main.dart'ta Firebase init'ten sonra çağrılmalı
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await Purchases.setLogLevel(LogLevel.debug);

      final configuration = PurchasesConfiguration(_apiKey);
      await Purchases.configure(configuration);

      _isInitialized = true;
      debugPrint('✅ RevenueCat initialized');
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

    // Platinyum ürünleri (lifetime veya yearly)
    if (id.contains('lifetime') || id.contains('platinyum')) {
      return MembershipTier.platinyum;
    }
    // Elmas ürünleri (yearly)
    if (id.contains('yearly') || id.contains('elmas')) {
      return MembershipTier.elmas;
    }
    // Altın ürünleri (monthly, weekly)
    if (id.contains('monthly') || id.contains('weekly') || id.contains('altin')) {
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

  // ─── PAYWALL ──────────────────────────────────────────────────

  /// RevenueCat Paywall'ı göster — tam ekran
  Future<PaywallResult> presentPaywall() async {
    try {
      final result = await RevenueCatUI.presentPaywall();
      debugPrint('✅ Paywall result: $result');
      return result;
    } catch (e) {
      debugPrint('❌ Paywall error: $e');
      return PaywallResult.error;
    }
  }

  /// Paywall'ı sadece premium değilse göster
  Future<PaywallResult> presentPaywallIfNeeded() async {
    try {
      final result = await RevenueCatUI.presentPaywallIfNeeded(entitlementId);
      debugPrint('✅ Paywall if needed result: $result');
      return result;
    } catch (e) {
      debugPrint('❌ Paywall if needed error: $e');
      return PaywallResult.error;
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
      if (productId.contains('weekly')) return 'weekly';
      if (productId.contains('monthly')) return 'monthly';
      if (productId.contains('yearly')) return 'yearly';
      if (productId.contains('lifetime')) return 'lifetime';
      return productId;
    } catch (e) {
      debugPrint('❌ Subscription type error: $e');
      return null;
    }
  }
}
