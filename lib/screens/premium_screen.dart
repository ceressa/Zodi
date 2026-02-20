import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../providers/auth_provider.dart';
import '../providers/coin_provider.dart';
import '../config/membership_config.dart';
import '../constants/colors.dart';
import '../services/activity_log_service.dart';
import '../services/revenue_cat_service.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen>
    with TickerProviderStateMixin {
  MembershipTier? _selectedTier;
  final ActivityLogService _activityLog = ActivityLogService();
  final RevenueCatService _revenueCatService = RevenueCatService();
  late final AnimationController _shimmerController;
  late final AnimationController _pulseController;
  bool _isLoading = false;
  bool _isRestoring = false;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentTier = authProvider.membershipTier;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5FF),
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        _buildHeroSection(),
                        const SizedBox(height: 24),

                        // ─── ÜYELIK PLANLARI ───
                        _buildSectionTitle('👑', 'Üyelik Planları'),
                        const SizedBox(height: 12),
                        _buildTierCards(currentTier),

                        const SizedBox(height: 28),

                        // ─── ALTIN PAKETLERİ ───
                        _buildSectionTitle('💰', 'Yıldız Tozu Paketleri'),
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            'Özellikler için Yıldız Tozu satın al',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textMuted.withOpacity(0.7),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildCoinPacks(),

                        const SizedBox(height: 20),

                        // ─── SATIN ALIMLARI GERİ YÜKLE ───
                        _buildRestoreButton(),

                        const SizedBox(height: 24),
                        _buildGuaranteeSection(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Positioned.fill(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8F5FF),
              Color(0xFFEDE9FE),
              Color(0xFFF5F3FF),
            ],
          ),
        ),
        child: CustomPaint(
          painter: _StarsPainter(),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: AppColors.textDark, size: 20),
            ),
          ),
          const Spacer(),
          // Coin balance
          Consumer<CoinProvider>(
            builder: (_, coinProvider, __) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.monetization_on,
                      size: 16, color: Color(0xFFB45309)),
                  const SizedBox(width: 4),
                  Text(
                    '${coinProvider.balance} ✨',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFB45309),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              final scale = 1.0 + (_pulseController.value * 0.06);
              return Transform.scale(scale: scale, child: child);
            },
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFFA500), Color(0xFFFF8C00)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withOpacity(0.4),
                    blurRadius: 24,
                    spreadRadius: 6,
                  ),
                ],
              ),
              child: const Icon(Icons.diamond, size: 40, color: Colors.white),
            )
                .animate(onPlay: (c) => c.repeat())
                .shimmer(duration: 2500.ms, color: Colors.white.withOpacity(0.4)),
          ),
          const SizedBox(height: 16),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF9400D3), Color(0xFFFF1493), Color(0xFFFF8C00)],
            ).createShader(bounds),
            child: const Text(
              'Astro Dozi Premium',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Yıldızların tüm sırlarını aç',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.08);
  }

  Widget _buildSectionTitle(String emoji, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTierCards(MembershipTier currentTier) {
    // Ücretsiz olmayan tier'ları göster
    final tiers = MembershipTierConfig.allTiers.where((t) => t.tier != MembershipTier.standard).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: tiers.asMap().entries.map((entry) {
          final i = entry.key;
          final tier = entry.value;
          final isCurrentTier = tier.tier == currentTier;
          final isSelected = _selectedTier == tier.tier;
          final isUpgrade = tier.tier.index > currentTier.index;

          return Padding(
            padding: EdgeInsets.only(bottom: i < tiers.length - 1 ? 12 : 0),
            child: _buildTierCard(tier, isCurrentTier, isSelected, isUpgrade),
          )
              .animate()
              .fadeIn(duration: 400.ms, delay: (200 + i * 100).ms)
              .slideX(begin: 0.04);
        }).toList(),
      ),
    );
  }

  Widget _buildTierCard(
    MembershipTierConfig tier,
    bool isCurrentTier,
    bool isSelected,
    bool isUpgrade,
  ) {
    final gradStart = tier.gradient.first;

    return GestureDetector(
      onTap: isCurrentTier
          ? null
          : () {
              setState(() {
                _selectedTier = _selectedTier == tier.tier ? null : tier.tier;
              });
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isCurrentTier
                ? AppColors.positive
                : isSelected
                    ? gradStart
                    : Colors.grey.shade200,
            width: isSelected || isCurrentTier ? 2.5 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: gradStart.withOpacity(0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Tier icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: tier.gradient),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(tier.emoji, style: const TextStyle(fontSize: 22)),
                  ),
                ),
                const SizedBox(width: 12),
                // Name + description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            tier.displayName,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                            ),
                          ),
                          if (isCurrentTier) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.positive.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Mevcut',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.positive,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tier.description,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                // Price
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₺${tier.monthlyPrice.toStringAsFixed(2).replaceAll('.', ',')}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: isSelected ? gradStart : AppColors.textDark,
                      ),
                    ),
                    const Text(
                      '/ay',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // Benefits row
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _buildBenefitChip('💰 +${tier.dailyBonus}/gün'),
                _buildBenefitChip('📺 +${tier.adReward}/reklam'),
                if (!tier.adsEnabled) _buildBenefitChip('🚫 Reklamsız'),
                if (tier.allFeaturesUnlocked)
                  _buildBenefitChip('✨ Tüm özellikler'),
              ],
            ),
            // Purchase button (shown when selected)
            if (isSelected && isUpgrade) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: tier.gradient),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: gradStart.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _purchaseTier(tier),
                      borderRadius: BorderRadius.circular(14),
                      child: Center(
                        child: Text(
                          '${tier.emoji} ${tier.displayName} Üyeliğe Geç',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
                    .animate(onPlay: (c) => c.repeat())
                    .shimmer(
                      duration: 2500.ms,
                      color: Colors.white.withOpacity(0.15),
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E8FF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Color(0xFF7C3AED),
        ),
      ),
    );
  }

  Widget _buildCoinPacks() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.95,
        children: CoinPackConfig.allPacks.asMap().entries.map((entry) {
          final i = entry.key;
          final pack = entry.value;
          return _buildCoinPackCard(pack)
              .animate()
              .fadeIn(duration: 300.ms, delay: (400 + i * 80).ms)
              .scale(begin: const Offset(0.92, 0.92), delay: (400 + i * 80).ms);
        }).toList(),
      ),
    );
  }

  Widget _buildCoinPackCard(CoinPackConfig pack) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: pack.isBestValue
              ? const Color(0xFFB45309)
              : Colors.grey.shade200,
          width: pack.isBestValue ? 2 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: pack.isBestValue
                ? const Color(0xFFB45309).withOpacity(0.15)
                : Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _purchaseCoinPack(pack),
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Coin icon
                    const Icon(Icons.monetization_on,
                        size: 36, color: Color(0xFFB45309)),
                    const SizedBox(height: 8),
                    // Amount
                    Text(
                      '${pack.coinAmount}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFB45309),
                      ),
                    ),
                    const Text(
                      'Yıldız Tozu',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFB45309),
                      ),
                    ),
                    if (pack.bonusPercent > 0) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '+%${pack.bonusPercent} bonus',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF16A34A),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    // Price
                    Text(
                      '₺${pack.price.toStringAsFixed(2).replaceAll('.', ',')}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
              // Best value badge
              if (pack.isBestValue)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFB45309), Color(0xFFF59E0B)],
                        ),
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'EN AVANTAJLI',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuaranteeSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.positive.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.positive.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shield_outlined,
                  color: AppColors.positive, size: 22),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Güvenli & Kolay',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'İstediğin zaman iptal et. Ödemen güvende.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 600.ms);
  }

  // ─── HELPER ─────────────────────────────────────────────────

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ─── RESTORE PURCHASES BUTTON ─────────────────────────────

  Widget _buildRestoreButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: TextButton(
        onPressed: _isRestoring ? null : _restorePurchases,
        child: _isRestoring
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text(
                'Satın Alımları Geri Yükle',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                  decoration: TextDecoration.underline,
                ),
              ),
      ),
    );
  }

  // ─── TIER PURCHASE (RevenueCat direkt satın alma) ────────

  /// Tier'a göre doğru RevenueCat paketini bulup satın alma başlat
  Future<void> _purchaseTier(MembershipTierConfig tier) async {
    setState(() => _isLoading = true);

    try {
      // Tier → product identifier eşleme
      String? targetProductId;
      switch (tier.tier) {
        case MembershipTier.altin:
          targetProductId = RevenueCatService.productAltinMonthly;
          break;
        case MembershipTier.elmas:
          targetProductId = RevenueCatService.productElmasMonthly;
          break;
        case MembershipTier.platinyum:
          targetProductId = RevenueCatService.productPlatinyumMonthly;
          break;
        default:
          return;
      }

      // Offerings'den paketi bul
      final offerings = await _revenueCatService.getOfferings();
      if (offerings?.current == null) {
        if (mounted) {
          _showErrorSnackBar('Ürünler yüklenemedi. Lütfen tekrar deneyin.');
        }
        return;
      }

      final packages = offerings!.current!.availablePackages;
      final matchingPackage = packages.where(
        (p) => p.storeProduct.identifier.contains(targetProductId!),
      ).firstOrNull;

      if (matchingPackage == null) {
        if (mounted) {
          _showErrorSnackBar('Bu plan şu anda kullanılamıyor.');
        }
        return;
      }

      // Direkt satın alma başlat
      final result = await _revenueCatService.purchasePackage(matchingPackage);

      if (result != null && mounted) {
        await context.read<AuthProvider>().refreshPremiumStatus();
        await _activityLog.logPremiumPurchase(tier.monthlyPrice);

        if (mounted) {
          context.read<CoinProvider>().setTier(
            context.read<AuthProvider>().membershipTier,
          );

          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${tier.emoji} ${tier.displayName} üyelik aktif edildi! 🎉',
              ),
              backgroundColor: AppColors.positive,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Satın alma hatası: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ─── COIN PACK PURCHASE (RevenueCat direkt satın alma) ───

  Future<void> _purchaseCoinPack(CoinPackConfig pack) async {
    setState(() => _isLoading = true);

    try {
      // RevenueCat offerings'den coin pack'i bul
      final offerings = await _revenueCatService.getOfferings();
      if (offerings?.current == null) {
        if (mounted) {
          _showErrorSnackBar('Ürünler yüklenemedi. Lütfen tekrar deneyin.');
        }
        return;
      }

      // Pack identifier'a göre doğru paketi bul
      final packages = offerings!.current!.availablePackages;
      final matchingPackage = packages.where(
        (p) => p.storeProduct.identifier.contains('coin_${pack.coinAmount}'),
      ).firstOrNull;

      if (matchingPackage == null) {
        if (mounted) {
          _showErrorSnackBar('Bu paket şu anda kullanılamıyor.');
        }
        return;
      }

      // Direkt satın alma başlat
      final result = await _revenueCatService.purchasePackage(matchingPackage);

      if (result != null && mounted) {
        // Coin'leri ekle
        await context.read<CoinProvider>().purchaseCoins(pack);

        if (mounted) {
          final totalCoins = pack.coinAmount + (pack.coinAmount * pack.bonusPercent ~/ 100);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('💰 $totalCoins Yıldız Tozu hesabına eklendi!'),
              backgroundColor: const Color(0xFFB45309),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Satın alma hatası: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ─── RESTORE PURCHASES ────────────────────────────────────

  Future<void> _restorePurchases() async {
    setState(() => _isRestoring = true);

    try {
      final customerInfo = await _revenueCatService.restorePurchases();

      if (!mounted) return;

      if (customerInfo != null) {
        final isPremium = customerInfo.entitlements.all[RevenueCatService.entitlementId]?.isActive ?? false;

        if (isPremium) {
          await context.read<AuthProvider>().refreshPremiumStatus();

          if (mounted) {
            context.read<CoinProvider>().setTier(
              context.read<AuthProvider>().membershipTier,
            );

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('✅ Aboneliğin geri yüklendi!'),
                backgroundColor: AppColors.positive,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('ℹ️ Aktif abonelik bulunamadı.'),
              backgroundColor: AppColors.textMuted,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Geri yükleme hatası: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRestoring = false);
      }
    }
  }
}

class _StarsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(42);
    final paint = Paint()
      ..color = const Color(0xFFFFD700).withOpacity(0.15)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 30; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final r = 1.0 + random.nextDouble() * 2.0;
      canvas.drawCircle(Offset(x, y), r, paint);
    }

    final glowPaint = Paint()
      ..color = const Color(0xFFA78BFA).withOpacity(0.08)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 5; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height * 0.5;
      canvas.drawCircle(Offset(x, y), 20 + random.nextDouble() * 30, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
