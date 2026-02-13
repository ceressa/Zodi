import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../widgets/zodi_character.dart';
import '../providers/auth_provider.dart';
import '../screens/daily_screen.dart';
import '../screens/analysis_screen.dart';
import '../screens/match_screen.dart';

class DailyCommentPage extends StatelessWidget {
  const DailyCommentPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 8),
          
          // Selamlama kartı
          _greetingCard(authProvider),
          
          const SizedBox(height: 16),
          
          // Hero kartı
          _heroCard(context),
          
          const SizedBox(height: 16),
          
          // Üçlü bilgi kartları
          _infoRow(),
          
          const SizedBox(height: 16),
          
          // Hızlı Başla Başlığı
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'HIZLI BAŞLA',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.gray600,
                letterSpacing: 1.2,
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Detaylı Analiz ve Burç Uyumu
          Row(
            children: [
              Expanded(
                child: _quickActionCard(
                  context,
                  title: 'Detaylı\nAnaliz',
                  icon: Icons.pie_chart_rounded,
                  colors: [AppColors.pink400, AppColors.rose400],
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AnalysisScreen()),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _quickActionCard(
                  context,
                  title: 'Burç\nUyumu',
                  icon: Icons.favorite_rounded,
                  colors: [AppColors.cyan400, AppColors.blue400],
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MatchScreen()),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 100),
        ],
      ),
    );
  }
  
  Widget _greetingCard(AuthProvider authProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.purple200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [AppColors.violet400, AppColors.fuchsia400],
              ),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Günaydın! 🌤',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.purple600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                authProvider.userName?.split(' ').first ?? 'Kullanıcı',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.purple800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _heroCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE0F2FE),
            Color(0xFFDDD6FE),
            Color(0xFFFCE7F3),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.purple400.withOpacity(0.2),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          const ZodiCharacter(size: ZodiSize.large),
          const SizedBox(height: 20),
          const Text(
            'Bugün ne diyor\nyıldızlar?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.purple800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Hemen keşfet, günün sürprizlerini öğren!\n🧿',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.gray600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DailyScreen()),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: AppColors.purpleGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.purple400.withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Günlük Falı Göster',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward,
                    size: 18,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _infoRow() {
    return Row(
      children: [
        Expanded(child: _infoTile('🔥', '0 Gün', 'Streak')),
        const SizedBox(width: 8),
        Expanded(child: _infoTile('📅', 'Cuma', '13 Şubat')),
        const SizedBox(width: 8),
        Expanded(child: _infoTile('🌙', 'Dolunay', 'Faz')),
      ],
    );
  }
  
  Widget _infoTile(String emoji, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.purple800,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 11, color: AppColors.gray600),
          ),
        ],
      ),
    );
  }
  
  Widget _quickActionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: colors.first.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
