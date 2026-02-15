import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../services/ad_service.dart';

/// Rewarded ad izleme butonu — herhangi bir yerde kullanılabilir
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
      widget.onRewarded?.call();
    } else {
      widget.onFailed?.call();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reklam yüklenemedi, biraz sonra tekrar dene!'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: widget.gradient ?? AppColors.purpleGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _showAd,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                else
                  Icon(widget.icon, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  _isLoading ? 'Yükleniyor...' : widget.label,
                  style: const TextStyle(
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
              child: Container(
                decoration: BoxDecoration(
                  color: (isDark ? Colors.black : Colors.white).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock, size: 40, color: AppColors.gold),
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
                      'Reklam izle ve aç!',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white70 : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        RewardedAdButton(
          label: 'Reklam İzle & $featureName Aç',
          placement: placement,
          icon: Icons.lock_open,
          onRewarded: onUnlocked,
        ),
      ],
    );
  }
}
