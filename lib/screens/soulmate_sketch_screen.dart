import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../config/fun_feature_config.dart';
import '../config/membership_config.dart';
import '../providers/auth_provider.dart';
import '../providers/coin_provider.dart';
import '../services/firebase_service.dart';
import '../services/gemini_service.dart';
import '../services/share_service.dart';
import '../models/zodiac_sign.dart';
import '../widgets/share_cards/soulmate_sketch_share_card.dart';
import '../widgets/sticky_bottom_actions.dart';

class SoulmateSketchScreen extends StatefulWidget {
  final FunFeatureConfig config;

  const SoulmateSketchScreen({super.key, required this.config});

  @override
  State<SoulmateSketchScreen> createState() => _SoulmateSketchScreenState();
}

class _SoulmateSketchScreenState extends State<SoulmateSketchScreen>
    with TickerProviderStateMixin {
  final GeminiService _geminiService = GeminiService();
  final FirebaseService _firebaseService = FirebaseService();

  bool _isLoading = false;
  bool _resultLoaded = false;
  Uint8List? _imageBytes;
  String? _error;
  bool? _hasFreeRight;
  String? _selectedSoulmateGender; // 'erkek' veya 'kadın'

  // Bekleme ipuçları
  static const _loadingTips = [
    'Yıldızlar ruh eşinin portresini çiziyor...',
    'Kozmik enerjiler şekilleniyor...',
    'Doğum haritanın sırları açığa çıkıyor...',
    'Gezegen hizalanmaları analiz ediliyor...',
    'Ruh eşinin aurası belirginleşiyor...',
    'Astrolojik bağlantılar kuruluyor...',
    'Son rötuşlar yapılıyor...',
  ];

  late final AnimationController _tipController;
  int _currentTipIndex = 0;

  @override
  void initState() {
    super.initState();
    _tipController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _currentTipIndex = (_currentTipIndex + 1) % _loadingTips.length;
          });
          _tipController.forward(from: 0);
        }
      });
    _checkCachedImage();
    _checkFreeRight();
  }

  @override
  void dispose() {
    _tipController.dispose();
    super.dispose();
  }

  Future<void> _checkCachedImage() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/soulmate_sketch.png');
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        if (mounted) {
          setState(() {
            _imageBytes = bytes;
            _resultLoaded = true;
          });
        }
      }
    } catch (e) {
      debugPrint('Cache kontrol hatası: $e');
    }
  }

  Future<void> _checkFreeRight() async {
    final authProvider = context.read<AuthProvider>();
    final userTier = authProvider.membershipTier;
    if (userTier == MembershipTier.platinyum) {
      final used = await _firebaseService.hasSoulmateSketchFreeUsed();
      if (mounted) setState(() => _hasFreeRight = !used);
    } else {
      if (mounted) setState(() => _hasFreeRight = false);
    }
  }

  Future<void> _startGeneration() async {
    final authProvider = context.read<AuthProvider>();
    final coinProvider = context.read<CoinProvider>();
    final profile = authProvider.userProfile;

    if (profile == null) {
      _showError('Profil bilgisi bulunamadı');
      return;
    }

    if (_selectedSoulmateGender == null) {
      _showError('Lütfen ruh eşinin cinsiyetini seç');
      return;
    }

    // Ödeme kontrolü
    final isFreeUse = _hasFreeRight == true;
    if (!isFreeUse) {
      final success = await coinProvider.spendCoins(
        widget.config.coinCost,
        'fun_feature_${widget.config.id}',
      );
      if (!success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Yeterli Yıldız Tozu yok!'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _currentTipIndex = 0;
    });
    _tipController.forward(from: 0);

    try {
      final zodiacName = profile.zodiacSign;
      final bytes = await _geminiService.generateSoulmateSketch(
        zodiacSign: zodiacName,
        birthDate: '${profile.birthDate.day}.${profile.birthDate.month}.${profile.birthDate.year}',
        gender: _selectedSoulmateGender!,
        risingSign: profile.risingSign,
        moonSign: profile.moonSign,
      );

      // Görseli cache'e kaydet
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/soulmate_sketch.png');
      await file.writeAsBytes(bytes);

      // Platinyum ücretsiz hakkı kullanıldıysa işaretle
      if (isFreeUse) {
        await _firebaseService.markSoulmateSketchFreeUsed();
        setState(() => _hasFreeRight = false);
      }

      if (mounted) {
        setState(() {
          _imageBytes = bytes;
          _resultLoaded = true;
          _isLoading = false;
        });
        _tipController.stop();
      }
    } catch (e) {
      debugPrint('❌ Soulmate sketch generation error: $e');
      // Hata durumunda coin iadesi (ücretsiz değilse)
      if (!isFreeUse) {
        await coinProvider.addCoins(widget.config.coinCost);
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Görsel oluşturulamadı. Lütfen tekrar dene.';
        });
        _tipController.stop();
      }
    }
  }

  void _showError(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _shareImage() async {
    if (_imageBytes == null) return;
    try {
      final authProvider = context.read<AuthProvider>();
      final zodiacStr = authProvider.userProfile?.zodiacSign ?? '';
      final zodiac = ZodiacSign.fromString(zodiacStr);

      await ShareService().shareCardWidget(
        context,
        SoulmateSketchShareCard(
          imageBytes: _imageBytes!,
          zodiacSymbol: zodiac?.symbol ?? '♈',
          zodiacName: zodiac?.displayName ?? zodiacStr,
        ),
      );
    } catch (e) {
      debugPrint('Share error: $e');
      // Fallback: görseli direkt paylaş
      try {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/soulmate_sketch.png');
        if (await file.exists()) {
          await Share.shareXFiles([XFile(file.path)],
              text: '🎨 Ruh Eşi Çizimim — Astro Dozi');
        }
      } catch (_) {}
    }
  }

  static const _galleryChannel = MethodChannel('com.bardino.zodi/gallery');

  Future<void> _saveToGallery() async {
    if (_imageBytes == null) return;
    try {
      await _galleryChannel.invokeMethod('saveToGallery', {
        'bytes': _imageBytes!,
        'fileName': 'astro_dozi_ruh_esi_${DateTime.now().millisecondsSinceEpoch}.png',
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Görsel galeriye kaydedildi! 📸'),
            backgroundColor: Color(0xFF7C3AED),
          ),
        );
      }
    } catch (e) {
      debugPrint('Gallery save error: $e');
      _showError('Galeriye kaydetme hatası');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5FF),
      appBar: AppBar(
        title: const Text('Ruh Eşi Çizimi'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF1E1B4B),
      ),
      // Sonuç varsa butonlar altta sabit
      bottomNavigationBar: _resultLoaded && _imageBytes != null
          ? StickyBottomActions(
              children: [
                StickyBottomActions.primaryButton(
                  label: 'Paylaş',
                  icon: Icons.share_rounded,
                  gradient: const [Color(0xFFE91E63), Color(0xFFF06292)],
                  onTap: _shareImage,
                ),
                StickyBottomActions.outlineButton(
                  label: 'Kaydet',
                  icon: Icons.download_rounded,
                  color: const Color(0xFF7C3AED),
                  onTap: _saveToGallery,
                ),
              ],
            )
          : null,
      body: SafeArea(
        child: _isLoading
            ? _buildLoadingState()
            : _resultLoaded
                ? _buildResultState()
                : _buildIntroState(),
      ),
      // Hata durumunda alt kısımda banner göster
      bottomSheet: _error != null && !_isLoading && !_resultLoaded
          ? Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade400),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _error!,
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.red.shade400, size: 18),
                    onPressed: () => setState(() => _error = null),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  // ─── INTRO STATE ───────────────────────────────────────────

  Widget _buildIntroState() {
    final authProvider = context.watch<AuthProvider>();
    final userTier = authProvider.membershipTier;
    final coinProvider = context.watch<CoinProvider>();
    final hasEnough = coinProvider.balance >= widget.config.coinCost;
    final isFree = _hasFreeRight == true;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          // Hero kart
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  widget.config.gradient.first.withValues(alpha: 0.15),
                  widget.config.gradient.last.withValues(alpha: 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: widget.config.gradient.first.withValues(alpha: 0.20),
              ),
            ),
            child: Column(
              children: [
                const Text('🎨', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 16),
                const Text(
                  'Ruh Eşi Çizimi',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E1B4B),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Doğum haritana göre ruh eşinin AI portresi',
                  style: TextStyle(
                    fontSize: 15,
                    color: const Color(0xFF1E1B4B).withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms).scale(
                begin: const Offset(0.95, 0.95),
                duration: 400.ms,
                curve: Curves.easeOut,
              ),

          const SizedBox(height: 24),

          // Açıklama kartları
          _buildInfoCard(
            '🌟',
            'Nasıl Çalışır?',
            'Doğum haritandaki gezegen pozisyonları ve burç enerjilerini analiz ediyoruz. '
                'Sonra AI ile ruh eşinin artistik bir portresini oluşturuyoruz.',
          ).animate().fadeIn(delay: 100.ms, duration: 400.ms).slideY(begin: 0.1),

          const SizedBox(height: 12),

          _buildInfoCard(
            '✨',
            'Ne Göreceksin?',
            'Burcuna özel fiziksel özellikler, enerji ve aura ile oluşturulmuş '
                'benzersiz bir sanatsal portre.',
          ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.1),

          const SizedBox(height: 24),

          // Cinsiyet seçimi
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ruh eşin kim olsun?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E1B4B),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedSoulmateGender = 'erkek'),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: _selectedSoulmateGender == 'erkek'
                                ? const Color(0xFF7C3AED).withValues(alpha: 0.12)
                                : const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _selectedSoulmateGender == 'erkek'
                                  ? const Color(0xFF7C3AED)
                                  : const Color(0xFFE5E7EB),
                              width: _selectedSoulmateGender == 'erkek' ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                '👨',
                                style: TextStyle(
                                  fontSize: 32,
                                  color: _selectedSoulmateGender == 'erkek'
                                      ? null
                                      : const Color(0xFF1E1B4B).withValues(alpha: 0.5),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Erkek',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _selectedSoulmateGender == 'erkek'
                                      ? const Color(0xFF7C3AED)
                                      : const Color(0xFF1E1B4B).withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedSoulmateGender = 'kadın'),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: _selectedSoulmateGender == 'kadın'
                                ? const Color(0xFFE91E63).withValues(alpha: 0.12)
                                : const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _selectedSoulmateGender == 'kadın'
                                  ? const Color(0xFFE91E63)
                                  : const Color(0xFFE5E7EB),
                              width: _selectedSoulmateGender == 'kadın' ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                '👩',
                                style: TextStyle(
                                  fontSize: 32,
                                  color: _selectedSoulmateGender == 'kadın'
                                      ? null
                                      : const Color(0xFF1E1B4B).withValues(alpha: 0.5),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Kadın',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _selectedSoulmateGender == 'kadın'
                                      ? const Color(0xFFE91E63)
                                      : const Color(0xFF1E1B4B).withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(delay: 250.ms, duration: 400.ms).slideY(begin: 0.1),

          const SizedBox(height: 24),

          // Fiyat bilgisi
          if (isFree)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7C3AED), Color(0xFF6D28D9)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.diamond_rounded, color: Colors.white, size: 18),
                  SizedBox(width: 6),
                  Text(
                    'Platinyum — 1 Kerelik Ücretsiz!',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 300.ms)
          else
            Text(
              '${widget.config.coinCost} ⭐ Yıldız Tozu',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: hasEnough
                    ? const Color(0xFF7C3AED)
                    : Colors.red.shade400,
              ),
            ).animate().fadeIn(delay: 300.ms),

          const SizedBox(height: 20),

          // Ana buton
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: (isFree || hasEnough) && _selectedSoulmateGender != null
                  ? _startGeneration
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE91E63),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                elevation: 4,
                shadowColor: const Color(0xFFE91E63).withValues(alpha: 0.40),
              ),
              child: Text(
                isFree ? 'Ücretsiz Çizimi Başlat' : 'Çizimi Başlat',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ).animate().fadeIn(delay: 400.ms, duration: 400.ms),

          if (!isFree && !hasEnough)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                'Yeterli Yıldız Tozu yok. Mevcut: ${coinProvider.balance} ⭐',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.red.shade400,
                ),
              ),
            ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String emoji, String title, String desc) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E1B4B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 13,
                    color: const Color(0xFF1E1B4B).withValues(alpha: 0.65),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── LOADING STATE ─────────────────────────────────────────

  Widget _buildLoadingState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Pulsing emoji
            const Text('🎨', style: TextStyle(fontSize: 72))
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(
                  begin: const Offset(0.85, 0.85),
                  end: const Offset(1.15, 1.15),
                  duration: 1200.ms,
                  curve: Curves.easeInOut,
                ),

            const SizedBox(height: 32),

            const Text(
              'Ruh Eşin Çiziliyor...',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E1B4B),
              ),
            ),

            const SizedBox(height: 12),

            Text(
              'Bu işlem 15-30 saniye sürebilir',
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFF1E1B4B).withValues(alpha: 0.5),
              ),
            ),

            const SizedBox(height: 32),

            // Progress indicator
            SizedBox(
              width: 200,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  backgroundColor:
                      const Color(0xFFE91E63).withValues(alpha: 0.15),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFFE91E63),
                  ),
                  minHeight: 6,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Animated tip
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
              child: Text(
                _loadingTips[_currentTipIndex],
                key: ValueKey(_currentTipIndex),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontStyle: FontStyle.italic,
                  color: const Color(0xFF7C3AED).withValues(alpha: 0.8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── RESULT STATE ──────────────────────────────────────────

  Widget _buildResultState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          // Başlık
          const Text(
            '💘 Ruh Eşinin Portresi',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E1B4B),
            ),
          ).animate().fadeIn(duration: 400.ms),

          const SizedBox(height: 4),

          Text(
            'Doğum haritana göre oluşturuldu',
            style: TextStyle(
              fontSize: 13,
              color: const Color(0xFF1E1B4B).withValues(alpha: 0.6),
            ),
          ).animate().fadeIn(delay: 100.ms),

          const SizedBox(height: 14),

          // Görsel
          if (_imageBytes != null)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE91E63).withValues(alpha: 0.20),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.memory(
                  _imageBytes!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            )
                .animate()
                .fadeIn(delay: 200.ms, duration: 600.ms)
                .scale(
                  begin: const Offset(0.95, 0.95),
                  duration: 600.ms,
                  curve: Curves.easeOut,
                ),

          // Butonlar artık altta sabit (bottomNavigationBar)
          const SizedBox(height: 16),

          // Tekrar üret butonu
          SizedBox(
            width: double.infinity,
            height: 40,
            child: TextButton.icon(
              onPressed: () async {
                // Eski cache'i temizle
                try {
                  final dir = await getApplicationDocumentsDirectory();
                  final file = File('${dir.path}/soulmate_sketch.png');
                  if (await file.exists()) await file.delete();
                } catch (_) {}
                setState(() {
                  _resultLoaded = false;
                  _imageBytes = null;
                });
                _checkFreeRight();
              },
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: Text(
                'Yeniden Çiz (${widget.config.coinCost} ⭐)',
                style: const TextStyle(fontSize: 13),
              ),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF1E1B4B).withValues(alpha: 0.6),
              ),
            ),
          ).animate().fadeIn(delay: 500.ms),

          if (_error != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade400, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
