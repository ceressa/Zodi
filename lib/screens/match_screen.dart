import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/horoscope_provider.dart';
import '../models/zodiac_sign.dart';
import '../constants/colors.dart';
import '../constants/strings.dart';
import '../services/firebase_service.dart';
import 'compatibility_report_screen.dart';

class MatchScreen extends StatefulWidget {
  const MatchScreen({super.key});

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  ZodiacSign? _selectedPartner;

  Future<void> _loadCompatibility() async {
    final authProvider = context.read<AuthProvider>();
    final horoscopeProvider = context.read<HoroscopeProvider>();
    
    if (authProvider.selectedZodiac != null && _selectedPartner != null) {
      await horoscopeProvider.fetchCompatibility(
        authProvider.selectedZodiac!,
        _selectedPartner!,
      );
      
      // Zengin profil güncellemeleri
      if (_firebaseService.isAuthenticated) {
        // 1. Özellik kullanımını artır
        _firebaseService.incrementFeatureUsage('compatibility');
        
        // 2. Favori uyumluluğu kaydet (ilk 3 kontrol otomatik favorilere eklenir)
        final compatibilityKey = '${authProvider.selectedZodiac!.name}_${_selectedPartner!.name}';
        // İlk kontrolde favorilere ekle
        _firebaseService.toggleFavoriteCompatibility(compatibilityKey);
        
        // 3. Partner burç bilgisini güncelle (en son kontrol edilen)
        _firebaseService.updateRelationshipInfo(
          partnerZodiacSign: _selectedPartner!.name,
        );
        
        // 4. Okuma desenlerini güncelle
        _firebaseService.updateReadingPatterns('compatibility', 30); // Ortalama 30 saniye
        
        // 5. Favori konuları güncelle
        _firebaseService.updateFavoriteTopics('compatibility');
        
        // 6. Analytics event
        _firebaseService.logCompatibilityCheck(
          authProvider.selectedZodiac!.name,
          _selectedPartner!.name,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = context.watch<AuthProvider>();
    final horoscopeProvider = context.watch<HoroscopeProvider>();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User's Zodiac Header
          if (authProvider.selectedZodiac != null) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.accentPurple.withOpacity(0.2),
                    AppColors.primaryPink.withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primaryPink.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.accentPurple, AppColors.primaryPink],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryPink.withOpacity(0.3),
                          blurRadius: 12,
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
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          authProvider.selectedZodiac!.displayName,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.textPrimary : AppColors.textDark,
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
          
          Text(
            AppStrings.matchTitle,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: isDark ? AppColors.textPrimary : AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hangi burçla uyumunu öğrenmek istersin?',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 24),
          
          // Partner Selection
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: ZodiacSign.values.map((sign) {
              final isSelected = _selectedPartner == sign;
              final isUserSign = authProvider.selectedZodiac == sign;
              
              return InkWell(
                onTap: isUserSign ? null : () {
                  setState(() => _selectedPartner = sign);
                  _loadCompatibility();
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: (MediaQuery.of(context).size.width - 72) / 3,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.accentPurple
                        : (isDark ? AppColors.cardDark : AppColors.cardLight),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isUserSign
                          ? AppColors.textMuted.withOpacity(0.3)
                          : (isSelected ? AppColors.accentPurple : AppColors.borderLight),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        sign.symbol,
                        style: TextStyle(
                          fontSize: 32,
                          color: isUserSign
                              ? AppColors.textMuted
                              : (isSelected ? Colors.white : AppColors.accentBlue),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        sign.displayName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isUserSign
                              ? AppColors.textMuted
                              : (isSelected ? Colors.white : (isDark ? AppColors.textPrimary : AppColors.textDark)),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          
          if (horoscopeProvider.isLoadingCompatibility) ...[
            const SizedBox(height: 32),
            const Center(
              child: CircularProgressIndicator(color: AppColors.accentPurple),
            ),
          ] else if (horoscopeProvider.compatibilityResult != null && _selectedPartner != null) ...[
            const SizedBox(height: 32),
            
            // Score
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.accentPurple, AppColors.accentBlue],
                ),
                borderRadius: BorderRadius.circular(20),
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
                      const Icon(Icons.favorite, color: AppColors.gold, size: 32),
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
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '%${horoscopeProvider.compatibilityResult!.score}',
                    style: const TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.w900,
                      color: AppColors.gold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Aspects
            Row(
              children: [
                Expanded(
                  child: _AspectCard(
                    label: AppStrings.matchLove,
                    value: horoscopeProvider.compatibilityResult!.aspects.love,
                    icon: Icons.favorite,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _AspectCard(
                    label: AppStrings.matchCommunication,
                    value: horoscopeProvider.compatibilityResult!.aspects.communication,
                    icon: Icons.chat_bubble_outline,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _AspectCard(
                    label: AppStrings.matchTrust,
                    value: horoscopeProvider.compatibilityResult!.aspects.trust,
                    icon: Icons.verified_user,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Summary
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.cardLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                horoscopeProvider.compatibilityResult!.summary,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: isDark ? AppColors.textPrimary : AppColors.textDark,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Detaylı Rapor Butonu
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: AppColors.cosmicGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CompatibilityReportScreen(
                        userSign: authProvider.selectedZodiac!,
                        partnerSign: _selectedPartner!,
                      ),
                    ),
                  ),
                  borderRadius: BorderRadius.circular(20),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.description, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Detaylı Uyum Raporu Al',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 4),
                        Text(
                          '✨',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 60),
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 60,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Bir burç seç ve uyumunuzu öğren',
                    style: TextStyle(
                      color: AppColors.textMuted,
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
  }
}

class _AspectCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;

  const _AspectCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.accentBlue, size: 20),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            '%$value',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimary : AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
