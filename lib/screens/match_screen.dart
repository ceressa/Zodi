import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/horoscope_provider.dart';
import '../providers/coin_provider.dart';
import '../models/zodiac_sign.dart';
import '../constants/colors.dart';
import '../constants/strings.dart';
import '../services/firebase_service.dart';
import '../services/ad_service.dart';
import '../config/membership_config.dart';
import 'compatibility_report_screen.dart';
import 'premium_screen.dart';
import '../theme/cosmic_page_route.dart';
import '../services/activity_log_service.dart';

class MatchScreen extends StatefulWidget {
  final bool showAppBar;
  const MatchScreen({super.key, this.showAppBar = false});

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final AdService _adService = AdService();
  final ActivityLogService _activityLog = ActivityLogService();
  final _scrollController = ScrollController();
  final _resultKey = GlobalKey();
  ZodiacSign? _selectedPartner;
  bool _resultUnlocked = false;

  static const int _basicCost = 5;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool _isBasicFree(AuthProvider authProvider) {
    return authProvider.membershipTier.index >= MembershipTier.elmas.index;
  }

  bool _isDetailedAccessible(AuthProvider authProvider) {
    return authProvider.membershipTier.index >= MembershipTier.elmas.index;
  }

  void _onPartnerSelected(ZodiacSign sign) {
    setState(() {
      _selectedPartner = sign;
      _resultUnlocked = false;
    });

    final authProvider = context.read<AuthProvider>();
    if (_isBasicFree(authProvider)) {
      _resultUnlocked = true;
      _loadCompatibility();
    }
  }

  Future<void> _unlockWithCoins() async {
    final coinProvider = context.read<CoinProvider>();
    final success = await coinProvider.spendCoins(_basicCost, 'compatibility_basic');
    if (success && mounted) {
      setState(() => _resultUnlocked = true);
      _loadCompatibility();
    }
  }

  void _unlockWithAd() async {
    final success = await _adService.showRewardedAd(placement: 'compatibility_basic');
    if (success && mounted) {
      setState(() => _resultUnlocked = true);
      _loadCompatibility();
    }
  }

