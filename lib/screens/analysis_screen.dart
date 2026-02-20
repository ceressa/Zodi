import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/horoscope_provider.dart';
import '../providers/coin_provider.dart';
import '../constants/colors.dart';
import '../constants/strings.dart';
import '../config/membership_config.dart';
import '../services/ad_service.dart';
import '../services/activity_log_service.dart';
import 'premium_screen.dart';
import '../theme/cosmic_page_route.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  final AdService _adService = AdService();
  final ActivityLogService _activityLog = ActivityLogService();
  bool _isLoadingCategory = false;
  String? _loadingCategoryName;

  static const int _analysisCost = 10;

  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'Aşk',
      'emoji': '❤️',
      'icon': Icons.favorite_rounded,
      'gradient': [const Color(0xFFFF1493), const Color(0xFFFF69B4)],
      'description': 'Romantik hayatın ve ilişkilerin',
    },
    {
      'name': 'Kariyer',
      'emoji': '💼',
      'icon': Icons.work_rounded,
      'gradient': [const Color(0xFF6366F1), const Color(0xFF818CF8)],
      'description': 'İş ve kariyer fırsatların',
    },
    {
      'name': 'Sağlık',
      'emoji': '🌿',
      'icon': Icons.spa_rounded,
      'gradient': [const Color(0xFF10B981), const Color(0xFF34D399)],
      'description': 'Fiziksel ve mental sağlığın',
    },
    {
      'name': 'Para',
      'emoji': '💰',
      'icon': Icons.account_balance_wallet_rounded,
      'gradient': [const Color(0xFFEAB308), const Color(0xFFFBBF24)],
      'description': 'Finansal durumun ve şansın',
    },
  ];

  bool _isElmasPlus(AuthProvider auth) {
    return auth.membershipTier.index >= MembershipTier.elmas.index;
  }

  bool _isYildizPlus(AuthProvider auth) {
    return auth.membershipTier.index >= MembershipTier.altin.index;
  }

  Future<void> _onCategoryTap(String category) async {
    final authProvider = context.read<AuthProvider>();

    if (_isElmasPlus(authProvider)) {
      _loadAndShowAnalysis(category);
    } else if (_isYildizPlus(authProvider)) {
      _showCoinGate(category);
    } else {
      _showStandardGate(category);
    }
  }

  void _showCoinGate(String category) {
    final coinProvider = context.read<CoinProvider>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1E233F)
              : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '$category Analizi',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Detaylı analiz için $_analysisCost Altın gerekli',
              style: TextStyle(fontSize: 15, color: AppColors.textMuted),
            ),
            const SizedBox(height: 24),
            if (coinProvider.canAfford(_analysisCost))
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    final success = await coinProvider.spendCoins(
                        _analysisCost, 'analysis_$category');
                    if (success && mounted) {
                      _activityLog.logCoinSpent(_analysisCost, 'analysis_$category');
                      _loadAndShowAnalysis(category);
                    }
                  },
                  icon: const Icon(Icons.monetization_on, size: 20),
                  label: Text('Keşfet! ($_analysisCost Altın)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                ),
              )
            else
              _buildInsufficientBalance(coinProvider),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showStandardGate(String category) {
    final coinProvider = context.read<CoinProvider>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1E233F)
              : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 20),
            Text('$category Analizi', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Analizi görmek için bir seçenek seç', style: TextStyle(fontSize: 15, color: AppColors.textMuted)),
            const SizedBox(height: 24),
            if (coinProvider.canAfford(_analysisCost))
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    final success = await coinProvider.spendCoins(_analysisCost, 'analysis_$category');
                    if (success && mounted) {
                      _activityLog.logCoinSpent(_analysisCost, 'analysis_$category');
                      _loadAndShowAnalysis(category);
                    }
                  },
                  icon: const Icon(Icons.monetization_on, size: 20),
                  label: Text('Keşfet! ($_analysisCost Altın)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                ),
              )
            else
              _buildInsufficientBalance(coinProvider),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF7C3AED).withValues(alpha: 0.15),
                    width: 1.5,
                  ),
                  color: const Color(0xFFF8F5FF),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      Navigator.pop(ctx);
                      final success = await _adService.showRewardedAd(placement: 'analysis_$category');
                      if (success && mounted) _loadAndShowAnalysis(category);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.play_circle_outline_rounded, size: 20, color: Color(0xFF7C3AED)),
                          SizedBox(width: 8),
                          Text(
                            'Reklam İzle',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF7C3AED),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.push(context, CosmicBottomSheetRoute(page: const PremiumScreen()));
              },
              child: Text(
                'Üyeliğini Yükselt — Sınırsız Erişim',
                style: TextStyle(color: AppColors.accentPurple, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildInsufficientBalance(CoinProvider coinProvider) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.monetization_on, size: 18, color: Color(0xFFB45309)),
            const SizedBox(width: 6),
            Text(
              '${coinProvider.balance} / $_analysisCost Altın',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFFB45309)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text('Yetersiz bakiye', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
      ],
    );
  }

  /// Analizi yükle ve sonucu tam ekran popup olarak göster
  Future<void> _loadAndShowAnalysis(String category) async {
    final authProvider = context.read<AuthProvider>();
    final horoscopeProvider = context.read<HoroscopeProvider>();
    if (authProvider.selectedZodiac == null) return;

    setState(() {
      _isLoadingCategory = true;
      _loadingCategoryName = category;
    });

    await horoscopeProvider.fetchDetailedAnalysis(
      authProvider.selectedZodiac!,
      category,
    );

    if (!mounted) return;

    setState(() {
      _isLoadingCategory = false;
      _loadingCategoryName = null;
    });

    final analysis = horoscopeProvider.detailedAnalysis;
    if (analysis == null) return;

    _activityLog.logDetailedAnalysis(category);

    final catData = _categories.firstWhere(
      (c) => c['name'] == category,
      orElse: () => _categories[0],
    );

    // Tam ekran sonuç popup'ı aç
    if (mounted) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => _AnalysisResultSheet(
          analysis: analysis,
          category: category,
          emoji: catData['emoji'] as String,
          gradientColors: catData['gradient'] as List<Color>,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1730) : const Color(0xFFF8F5FF),
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
          AppStrings.analysisTitle,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : AppColors.textDark,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık
          Text(
            AppStrings.analysisTitle,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: isDark ? AppColors.textPrimary : AppColors.textDark,
            ),
          ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.05),
          const SizedBox(height: 6),
          Text(
            'Hayatının farklı alanlarını astrolojik olarak keşfet',
            style: TextStyle(fontSize: 15, color: AppColors.textMuted, height: 1.4),
          ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

          // Erişim bilgisi
          if (!_isElmasPlus(authProvider)) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  AppColors.accentPurple.withValues(alpha: 0.1),
                  AppColors.primaryPink.withValues(alpha: 0.1),
                ]),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.accentPurple.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: AppColors.accentPurple, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _isYildizPlus(authProvider)
                          ? 'Analiz başına $_analysisCost Altın'
                          : 'Altın veya reklam izleyerek erişebilirsin',
                      style: TextStyle(
                        color: AppColors.accentPurple,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
          ],

          const SizedBox(height: 24),

          // Kategori Kartları — 2x2 Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.05,
            children: List.generate(_categories.length, (index) {
              final cat = _categories[index];
              final name = cat['name'] as String;
              final gradientColors = cat['gradient'] as List<Color>;
              final isLoading = _isLoadingCategory && _loadingCategoryName == name;

              return _buildCategoryTile(
                name: name,
                emoji: cat['emoji'] as String,
                description: cat['description'] as String,
                gradientColors: gradientColors,
                isLoading: isLoading,
                isDark: isDark,
                index: index,
              );
            }),
          ),

          const SizedBox(height: 20),

          // Bilgi notu
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
            ),
            child: Row(
              children: [
                const Text('💡', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Her dokunuşta yeni ve güncel bir analiz alırsın. İstediğin kadar tekrarla!',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white60 : AppColors.textMuted,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 500.ms),
        ],
      ),
    ),
    );
  }

  Widget _buildCategoryTile({
    required String name,
    required String emoji,
    required String description,
    required List<Color> gradientColors,
    required bool isLoading,
    required bool isDark,
    required int index,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: isLoading ? null : () => _onCategoryTap(name),
      child: Container(
        padding: const EdgeInsets.all(16),
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
                ? gradientColors[0].withValues(alpha: 0.12)
                : gradientColors[0].withValues(alpha: 0.10),
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
                  : gradientColors[0].withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(3, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Emoji + loading
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: gradientColors),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: isLoading
                        ? const SizedBox(
                            width: 22, height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.white,
                            ),
                          )
                        : Text(emoji, style: const TextStyle(fontSize: 24)),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: gradientColors[0].withValues(alpha: 0.4),
                ),
              ],
            ),
            // Başlık + açıklama
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$name Analizi',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textPrimary : AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: Duration(milliseconds: 200 + index * 80))
        .slideY(begin: 0.05, duration: 400.ms, delay: Duration(milliseconds: 200 + index * 80));
  }
}

