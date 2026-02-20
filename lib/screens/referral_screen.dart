import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../services/referral_service.dart';
import '../providers/auth_provider.dart';
import '../providers/coin_provider.dart';
import '../constants/colors.dart';

/// Arkadaş davet ekranı — referral kodu paylaş, coin kazan
class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key});

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  final ReferralService _referralService = ReferralService();
  final TextEditingController _codeController = TextEditingController();

  String _myCode = '';
  int _referralCount = 0;
  int _remainingReferrals = 0;
  bool _hasUsedCode = false;
  bool _isLoading = true;
  bool _isApplying = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.userId ?? '';

    final code = await _referralService.getOrCreateReferralCode(userId);
    final count = await _referralService.getReferralCount();
    final remaining = await _referralService.getRemainingReferrals();
    final hasUsed = await _referralService.hasUsedReferralCode();

    if (mounted) {
      setState(() {
        _myCode = code;
        _referralCount = count;
        _remainingReferrals = remaining;
        _hasUsedCode = hasUsed;
        _isLoading = false;
      });
    }
  }

  Future<void> _shareCode() async {
    final text = _referralService.getShareText(_myCode);
    await Share.share(text, subject: 'Astro Dozi Davet');
  }

  Future<void> _copyCode() async {
    await Clipboard.setData(ClipboardData(text: _myCode));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Davet kodu kopyalandı!'),
          backgroundColor: AppColors.accentPurple,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _applyCode() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty || code.length < 6) {
      _showMessage('Lütfen geçerli bir davet kodu gir.', isError: true);
      return;
    }

    setState(() => _isApplying = true);

    final authProvider = context.read<AuthProvider>();
    final coinProvider = context.read<CoinProvider>();
    final userId = authProvider.userId ?? '';

    final result = await _referralService.useReferralCode(code, userId);

    if (result.success && result.reward != null) {
      // Kendine coin ekle
      await coinProvider.addCoins(result.reward!);
      // Not: Karşı tarafın coinlerini sunucu tarafında eklemek gerekir
      // Şimdilik sadece kendi tarafını ekliyoruz
    }

    if (mounted) {
      setState(() => _isApplying = false);
      _showMessage(result.message, isError: !result.success);
      if (result.success) {
        _codeController.clear();
        _loadData(); // Verileri güncelle
      }
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.warning : AppColors.accentPurple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5FF),
      appBar: AppBar(
        title: const Text(
          'Arkadaş Davet Et',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: const Color(0xFFF8F5FF),
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.textDark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.accentPurple),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Hero card
                  _buildHeroCard(),
                  const SizedBox(height: 24),

                  // İstatistikler
                  _buildStatsRow(),
                  const SizedBox(height: 24),

                  // Kodunu paylaş
                  _buildMyCodeCard(),
                  const SizedBox(height: 24),

                  // Kod kullan
                  if (!_hasUsedCode) _buildUseCodeCard(),

                  const SizedBox(height: 24),

                  // Nasıl çalışır?
                  _buildHowItWorks(),
                ],
              ),
            ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFFDB2777)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text('🎁', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 12),
          const Text(
            'Arkadaşını Davet Et\nİkiniz de Kazanın!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.monetization_on, size: 18, color: Colors.amber),
                const SizedBox(width: 6),
                Text(
                  '${ReferralService.referralReward} Yıldız Tozu x 2',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.03);
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            '$_referralCount',
            'Davet Edilen',
            Icons.people_alt_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            '${_referralCount * ReferralService.referralReward}',
            'Kazanılan Yıldız Tozu',
            Icons.monetization_on,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            '$_remainingReferrals',
            'Kalan Hak',
            Icons.card_giftcard,
          ),
        ),
      ],
    ).animate(delay: 100.ms).fadeIn(duration: 300.ms);
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.accentPurple, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textDark.withOpacity(0.5),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMyCodeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Senin Davet Kodun',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 14),

          // Kod kutusu
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF3E8FF), Color(0xFFEDE9FE)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.accentPurple.withOpacity(0.2),
              ),
            ),
            child: Center(
              child: Text(
                _myCode,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 6,
                  color: AppColors.accentPurple,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Butonlar
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _copyCode,
                  icon: const Icon(Icons.copy, size: 18),
                  label: const Text('Kopyala'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accentPurple,
                    side: BorderSide(color: AppColors.accentPurple.withOpacity(0.3)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: AppColors.purpleGradient,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentPurple.withOpacity(0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _shareCode,
                      borderRadius: BorderRadius.circular(14),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.share_rounded, size: 18, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Arkadaşına Gönder',
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
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate(delay: 200.ms).fadeIn(duration: 300.ms);
  }

  Widget _buildUseCodeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Davet Kodu Kullan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Arkadaşının davet kodunu girerek ${ReferralService.referralReward} Yıldız Tozu kazan!',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textDark.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _codeController,
                  textCapitalization: TextCapitalization.characters,
                  maxLength: 6,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 3,
                  ),
                  decoration: InputDecoration(
                    hintText: 'KODGIR',
                    counterText: '',
                    hintStyle: TextStyle(
                      color: AppColors.textDark.withOpacity(0.2),
                      letterSpacing: 3,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF8F5FF),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: AppColors.accentPurple.withOpacity(0.2)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: AppColors.accentPurple.withOpacity(0.15)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.accentPurple, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isApplying ? null : _applyCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  child: _isApplying
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Uygula',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate(delay: 300.ms).fadeIn(duration: 300.ms);
  }

  Widget _buildHowItWorks() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nasıl Çalışır?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          _buildStep(1, 'Davet kodunu arkadaşınla paylaş', Icons.share_rounded),
          const SizedBox(height: 12),
          _buildStep(2, 'Arkadaşın Astro Dozi\'yi indirsin', Icons.download_rounded),
          const SizedBox(height: 12),
          _buildStep(3, 'Kodunu uygulasın', Icons.input_rounded),
          const SizedBox(height: 12),
          _buildStep(4, 'İkiniz de ${ReferralService.referralReward} Yıldız Tozu kazanın!', Icons.stars_rounded),
        ],
      ),
    ).animate(delay: 400.ms).fadeIn(duration: 300.ms);
  }

  Widget _buildStep(int number, String text, IconData icon) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            gradient: AppColors.purpleGradient,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              '$number',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Icon(icon, size: 18, color: AppColors.accentPurple),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textDark.withOpacity(0.7),
            ),
          ),
        ),
      ],
    );
  }
}
