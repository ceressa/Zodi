import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/campaign_service.dart';
import '../constants/colors.dart';
import '../screens/premium_screen.dart';
import '../theme/cosmic_page_route.dart';

/// Başlangıç paketi banner'ı — FOMO zamanlayıcılı
/// İlk 48 saat içinde gösterilir, ₺29.99 özel teklif
class StarterPackBanner extends StatefulWidget {
  final VoidCallback? onDismiss;
  final VoidCallback? onPurchase;

  const StarterPackBanner({
    super.key,
    this.onDismiss,
    this.onPurchase,
  });

  @override
  State<StarterPackBanner> createState() => _StarterPackBannerState();
}

class _StarterPackBannerState extends State<StarterPackBanner> {
  final CampaignService _campaignService = CampaignService();
  int _remainingHours = 0;
  bool _visible = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _checkVisibility();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkVisibility() async {
    final shouldShow = await _campaignService.shouldShowStarterPack();
    if (shouldShow) {
      final hours = await _campaignService.getStarterPackRemainingHours();
      if (mounted) {
        setState(() {
          _visible = true;
          _remainingHours = hours;
        });
        // Her dakika güncelle
        _timer = Timer.periodic(const Duration(minutes: 1), (_) async {
          final h = await _campaignService.getStarterPackRemainingHours();
          if (mounted) {
            setState(() => _remainingHours = h);
            if (h <= 0) {
              setState(() => _visible = false);
              _timer?.cancel();
            }
          }
        });
      }
    }
  }

  void _dismiss() {
    _campaignService.dismissCampaign();
    setState(() => _visible = false);
    widget.onDismiss?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFFDB2777)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // İçerik
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Üst satır — başlık + zamanlayıcı
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.local_fire_department, color: Colors.amber, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'Özel Teklif',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Zamanlayıcı
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.timer, color: Colors.amber, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            _remainingHours > 0 ? '$_remainingHours saat kaldı' : 'Son fırsat!',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Başlık
                const Text(
                  'Başlangıç Paketi',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),

                // İçerik
                Text(
                  '${CampaignService.starterPackCoins} Yıldız Tozu + ${CampaignService.starterPackPremiumDays} Gün Premium',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.85),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),

                // Fiyat + buton
                Row(
                  children: [
                    // Eski fiyat
                    Text(
                      '₺99.99',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.5),
                        decoration: TextDecoration.lineThrough,
                        decorationColor: Colors.white.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Yeni fiyat
                    Text(
                      '₺${CampaignService.starterPackPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    // CTA butonu
                    GestureDetector(
                      onTap: () {
                        widget.onPurchase?.call();
                        Navigator.push(
                          context,
                          CosmicBottomSheetRoute(page: const PremiumScreen()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Text(
                          'Hemen Al',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF7C3AED),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Kapat butonu
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: _dismiss,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 16, color: Colors.white70),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1);
  }
}
