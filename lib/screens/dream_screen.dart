import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/auth_provider.dart';
import '../providers/horoscope_provider.dart';
import '../theme/app_colors.dart';
import '../services/firebase_service.dart';
import '../services/ad_service.dart';
import '../services/activity_log_service.dart';
import '../services/share_service.dart';
import '../screens/premium_screen.dart';
import '../theme/cosmic_page_route.dart';
import '../widgets/share_cards/dream_share_card.dart';
import '../widgets/sticky_bottom_actions.dart';

class DreamScreen extends StatefulWidget {
  const DreamScreen({super.key});

  @override
  State<DreamScreen> createState() => _DreamScreenState();
}

class _DreamScreenState extends State<DreamScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final AdService _adService = AdService();
  final ActivityLogService _activityLog = ActivityLogService();
  final _dreamController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _dreamController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _interpretDream() async {
    if (!_formKey.currentState!.validate()) return;

    // Klavyeyi kapat
    FocusScope.of(context).unfocus();

    final authProvider = context.read<AuthProvider>();

    // Premium kontrolü
    if (!authProvider.isPremium) {
      final unlocked =
          await _adService.showRewardedAd(placement: 'dream_interpretation');
      if (!unlocked) {
        if (mounted) _showPremiumDialog();
        return;
      }
    }

    final horoscopeProvider = context.read<HoroscopeProvider>();
    await horoscopeProvider.interpretDream(_dreamController.text);

    if (horoscopeProvider.dreamInterpretation != null) {
      await _activityLog.logDreamInterpretation(_dreamController.text);

      // Sonuca scroll et
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
          );
        }
      });
    }

    // Zengin profil güncellemeleri
    if (_firebaseService.isAuthenticated &&
        horoscopeProvider.dreamInterpretation != null) {
      _firebaseService.incrementFeatureUsage('dream_interpretation');
      final dreamId = DateTime.now().millisecondsSinceEpoch.toString();
      _firebaseService.saveDreamInterpretation(dreamId);
      _firebaseService.updateReadingPatterns('dream', 45);
      _firebaseService.updateFavoriteTopics('dream_interpretation');
      final dreamPreview = _dreamController.text.length > 50
          ? '${_dreamController.text.substring(0, 50)}...'
          : _dreamController.text;
      _firebaseService.addRecentSearch('Rüya: $dreamPreview');
      _firebaseService.logDreamInterpretation();
    }
  }

  void _showPremiumDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Text('💎', style: TextStyle(fontSize: 24)),
            SizedBox(width: 8),
            Text('Premium Özellik'),
          ],
        ),
        content: const Text(
          'Rüya tabiri premium kullanıcılara özel. Reklam izleyerek veya premium üyelikle erişebilirsin.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tamam'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.purple500,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                CosmicBottomSheetRoute(page: const PremiumScreen()),
              );
            },
            child: const Text('Premium\'a Geç'),
          ),
        ],
      ),
    );
  }

  String _moodLabel(String mood) {
    switch (mood.toLowerCase()) {
      case 'positive':
        return 'Olumlu';
      case 'negative':
        return 'Olumsuz';
      case 'mixed':
        return 'Karışık';
      default:
        return mood;
    }
  }

  Color _moodColor(String mood) {
    switch (mood.toLowerCase()) {
      case 'positive':
        return const Color(0xFF10B981);
      case 'negative':
        return const Color(0xFFEF4444);
      case 'mixed':
        return const Color(0xFFF59E0B);
      default:
        return AppColors.purple500;
    }
  }

  IconData _moodIcon(String mood) {
    switch (mood.toLowerCase()) {
      case 'positive':
        return Icons.sentiment_very_satisfied_rounded;
      case 'negative':
        return Icons.sentiment_dissatisfied_rounded;
      case 'mixed':
        return Icons.sentiment_neutral_rounded;
      default:
        return Icons.sentiment_satisfied_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final horoscopeProvider = context.watch<HoroscopeProvider>();
    final dream = horoscopeProvider.dreamInterpretation;
    final isLoading = horoscopeProvider.isLoadingDream;

    return Scaffold(
      backgroundColor: AppColors.purple50,
      bottomNavigationBar: (!isLoading && dream != null)
          ? StickyBottomActions(
              children: [
                StickyBottomActions.primaryButton(
                  label: 'Rüya Yorumunu Paylaş',
                  icon: Icons.share_rounded,
                  gradient: const [Color(0xFF6366F1), Color(0xFF818CF8)],
                  onTap: () => _shareDream(dream),
                ),
              ],
            )
          : null,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // ─── App Bar ───
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: AppColors.purple50,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child:
                    Icon(Icons.arrow_back, color: AppColors.purple700, size: 20),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF312E81), Color(0xFF4C1D95)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(60, 16, 24, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            const Text('🌙',
                                style: TextStyle(fontSize: 28)),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'Rüya Yorumu',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Rüyanı anlat, yıldızlar yorumlasın',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ─── Body ───
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ─── Input Card ───
                _buildInputCard(isLoading),

                // ─── Loading State ───
                if (isLoading) ...[
                  const SizedBox(height: 24),
                  _buildLoadingState(),
                ],

                // ─── Results ───
                if (!isLoading && dream != null) ...[
                  const SizedBox(height: 24),
                  _buildMoodBadge(dream.mood),
                  const SizedBox(height: 14),
                  _buildKeywords(dream.keywords),
                  const SizedBox(height: 14),
                  _buildSection(
                    '📖',
                    'Yorum',
                    dream.interpretation,
                    AppColors.purple500,
                    0,
                  ),
                  const SizedBox(height: 14),
                  _buildSection(
                    '🔮',
                    'Sembolizm',
                    dream.symbolism,
                    const Color(0xFF6366F1),
                    100,
                  ),
                  const SizedBox(height: 14),
                  _buildSection(
                    '💜',
                    'Duygusal Anlam',
                    dream.emotionalMeaning,
                    const Color(0xFFEC4899),
                    200,
                  ),
                  const SizedBox(height: 14),
                  _buildAdviceCard(dream.advice),
                  const SizedBox(height: 24),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Input Card ───────────────────────────────────────

  Widget _buildInputCard(bool isLoading) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.purple100),
        boxShadow: [
          BoxShadow(
            color: AppColors.purple200.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('✍️', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(
                  'Rüyanı Anlat',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.purple800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _dreamController,
              maxLines: 6,
              style: const TextStyle(fontSize: 15, height: 1.5),
              decoration: InputDecoration(
                hintText:
                    'Rüyanda ne gördün? Detaylı anlat...\n\nÖrneğin: Yüksek bir dağın tepesinde duruyordum, gökyüzünde yıldızlar çok parlaktı...',
                hintStyle: TextStyle(
                  color: AppColors.purple300.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
                filled: true,
                fillColor: AppColors.purple50,
                contentPadding: const EdgeInsets.all(16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide:
                      const BorderSide(color: AppColors.purple400, width: 1.5),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Rüyanı anlatmalısın';
                }
                if (value.length < 20) {
                  return 'Biraz daha detaylı anlat (en az 20 karakter)';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Interpret Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isLoading ? null : _interpretDream,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4C1D95),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      AppColors.purple300.withValues(alpha: 0.5),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.auto_awesome, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Rüyamı Yorumla',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05);
  }

  // ─── Loading ──────────────────────────────────────────

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          const Text('🌙', style: TextStyle(fontSize: 48))
              .animate(onPlay: (c) => c.repeat())
              .shimmer(duration: 1500.ms)
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.15, 1.15),
                duration: 800.ms,
              )
              .then()
              .scale(
                begin: const Offset(1.15, 1.15),
                end: const Offset(1, 1),
                duration: 800.ms,
              ),
          const SizedBox(height: 20),
          Text(
            'Rüyanın derinliklerine dalıyoruz...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.purple700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Semboller çözümleniyor',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.purple400,
            ),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  // ─── Mood Badge ───────────────────────────────────────

  Widget _buildMoodBadge(String mood) {
    final color = _moodColor(mood);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_moodIcon(mood), color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rüya Enerjisi',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.purple400,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _moodLabel(mood),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 50.ms)
        .slideX(begin: -0.05);
  }

  // ─── Keywords ─────────────────────────────────────────

  Widget _buildKeywords(List<String> keywords) {
    if (keywords.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: keywords.asMap().entries.map((entry) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF7C3AED), Color(0xFF6366F1)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7C3AED).withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            entry.value,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        )
            .animate()
            .fadeIn(delay: (100 + entry.key * 60).ms)
            .scale(begin: const Offset(0.8, 0.8));
      }).toList(),
    );
  }

  // ─── Section Card ─────────────────────────────────────

  Widget _buildSection(
      String emoji, String title, String content, Color accent, int delayMs) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.15)),
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
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 14.5,
              height: 1.65,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: delayMs))
        .slideY(begin: 0.05);
  }

  // ─── Advice Card ──────────────────────────────────────

  Widget _buildAdviceCard(String advice) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4C1D95), Color(0xFF7C3AED)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4C1D95).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
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
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            advice,
            style: TextStyle(
              fontSize: 14.5,
              height: 1.65,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 300.ms)
        .slideY(begin: 0.05);
  }

  Widget _buildShareButton(dynamic dream) {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF818CF8)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _shareDream(dream),
          borderRadius: BorderRadius.circular(16),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.share_rounded, size: 18, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Rüya Yorumunu Paylaş',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 400.ms);
  }

  Future<void> _shareDream(dynamic dream) async {
    final authProvider = context.read<AuthProvider>();
    final zodiac = authProvider.selectedZodiac;

    final card = DreamShareCard(
      dreamText: _dreamController.text,
      mood: dream.mood,
      keywords: List<String>.from(dream.keywords ?? []),
      interpretation: dream.interpretation,
      symbolism: dream.symbolism,
      advice: dream.advice,
      zodiacSymbol: zodiac?.symbol,
      zodiacName: zodiac?.displayName,
    );

    await ShareService().shareCardWidget(
      context,
      card,
      text: '🌙 Rüya Yorumum — Astro Dozi\n#AstroDozi #RüyaYorumu',
    );
  }
}
