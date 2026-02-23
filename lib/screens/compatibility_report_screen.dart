import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../constants/colors.dart';
import '../models/zodiac_sign.dart';
import '../providers/auth_provider.dart';
import '../config/membership_config.dart';
import '../services/gemini_service.dart';
import '../services/ad_service.dart';
import '../services/share_service.dart';
import '../widgets/share_cards/compatibility_share_card.dart';
import 'premium_screen.dart';
import '../theme/cosmic_page_route.dart';
import '../widgets/sticky_bottom_actions.dart';

class CompatibilityReportScreen extends StatefulWidget {
  final ZodiacSign userSign;
  final ZodiacSign partnerSign;

  const CompatibilityReportScreen({
    super.key,
    required this.userSign,
    required this.partnerSign,
  });

  @override
  State<CompatibilityReportScreen> createState() =>
      _CompatibilityReportScreenState();
}

class _CompatibilityReportScreenState extends State<CompatibilityReportScreen> {
  final _geminiService = GeminiService();
  final _adService = AdService();
  Map<String, dynamic>? _report;
  bool _isLoading = true;
  bool _hasAccess = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAccessAndLoad();
    });
  }

  void _checkAccessAndLoad() {
    final authProvider = context.read<AuthProvider>();
    // Sadece Elmas ve üstü üyelikler erişebilir
    if (authProvider.membershipTier.index >= MembershipTier.elmas.index) {
      setState(() => _hasAccess = true);
      _loadReport();
    } else {
      setState(() {
        _hasAccess = false;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadReport() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final prompt = '''
Sen Zodi'sin - Astroloji dünyasının en dürüst rehberi.

${widget.userSign.displayName} ve ${widget.partnerSign.displayName} burçları arasında DETAYLI uyum raporu hazırla.

Yanıtı aşağıdaki JSON formatında ver:
{
  "overallScore": 0-100 arası genel uyum puanı,
  "loveScore": 0-100 arası aşk uyumu,
  "communicationScore": 0-100 arası iletişim uyumu,
  "trustScore": 0-100 arası güven uyumu,
  "sexualScore": 0-100 arası cinsel uyum,
  "friendshipScore": 0-100 arası arkadaşlık uyumu,
  "overallAnalysis": "Genel uyum analizi (2-3 paragraf, detaylı ve dürüst)",
  "loveAnalysis": "Aşk ve romantizm analizi (1-2 paragraf)",
  "communicationAnalysis": "İletişim tarzları analizi (1-2 paragraf)",
  "conflictAnalysis": "Çatışma noktaları ve çözüm önerileri (1-2 paragraf)",
  "sexualAnalysis": "Cinsel uyum ve çekim analizi (1 paragraf)",
  "strengths": ["Bu ilişkinin 4-5 güçlü yönü"],
  "challenges": ["Bu ilişkinin 3-4 zorlu noktası"],
  "advice": "Zodi'den bu çift için 2-3 paragraf tavsiye",
  "famousCouples": ["Bu burç kombinasyonuna sahip 2-3 ünlü çift"],
  "compatibility_emoji": "İlişkiyi en iyi anlatan tek emoji"
}
''';

      final response = await _geminiService.generateTarotInterpretation(prompt);

      Map<String, dynamic> result;
      try {
        result = jsonDecode(response) as Map<String, dynamic>;
      } catch (_) {
        final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(response);
        if (jsonMatch != null) {
          result = jsonDecode(jsonMatch.group(0)!) as Map<String, dynamic>;
        } else {
          throw Exception('JSON parse hatası');
        }
      }

      // Reklam göster (detaylı rapor sonrası)
      _adService.trackScreenNavigation();
      _adService.showInterstitialIfNeeded();

      setState(() {
        _report = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Rapor oluşturulurken bir sorun oluştu. Tekrar dene!';
        _isLoading = false;
      });
    }
  }

  void _shareReport() {
    if (_report == null) return;

    final card = CompatibilityShareCard(
      sign1Symbol: widget.userSign.symbol,
      sign1Name: widget.userSign.displayName,
      sign2Symbol: widget.partnerSign.symbol,
      sign2Name: widget.partnerSign.displayName,
      overallScore: _report!['overallScore'] ?? 0,
      loveScore: _report!['loveScore'] ?? 0,
      communicationScore: _report!['communicationScore'] ?? 0,
      trustScore: _report!['trustScore'] ?? 0,
      summary: _report!['overallAnalysis'] ?? '',
    );

    ShareService().shareCardWidget(
      context,
      card,
      text: '${widget.userSign.symbol} & ${widget.partnerSign.symbol} Uyum Raporu — Astro Dozi\n#AstroDozi #BurcUyumu',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5FF),
      bottomNavigationBar: (_report != null && !_isLoading && _hasAccess)
          ? StickyBottomActions(
              children: [
                StickyBottomActions.primaryButton(
                  label: 'Raporu Paylaş',
                  icon: Icons.share_rounded,
                  gradient: [AppColors.accentPurple, const Color(0xFFFF1493)],
                  onTap: _shareReport,
                ),
              ],
            )
          : null,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE8D5F5), Color(0xFFF0E6FF), Color(0xFFE0D0F0)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(isDark),
              Expanded(
                child: !_hasAccess
                    ? _buildAccessGate(isDark)
                    : _isLoading
                        ? _buildLoading(isDark)
                        : _error != null
                            ? _buildError(isDark)
                            : _buildReport(isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back,
                color: isDark ? Colors.white : AppColors.textDark),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              'Detaylı Uyum Raporu',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textDark,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: Icon(Icons.share,
                color: isDark ? Colors.white : AppColors.textDark),
            onPressed: _report != null ? _shareReport : null,
          ),
        ],
      ),
    );
  }

  Widget _buildAccessGate(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(widget.userSign.symbol, style: const TextStyle(fontSize: 48)),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: AppColors.cosmicGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.diamond, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 16),
                Text(widget.partnerSign.symbol, style: const TextStyle(fontSize: 48)),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Detaylı Uyum Raporu',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.gold,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'ELMAS+ ÖZELLİĞİ',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Bu detaylı rapor Elmas ve üstü üyeliklere özeldir.\nAşk, iletişim, güven ve daha fazlasını keşfet!',
              style: TextStyle(
                fontSize: 15,
                color: isDark ? Colors.white70 : AppColors.textMuted,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // Üyeliğini Yükselt butonu
            SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppColors.cosmicGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentPurple.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.push(
                      context,
                      CosmicBottomSheetRoute(page: const PremiumScreen()),
                    ),
                    borderRadius: BorderRadius.circular(16),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.diamond, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Üyeliğini Yükselt',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Geri Dön',
                style: TextStyle(
                  color: isDark ? Colors.white54 : AppColors.textMuted,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(widget.userSign.symbol,
                  style: const TextStyle(fontSize: 48)),
              const SizedBox(width: 16),
              const Icon(Icons.favorite, color: AppColors.gold, size: 32)
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2), duration: 800.ms),
              const SizedBox(width: 16),
              Text(widget.partnerSign.symbol,
                  style: const TextStyle(fontSize: 48)),
            ],
          ),
          const SizedBox(height: 24),
          const CircularProgressIndicator(color: AppColors.accentPurple),
          const SizedBox(height: 16),
          Text(
            'Detaylı rapor hazırlanıyor...',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white70 : AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          ...[
            'Gezegenler analiz ediliyor',
            'Elementler karşılaştırılıyor',
            'Uyum hesaplanıyor',
          ]
              .asMap()
              .entries
              .map((e) => Text(
                    '${e.value}...',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white38 : AppColors.textMuted,
                    ),
                  )
                      .animate(delay: Duration(milliseconds: e.key * 600))
                      .fadeIn()),
        ],
      ),
    );
  }

  Widget _buildError(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('😞', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            _error!,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white70 : AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadReport,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentPurple,
              foregroundColor: Colors.white,
            ),
            child: const Text('Tekrar Dene'),
          ),
        ],
      ),
    );
  }

  Widget _buildReport(bool isDark) {
    if (_report == null) return const SizedBox();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık kartı
          _buildHeaderCard(isDark),

          const SizedBox(height: 20),

          // Skor kartları
          _buildScoreGrid(isDark),

          const SizedBox(height: 20),

          // Detaylı analizler
          _buildAnalysisCard(
            '💕', 'Aşk & Romantizm',
            _report!['loveAnalysis'] ?? '',
            const [Color(0xFFF472B6), Color(0xFFBE185D)],
          ),
          const SizedBox(height: 12),
          _buildAnalysisCard(
            '💬', 'İletişim',
            _report!['communicationAnalysis'] ?? '',
            const [Color(0xFF38BDF8), Color(0xFF3B82F6)],
          ),
          const SizedBox(height: 12),
          _buildAnalysisCard(
            '🔥', 'Cinsel Uyum',
            _report!['sexualAnalysis'] ?? '',
            const [Color(0xFFFF4500), Color(0xFFFF8C00)],
          ),
          const SizedBox(height: 12),
          _buildAnalysisCard(
            '⚡', 'Çatışma & Çözüm',
            _report!['conflictAnalysis'] ?? '',
            const [Color(0xFFA78BFA), Color(0xFF7C3AED)],
          ),

          const SizedBox(height: 20),

          // Güçlü yönler
          _buildListSection(
            '💪', 'Güçlü Yönler',
            (_report!['strengths'] as List<dynamic>?)?.cast<String>() ?? [],
            AppColors.positive,
            isDark,
          ),

          const SizedBox(height: 16),

          // Zorluklar
          _buildListSection(
            '⚠️', 'Zorluklar',
            (_report!['challenges'] as List<dynamic>?)?.cast<String>() ?? [],
            AppColors.warning,
            isDark,
          ),

          const SizedBox(height: 20),

          // Tavsiyeler
          _buildAdviceCard(isDark),

          // Ünlü çiftler
          if (_report!['famousCouples'] != null) ...[
            const SizedBox(height: 16),
            _buildFamousCouplesCard(isDark),
          ],

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(bool isDark) {
    final emoji = _report!['compatibility_emoji'] ?? '💫';
    final score = _report!['overallScore'] ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.accentPurple, Color(0xFFFF1493)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentPurple.withOpacity(0.3),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(widget.userSign.symbol,
                  style: const TextStyle(fontSize: 40)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(emoji, style: const TextStyle(fontSize: 32)),
              ),
              Text(widget.partnerSign.symbol,
                  style: const TextStyle(fontSize: 40)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${widget.userSign.displayName} & ${widget.partnerSign.displayName}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '%$score',
            style: const TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.w900,
              color: AppColors.gold,
            ),
          ),
          const Text(
            'Genel Uyum',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.2);
  }

  Widget _buildScoreGrid(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildMiniScore(
            '💕', 'Aşk', _report!['loveScore'] ?? 0, isDark),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMiniScore(
            '💬', 'İletişim', _report!['communicationScore'] ?? 0, isDark),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMiniScore(
            '🤝', 'Güven', _report!['trustScore'] ?? 0, isDark),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMiniScore(
            '🔥', 'Çekim', _report!['sexualScore'] ?? 0, isDark),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMiniScore(
            '👫', 'Dostluk', _report!['friendshipScore'] ?? 0, isDark),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildMiniScore(String emoji, String label, int score, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.08)
            : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 4),
          Text(
            '%$score',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textDark,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? Colors.white54 : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisCard(
    String emoji, String title, String content, List<Color> colors,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.95),
              height: 1.5,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1);
  }

  Widget _buildListSection(
    String emoji, String title, List<String> items, Color color, bool isDark,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.08)
            : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '•',
                      style: TextStyle(
                        fontSize: 16,
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: isDark ? Colors.white : AppColors.textDark,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildAdviceCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFF59E0B)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('💡', style: TextStyle(fontSize: 20)),
              SizedBox(width: 8),
              Text(
                'Astro Dozi\'den Tavsiye',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _report!['advice'] ?? '',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.95),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFamousCouplesCard(bool isDark) {
    final couples =
        (_report!['famousCouples'] as List<dynamic>?)?.cast<String>() ?? [];
    if (couples.isEmpty) return const SizedBox();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.08)
            : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🌟', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                'Ünlü Çiftler',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...couples.map((c) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  '⭐ $c',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white : AppColors.textDark,
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