  Future<void> _loadCompatibility() async {
    final authProvider = context.read<AuthProvider>();
    final horoscopeProvider = context.read<HoroscopeProvider>();

    if (authProvider.selectedZodiac != null && _selectedPartner != null) {
      await horoscopeProvider.fetchCompatibility(
        authProvider.selectedZodiac!,
        _selectedPartner!,
      );

      await _activityLog.logCompatibility(authProvider.selectedZodiac!.name, _selectedPartner!.name);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_resultKey.currentContext != null) {
          Scrollable.ensureVisible(
            _resultKey.currentContext!,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            alignment: 0.0,
          );
        }
      });

      if (_firebaseService.isAuthenticated) {
        _firebaseService.incrementFeatureUsage('compatibility');
        final compatibilityKey = '${authProvider.selectedZodiac!.name}_${_selectedPartner!.name}';
        _firebaseService.toggleFavoriteCompatibility(compatibilityKey);
        _firebaseService.updateRelationshipInfo(
          partnerZodiacSign: _selectedPartner!.name,
        );
        _firebaseService.updateReadingPatterns('compatibility', 30);
        _firebaseService.updateFavoriteTopics('compatibility');
        _firebaseService.logCompatibilityCheck(
          authProvider.selectedZodiac!.name,
          _selectedPartner!.name,
        );
      }
    }
  }

  void _openDetailedReport(AuthProvider authProvider) {
    if (_isDetailedAccessible(authProvider)) {
      Navigator.push(
        context,
        CosmicPageRoute(
          page: CompatibilityReportScreen(
            userSign: authProvider.selectedZodiac!,
            partnerSign: _selectedPartner!,
          ),
        ),
      );
    } else {
      _showReportGateDialog();
    }
  }

  void _showReportGateDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppColors.cosmicGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.lock, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Elmas+ Özel', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        content: const Text(
          'Detaylı uyum raporu Elmas ve üstü üyeliklere özeldir.',
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Vazgeç', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(context, CosmicBottomSheetRoute(page: const PremiumScreen()));
            },
            icon: const Icon(Icons.diamond, size: 18),
            label: const Text('Üyeliğini Yükselt'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = context.watch<AuthProvider>();
    final horoscopeProvider = context.watch<HoroscopeProvider>();
    final coinProvider = context.watch<CoinProvider>();

    final bgColor = const Color(0xFFF8F5FF);

    final body = SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // === Kullanıcı Burç Header ===
          if (authProvider.selectedZodiac != null) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF4C1D95).withValues(alpha: 0.4), const Color(0xFF7C3AED).withValues(alpha: 0.2)]
                      : [const Color(0xFF7C3AED).withValues(alpha: 0.08), const Color(0xFFA78BFA).withValues(alpha: 0.06)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFFA78BFA).withValues(alpha: 0.20)
                      : const Color(0xFF7C3AED).withValues(alpha: 0.12),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.03)
                        : Colors.white.withValues(alpha: 0.60),
                    blurRadius: 6,
                    offset: const Offset(-2, -2),
                  ),
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.25)
                        : const Color(0xFF7C3AED).withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(3, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7C3AED), Color(0xFFA78BFA)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7C3AED).withValues(alpha: 0.30),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        authProvider.selectedZodiac!.symbol,
                        style: const TextStyle(fontSize: 32, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Senin Burcun',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white54 : AppColors.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          authProvider.selectedZodiac!.displayName,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // === Açıklama ===
          Text(
            'Hangi burçla uyumunu öğrenmek istersin?',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white60 : AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),

          // === Partner Seçimi ===
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: ZodiacSign.values.map((sign) {
              final isSelected = _selectedPartner == sign;

              return GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => _onPartnerSelected(sign),
                child: Container(
                  width: (MediaQuery.of(context).size.width - 72) / 3,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [Color(0xFF7C3AED), Color(0xFFA78BFA)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isSelected
                        ? null
                        : (isDark ? AppColors.cardDark : AppColors.cardLight),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFA78BFA).withValues(alpha: 0.5)
                          : (isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : AppColors.borderLight.withValues(alpha: 0.5)),
                      width: isSelected ? 2 : 1.5,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFF7C3AED).withValues(alpha: 0.25),
                              blurRadius: 16,
                              spreadRadius: 2,
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.02)
                                  : Colors.white.withValues(alpha: 0.50),
                              blurRadius: 4,
                              offset: const Offset(-1, -1),
                            ),
                            BoxShadow(
                              color: isDark
                                  ? Colors.black.withValues(alpha: 0.20)
                                  : Colors.black.withValues(alpha: 0.04),
                              blurRadius: 6,
                              offset: const Offset(2, 2),
                            ),
                          ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        sign.symbol,
                        style: TextStyle(
                          fontSize: 32,
                          color: isSelected ? Colors.white : null,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        sign.displayName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? Colors.white : AppColors.textDark),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          // ─── Coin/Ad Gate (non-premium users) ───
          if (_selectedPartner != null && !_resultUnlocked && !_isBasicFree(authProvider)) ...[
            const SizedBox(height: 32),
            Container(
              key: _resultKey,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF1E1B4B), const Color(0xFF252158)]
                      : [Colors.white, const Color(0xFFFAF5FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : const Color(0xFF7C3AED).withValues(alpha: 0.10),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.03)
                        : Colors.white.withValues(alpha: 0.60),
                    blurRadius: 6,
                    offset: const Offset(-2, -2),
                  ),
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.25)
                        : Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(3, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        authProvider.selectedZodiac?.symbol ?? '',
                        style: const TextStyle(fontSize: 36),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.favorite, color: Color(0xFFEC4899), size: 28),
                      const SizedBox(width: 12),
                      Text(
                        _selectedPartner!.symbol,
                        style: const TextStyle(fontSize: 36),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Uyum sonucunu görmek için',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Coin ile aç
                  if (coinProvider.canAfford(_basicCost))
                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF7C3AED), Color(0xFFA78BFA)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ElevatedButton.icon(
                          onPressed: _unlockWithCoins,
                          icon: const Icon(Icons.monetization_on, size: 20),
                          label: Text('Keşfet! ($_basicCost Yıldız Tozu)'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    )
                  else
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.monetization_on, size: 18, color: Color(0xFFF59E0B)),
                            const SizedBox(width: 6),
                            Text(
                              '${coinProvider.balance} / $_basicCost Yıldız Tozu',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFF59E0B),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Yetersiz bakiye',
                          style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.grey.shade500),
                        ),
                      ],
                    ),
                  const SizedBox(height: 12),

                  // Reklam ile aç — ince, şık
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFFA78BFA).withValues(alpha: 0.25)
                              : const Color(0xFF7C3AED).withValues(alpha: 0.15),
                          width: 1.5,
                        ),
                        color: isDark
                            ? const Color(0xFF1E1B4B).withValues(alpha: 0.3)
                            : const Color(0xFFF8F5FF),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _unlockWithAd,
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.play_circle_outline_rounded,
                                  size: 20,
                                  color: isDark ? const Color(0xFFA78BFA) : const Color(0xFF7C3AED),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Reklam İzle',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? const Color(0xFFA78BFA) : const Color(0xFF7C3AED),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ]

          // ─── Loading ───
          else if (horoscopeProvider.isLoadingCompatibility) ...[
            const SizedBox(height: 32),
            Center(
              key: _resultKey,
              child: const CircularProgressIndicator(color: Color(0xFF7C3AED)),
            ),
          ]

          // ─── Results ───
          else if (horoscopeProvider.compatibilityResult != null && _selectedPartner != null && _resultUnlocked) ...[
            const SizedBox(height: 32),

            // === Skor kartı ===
            Container(
              key: _resultKey,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4C1D95), Color(0xFF7C3AED), Color(0xFFA78BFA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7C3AED).withValues(alpha: 0.30),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        authProvider.selectedZodiac!.symbol,
                        style: const TextStyle(fontSize: 40, color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.20),
                        ),
                        child: const Center(
                          child: Icon(Icons.favorite, color: Color(0xFFF59E0B), size: 28),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        _selectedPartner!.symbol,
                        style: const TextStyle(fontSize: 40, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.matchScore,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '%${horoscopeProvider.compatibilityResult!.score}',
                    style: const TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFF59E0B),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // === Aspect kartları ===
            Row(
              children: [
                Expanded(
                  child: _AspectCard(
                    label: AppStrings.matchLove,
                    value: horoscopeProvider.compatibilityResult!.aspects.love,
                    emoji: '💕',
                    color: const Color(0xFFF472B6),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _AspectCard(
                    label: AppStrings.matchCommunication,
                    value: horoscopeProvider.compatibilityResult!.aspects.communication,
                    emoji: '💬',
                    color: const Color(0xFF60A5FA),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _AspectCard(
                    label: AppStrings.matchTrust,
                    value: horoscopeProvider.compatibilityResult!.aspects.trust,
                    emoji: '🤝',
                    color: const Color(0xFF34D399),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // === Özet ===
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF1E1B4B), const Color(0xFF252158)]
                      : [Colors.white, const Color(0xFFFAF5FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : const Color(0xFF7C3AED).withValues(alpha: 0.08),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.03)
                        : Colors.white.withValues(alpha: 0.60),
                    blurRadius: 6,
                    offset: const Offset(-2, -2),
                  ),
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.25)
                        : Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(3, 3),
                  ),
                ],
              ),
              child: Text(
                horoscopeProvider.compatibilityResult!.summary,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: isDark ? Colors.white.withValues(alpha: 0.8) : AppColors.textDark,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // === Detaylı Rapor Butonu ===
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: AppColors.cosmicGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7C3AED).withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _openDetailedReport(authProvider),
                  borderRadius: BorderRadius.circular(24),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.description, color: Colors.white),
                        const SizedBox(width: 8),
                        const Text(
                          'Detaylı Uyum Raporu Al',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        if (!_isDetailedAccessible(authProvider))
                          Container(
                            margin: const EdgeInsets.only(left: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'ELMAS+',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white),
                            ),
                          )
                        else
                          const Text(' ✨', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ] else if (_selectedPartner == null) ...[
            const SizedBox(height: 40),
            Center(
              child: Column(
                children: [
                  Opacity(
                    opacity: 0.18,
                    child: Image.asset(
                      'assets/astro_dozi_hi.webp',
                      width: 100,
                      height: 100,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.favorite_border,
                        size: 60,
                        color: isDark ? Colors.white24 : AppColors.textMuted,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Bir burç seç ve uyumunuzu öğren',
                    style: TextStyle(
                      color: isDark ? Colors.white38 : AppColors.textMuted,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );

    if (!widget.showAppBar) return body;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : AppColors.textDark,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppStrings.matchTitle,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : AppColors.textDark,
          ),
        ),
        centerTitle: true,
      ),
      body: body,
    );
  }
}

class _AspectCard extends StatelessWidget {
  final String label;
  final int value;
  final String emoji;
  final Color color;

  const _AspectCard({
    required this.label,
    required this.value,
    required this.emoji,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E1B4B), const Color(0xFF252158)]
              : [Colors.white, const Color(0xFFFAF5FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? color.withValues(alpha: 0.15)
              : color.withValues(alpha: 0.12),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.white.withValues(alpha: 0.02)
                : Colors.white.withValues(alpha: 0.50),
            blurRadius: 4,
            offset: const Offset(-1, -1),
          ),
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.20)
                : color.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.white54 : AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            '%$value',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}
