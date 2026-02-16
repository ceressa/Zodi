import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/auth_provider.dart';
import '../providers/horoscope_provider.dart';
import '../constants/colors.dart';
import '../widgets/animated_card.dart';
import '../services/firebase_service.dart';
import '../services/ad_service.dart';
import '../screens/premium_screen.dart';
import '../theme/cosmic_page_route.dart';

class DreamScreen extends StatefulWidget {
  const DreamScreen({super.key});

  @override
  State<DreamScreen> createState() => _DreamScreenState();
}

class _DreamScreenState extends State<DreamScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final AdService _adService = AdService();
  final _dreamController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _dreamController.dispose();
    super.dispose();
  }

  Future<void> _interpretDream() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    
    // Premium kontrolü
    if (!authProvider.isPremium) {
      final unlocked = await _adService.showRewardedAd(placement: 'dream_interpretation');
      if (!unlocked) {
        if (mounted) {
          _showPremiumDialog();
        }
        return;
      }
    }

    final horoscopeProvider = context.read<HoroscopeProvider>();
    await horoscopeProvider.interpretDream(_dreamController.text);
    
    // Zengin profil güncellemeleri
    if (_firebaseService.isAuthenticated && horoscopeProvider.dreamInterpretation != null) {
      // 1. Özellik kullanımını artır
      _firebaseService.incrementFeatureUsage('dream_interpretation');
      
      // 2. Rüya yorumunu kaydet (ID olarak timestamp kullan)
      final dreamId = DateTime.now().millisecondsSinceEpoch.toString();
      _firebaseService.saveDreamInterpretation(dreamId);
      
      // 3. Okuma desenlerini güncelle
      _firebaseService.updateReadingPatterns('dream', 45); // Ortalama 45 saniye
      
      // 4. Favori konuları güncelle
      _firebaseService.updateFavoriteTopics('dream_interpretation');
      
      // 5. Son aramaya ekle
      final dreamPreview = _dreamController.text.length > 50 
          ? '${_dreamController.text.substring(0, 50)}...' 
          : _dreamController.text;
      _firebaseService.addRecentSearch('Rüya: $dreamPreview');
      
      // 6. Analytics event
      _firebaseService.logDreamInterpretation();
    }
  }

  void _showPremiumDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Premium Özellik'),
        content: const Text('Rüya tabiri premium kullanıcılar için özel bir özelliktir. Reklam izleyerek veya premium üyelikle erişebilirsin.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
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

  Color _getMoodColor(String mood) {
    switch (mood.toLowerCase()) {
      case 'positive':
        return AppColors.positive;
      case 'negative':
        return AppColors.negative;
      case 'mixed':
        return AppColors.warning;
      default:
        return AppColors.accentBlue;
    }
  }

  IconData _getMoodIcon(String mood) {
    switch (mood.toLowerCase()) {
      case 'positive':
        return Icons.sentiment_very_satisfied;
      case 'negative':
        return Icons.sentiment_dissatisfied;
      case 'mixed':
        return Icons.sentiment_neutral;
      default:
        return Icons.sentiment_satisfied;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final horoscopeProvider = context.watch<HoroscopeProvider>();
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [AppColors.bgDark, AppColors.cardDark]
                : [AppColors.bgLight, AppColors.surfaceLight],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back,
                        color: isDark ? AppColors.textPrimary : AppColors.textDark,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Rüya Yorumu',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: isDark ? AppColors.textPrimary : AppColors.textDark,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text('🌙', style: TextStyle(fontSize: 24)),
                            ],
                          ),
                          Text(
                            'Rüyanı anlat, Zodi yorumlasın',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? AppColors.textSecondary : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Dream Input Form
                AnimatedCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rüyanı Anlat',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.textPrimary : AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _dreamController,
                          maxLines: 8,
                          decoration: InputDecoration(
                            hintText: 'Rüyanda ne gördün? Detaylı anlat...\n\nÖrnek: Uçuyordum, sonra denize düştüm...',
                            hintStyle: TextStyle(
                              color: AppColors.textMuted.withOpacity(0.5),
                            ),
                            filled: true,
                            fillColor: (isDark ? AppColors.textPrimary : AppColors.textDark).withOpacity(0.05),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: (isDark ? AppColors.textPrimary : AppColors.textDark).withOpacity(0.1),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: (isDark ? AppColors.textPrimary : AppColors.textDark).withOpacity(0.1),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.accentPurple, width: 2),
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
                        const SizedBox(height: 20),
                        
                        // Interpret Button
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.accentPurple,
                                AppColors.accentBlue,
                                AppColors.accentPink,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: horoscopeProvider.isLoadingDream ? null : _interpretDream,
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: horoscopeProvider.isLoadingDream
                                    ? const Center(
                                        child: SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      )
                                    : const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.psychology, color: Colors.white, size: 20),
                                          SizedBox(width: 8),
                                          Text(
                                            'Yorumla',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Results
                if (horoscopeProvider.dreamInterpretation != null) ...[
                  const SizedBox(height: 24),
                  
                  // Mood Badge
                  AnimatedCard(
                    delay: 100.ms,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _getMoodColor(horoscopeProvider.dreamInterpretation!.mood).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getMoodIcon(horoscopeProvider.dreamInterpretation!.mood),
                            color: _getMoodColor(horoscopeProvider.dreamInterpretation!.mood),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Rüya Havası',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? AppColors.textSecondary : AppColors.textMuted,
                                ),
                              ),
                              Text(
                                horoscopeProvider.dreamInterpretation!.mood.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: _getMoodColor(horoscopeProvider.dreamInterpretation!.mood),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Keywords
                  if (horoscopeProvider.dreamInterpretation!.keywords.isNotEmpty)
                    AnimatedCard(
                      delay: 150.ms,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.label, color: AppColors.accentPurple, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Anahtar Kelimeler',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppColors.textPrimary : AppColors.textDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: horoscopeProvider.dreamInterpretation!.keywords.map((keyword) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  gradient: AppColors.purpleGradient,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  keyword,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  
                  const SizedBox(height: 16),
                  
                  // Main Interpretation
                  AnimatedCard(
                    delay: 200.ms,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.auto_stories, color: AppColors.accentBlue, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Yorum',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.textPrimary : AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          horoscopeProvider.dreamInterpretation!.interpretation,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.6,
                            color: isDark ? AppColors.textSecondary : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Symbolism
                  AnimatedCard(
                    delay: 300.ms,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.psychology_alt, color: AppColors.accentPink, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Sembolizm',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.textPrimary : AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          horoscopeProvider.dreamInterpretation!.symbolism,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.6,
                            color: isDark ? AppColors.textSecondary : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Emotional Meaning
                  AnimatedCard(
                    delay: 400.ms,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.favorite, color: AppColors.gold, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Duygusal Anlam',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.textPrimary : AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          horoscopeProvider.dreamInterpretation!.emotionalMeaning,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.6,
                            color: isDark ? AppColors.textSecondary : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Advice
                  AnimatedCard(
                    delay: 500.ms,
                    gradient: AppColors.goldGradient,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.lightbulb, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Zodi\'den Tavsiye',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          horoscopeProvider.dreamInterpretation!.advice,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.6,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
