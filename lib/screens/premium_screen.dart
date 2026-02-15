import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/auth_provider.dart';
import '../constants/colors.dart';
import '../constants/strings.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  String _selectedPlan = 'monthly';

  static const Map<String, Map<String, dynamic>> _planConfig = {
    'weekly': {
      'price': '₺29,99',
      'label': 'Haftalık',
      'period': '/hafta',
      'badge': '7 Gün Dene',
    },
    'monthly': {
      'price': '₺99,99',
      'label': 'Aylık',
      'period': '/ay',
      'badge': 'Popüler',
    },
    'yearly': {
      'price': '₺799,99',
      'label': 'Yıllık',
      'period': '/yıl',
      'badge': '%33 İndirim',
      'savings': '₺400 tasarruf',
    },
  };
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selected = _planConfig[_selectedPlan]!;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back,
                      color: isDark ? AppColors.textPrimary : AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.accentPurple, AppColors.accentBlue],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accentPurple.withOpacity(0.3),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.star,
                        size: 50,
                        color: AppColors.gold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      AppStrings.premiumTitle,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: isDark ? AppColors.textPrimary : AppColors.textDark,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppStrings.premiumSubtitle,
                      style: const TextStyle(fontSize: 16, color: AppColors.textMuted),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    _buildPlanSelector(isDark),
                    const SizedBox(height: 24),
                    _FeatureItem(icon: Icons.auto_awesome, title: 'Sınırsız Günlük Yorum', subtitle: 'Her gün yeni ve detaylı burç yorumları'),
                    const SizedBox(height: 12),
                    _FeatureItem(icon: Icons.style, title: 'Tarot Falı (3 Kart)', subtitle: 'Geçmiş, şimdi ve gelecek için üçlü tarot açılımı'),
                    const SizedBox(height: 12),
                    _FeatureItem(icon: Icons.coffee, title: 'Kahve Falı Yorumu', subtitle: 'Yapay zeka destekli kahve falı analizi'),
                    const SizedBox(height: 12),
                    _FeatureItem(icon: Icons.nightlight, title: 'Rüya Tabirleri', subtitle: 'Rüyalarınızın anlamını keşfedin'),
                    const SizedBox(height: 12),
                    _FeatureItem(icon: Icons.favorite, title: 'Detaylı Uyum Analizi', subtitle: 'Burç uyumunuzu derinlemesine inceleyin'),
                    const SizedBox(height: 12),
                    _FeatureItem(icon: Icons.calendar_month, title: 'Haftalık & Aylık Yorumlar', subtitle: 'Gelecek planlaması için uzun vadeli tahminler'),
                    const SizedBox(height: 12),
                    _FeatureItem(icon: Icons.chat_bubble, title: 'Zodi ile Sohbet', subtitle: 'Astroloji asistanınızla sınırsız sohbet'),
                    const SizedBox(height: 12),
                    _FeatureItem(icon: Icons.stars, title: 'Kozmik Takvim', subtitle: 'Ay evreleri ve astrolojik olaylar'),
                    const SizedBox(height: 12),
                    _FeatureItem(icon: Icons.person, title: 'Kişisel Profil Kartı', subtitle: 'Detaylı astrolojik profil ve paylaşım'),
                    const SizedBox(height: 12),
                    _FeatureItem(icon: Icons.share, title: 'Tüm Paylaşım Kartları', subtitle: 'Profesyonel tasarım kartlarını paylaş'),
                    const SizedBox(height: 12),
                    _FeatureItem(icon: Icons.block, title: 'Reklamsız Deneyim', subtitle: 'Hiç reklam görmeden kullan'),
                    const SizedBox(height: 12),
                    _FeatureItem(icon: Icons.update, title: 'Öncelikli Güncellemeler', subtitle: 'Yeni özelliklere ilk erişim'),
                    const SizedBox(height: 40),
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
                          Text(
                            selected['price']!,
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              color: AppColors.gold,
                            ),
                          ),
                          Text(
                            selected['label']!,
                            style: const TextStyle(fontSize: 16, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await context.read<AuthProvider>().upgradeToPremium(subscriptionType: _selectedPlan);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Premium (${selected['label']}) üyeliğin aktif edildi! 🎉'),
                          backgroundColor: AppColors.positive,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text(
                    AppStrings.premiumButton,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanSelector(bool isDark) {
    return Row(
      children: [
        _buildPlanChip('weekly', 'Haftalık', isDark),
        const SizedBox(width: 8),
        _buildPlanChip('monthly', 'Aylık', isDark),
        const SizedBox(width: 8),
        _buildPlanChip('yearly', 'Yıllık', isDark),
      ],
    );
  }

  Widget _buildPlanChip(String value, String label, bool isDark) {
    final selected = _selectedPlan == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPlan = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.accentPurple.withOpacity(0.2)
                : (isDark ? AppColors.cardDark : AppColors.cardLight),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.accentPurple : AppColors.textMuted.withOpacity(0.3),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: selected ? FontWeight.bold : FontWeight.w500,
              color: selected ? AppColors.accentPurple : (isDark ? AppColors.textPrimary : AppColors.textDark),
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;

  const _FeatureItem({required this.icon, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isDark ? AppColors.textPrimary : AppColors.textDark).withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.accentPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.accentPurple, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textPrimary : AppColors.textDark,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Icon(Icons.check_circle, color: AppColors.positive, size: 24),
        ],
      ),
    );
  }
}
