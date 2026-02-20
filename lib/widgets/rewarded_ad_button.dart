import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../services/ad_service.dart';
import '../services/activity_log_service.dart';
import '../providers/coin_provider.dart';

/// Rewarded ad izleme butonu — şık, kozmik temaya uyumlu
/// Reklam izlendiğinde onRewarded callback'i tetiklenir
class RewardedAdButton extends StatefulWidget {
  final String label;
  final String placement;
  final IconData icon;
  final VoidCallback? onRewarded;
  final VoidCallback? onFailed;
  final LinearGradient? gradient;

  const RewardedAdButton({
    super.key,
    required this.label,
    required this.placement,
    this.icon = Icons.play_circle_outline,
    this.onRewarded,
    this.onFailed,
    this.gradient,
  });

  @override
  State<RewardedAdButton> createState() => _RewardedAdButtonState();
}

class _RewardedAdButtonState extends State<RewardedAdButton> {
  bool _isLoading = false;
  final _adService = AdService();

  @override
  void initState() {
    super.initState();
    _adService.loadRewardedAd();
  }

  Future<void> _showAd() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    final rewarded = await _adService.showRewardedAd(placement: widget.placement);

    setState(() => _isLoading = false);

    if (rewarded) {
      if (mounted) {
        final coinProvider = context.read<CoinProvider>();
        await coinProvider.earnFromAd();
        ActivityLogService().logCoinEarned(5, 'reklam_${widget.placement}');
      }
      widget.onRewarded?.call();
    } else {
      widget.onFailed?.call();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Reklam yüklenemedi, biraz sonra tekrar dene!'),
            backgroundColor: AppColors.warning,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? const Color(0xFFA78BFA).withValues(alpha: 0.25)
              : const Color(0xFF7C3AED).withValues(alpha: 0.15),
          width: 1.5,
        ),
        color: isDark
            ? const Color(0xFF1E1B4B).withValues(alpha: 0.5)
            : const Color(0xFFF8F5FF),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _showAd,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isLoading)
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      color: isDark ? const Color(0xFFA78BFA) : const Color(0xFF7C3AED),
                      strokeWidth: 2,
                    ),
                  )
                else
                  Icon(
                    widget.icon,
                    color: isDark ? const Color(0xFFA78BFA) : const Color(0xFF7C3AED),
                    size: 20,
                  ),
                const SizedBox(width: 8),
                Text(
                  _isLoading ? 'Yükleniyor...' : widget.label,
                  style: TextStyle(
                    color: isDark
                        ? const Color(0xFFA78BFA)
                        : const Color(0xFF7C3AED),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Rewarded ad ile kilit açma — özellik kilitliyse reklam izle butonu gösterir
class RewardedUnlockWidget extends StatelessWidget {
  final String featureName;
  final String placement;
  final bool isLocked;
  final Widget child;
  final VoidCallback? onUnlocked;

  const RewardedUnlockWidget({
    super.key,
    required this.featureName,
    required this.placement,
    required this.isLocked,
    required this.child,
    this.onUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLocked) return child;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Bulanık önizleme
        Stack(
          children: [
            Opacity(opacity: 0.3, child: child),
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                  child: Container(
                    decoration: BoxDecoration(
                      color: (isDark ? const Color(0xFF0F0A2E) : Colors.white).withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.lock_rounded, size: 36, color: Color(0xFFA78BFA)),
                        const SizedBox(height: 8),
                        Text(
                          featureName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Reklam izle ve aç',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white54 : AppColors.textMuted,
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
        const SizedBox(height: 12),
        RewardedAdButton(
          label: 'Reklam İzle & $featureName Aç',
          placement: placement,
          icon: Icons.lock_open_rounded,
          onRewarded: onUnlocked,
        ),
      ],
    );
  }
}