/// Tam ekran analiz sonuç sayfası — bottom sheet olarak açılır
class _AnalysisResultSheet extends StatelessWidget {
  final dynamic analysis;
  final String category;
  final String emoji;
  final List<Color> gradientColors;

  const _AnalysisResultSheet({
    required this.analysis,
    required this.category,
    required this.emoji,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.88,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E233F) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Handle bar
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
              child: Column(
                children: [
                  // Skor Hero kartı
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: gradientColors[0].withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(emoji, style: const TextStyle(fontSize: 48)),
                        const SizedBox(height: 8),
                        Text(
                          '$category Analizi',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          analysis.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '%${analysis.percentage}',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.95, 0.95)),

                  const SizedBox(height: 20),

                  // İçerik kartı
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : AppColors.cardLight,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: gradientColors[0].withValues(alpha: 0.12)),
                    ),
                    child: Text(
                      analysis.content,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.8,
                        color: isDark ? AppColors.textPrimary : AppColors.textDark,
                      ),
                    ),
                  ).animate().fadeIn(duration: 500.ms, delay: 200.ms).slideY(begin: 0.05),

                  const SizedBox(height: 24),

                  // Kapat butonu
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                      label: const Text('Kapat'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDark ? Colors.white70 : AppColors.textDark,
                        side: BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
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
}
