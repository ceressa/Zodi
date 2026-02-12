import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/ad_service.dart';

class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({super.key});

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  final AdService _adService = AdService();
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    print('🎯 AdBannerWidget: initState - Loading banner ad...');
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    
    _adService.loadBannerAd();
    
    // Periyodik olarak kontrol et
    _checkAdStatus();
  }

  void _checkAdStatus() {
    int attempts = 0;
    const maxAttempts = 20; // 10 saniye (20 x 500ms)
    
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 500));
      attempts++;
      
      if (!mounted) return false;
      
      final isReady = _adService.isBannerAdReady;
      final hasAd = _adService.bannerAd != null;
      
      print('🎯 AdBannerWidget: Check #$attempts - Ready: $isReady, Has ad: $hasAd');
      
      if (isReady && hasAd) {
        setState(() {
          _isLoading = false;
          _hasError = false;
        });
        print('✅ AdBannerWidget: Ad is ready!');
        return false; // Stop checking
      }
      
      if (attempts >= maxAttempts) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
        print('❌ AdBannerWidget: Timeout - Ad failed to load after $maxAttempts attempts');
        return false; // Stop checking
      }
      
      return true; // Continue checking
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    
    // Premium kullanıcılara reklam gösterme
    if (authProvider.isPremium) {
      print('🎯 AdBannerWidget: User is premium, hiding ad');
      return const SizedBox.shrink();
    }

    // Hata durumu
    if (_hasError) {
      print('🎯 AdBannerWidget: Error state, showing error message');
      return Container(
        alignment: Alignment.center,
        width: 320,
        height: 50,
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red[300], size: 16),
            const SizedBox(width: 8),
            Text(
              'Reklam yüklenemedi',
              style: TextStyle(color: Colors.red[300], fontSize: 12),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: _loadAd,
              child: const Text('Tekrar Dene', style: TextStyle(fontSize: 11)),
            ),
          ],
        ),
      );
    }

    // Yükleniyor durumu
    if (_isLoading) {
      print('🎯 AdBannerWidget: Loading state');
      return Container(
        alignment: Alignment.center,
        width: 320,
        height: 50,
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white54),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Reklam yükleniyor...',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
      );
    }

    final bannerAd = _adService.bannerAd;
    
    if (bannerAd == null) {
      print('🎯 AdBannerWidget: Banner ad is null');
      return const SizedBox.shrink();
    }

    print('🎯 AdBannerWidget: Showing banner ad');
    return Container(
      alignment: Alignment.center,
      width: bannerAd.size.width.toDouble(),
      height: bannerAd.size.height.toDouble(),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: AdWidget(ad: bannerAd),
    );
  }
}
