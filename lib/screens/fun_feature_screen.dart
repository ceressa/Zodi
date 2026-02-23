import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../config/fun_feature_config.dart';
import '../providers/auth_provider.dart';
import '../providers/coin_provider.dart';
import '../constants/colors.dart';
import '../services/ad_service.dart';
import '../services/gemini_service.dart';
import '../services/fun_feature_service.dart';
import '../services/share_service.dart';
import '../services/daily_discovery_service.dart';
import '../widgets/share_cards/fun_feature_share_card.dart';
import '../widgets/sticky_bottom_actions.dart';

/// Eğlenceli özellik detay ve içerik ekranı — Gerçek AI entegrasyonu
class FunFeatureScreen extends StatefulWidget {
  final FunFeatureConfig config;
  final int? overrideCoinCost;

  const FunFeatureScreen({super.key, required this.config, this.overrideCoinCost});

  @override
  State<FunFeatureScreen> createState() => _FunFeatureScreenState();
}

class _FunFeatureScreenState extends State<FunFeatureScreen> {
  final GeminiService _geminiService = GeminiService();
  final FunFeatureService _cacheService = FunFeatureService();
  final AdService _adService = AdService();

  bool _isLoading = false;
  bool _resultLoaded = false;
  Map<String, dynamic>? _result;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkCache();
  }

  /// Bugün için cache'de sonuç var mı kontrol et
  Future<void> _checkCache() async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final cacheKey = '${widget.config.id}_$today';
    final cached = await _cacheService.getCachedResult(cacheKey);
    if (cached != null && mounted) {
      try {
        final json = jsonDecode(cached) as Map<String, dynamic>;
        setState(() {
          _result = json;
          _resultLoaded = true;
        });
      } catch (_) {
        // Cache bozuk, yeni sonuç üretilecek
      }
    }
  }

  /// Prompt şablonlarını feature id'ye göre döndür
  String _getPromptTemplate() {
    switch (widget.config.id) {
      case 'numerology':
        return '''
NUMEROLOJI ANALIZI YAP:
Kullanıcının doğum tarihinden yaşam sayısını, kişilik sayısını ve kader sayısını hesapla.
Her sayının anlamını ve etkilerini detaylıca anlat.
Sayıların birbirleriyle uyumunu ve genel enerji haritasını çıkar.
"mainResult" olarak yaşam sayısını ve kısa bir özetini ver.
"details" olarak: [yaşam sayısı analizi, kişilik sayısı analizi, kader sayısı analizi, genel sayısal enerji]
''';
      case 'aura':
        return '''
AURA ANALİZİ YAP:
Kullanıcının burcu ve doğum bilgilerine göre aura rengini belirle.
Aura katmanlarını (fiziksel, duygusal, mental, ruhani) analiz et.
Enerji seviyesini ve aura gücünü değerlendir.
"mainResult" olarak aura rengini ver (örn: "Mor Aura" veya "Turkuaz Aura").
"details" olarak: [aura rengi anlamı, enerji seviyesi, güçlü aura katmanları, aura geliştirme önerileri]
''';
      case 'spirit_animal':
        return '''
RUH HAYVANI ANALİZİ YAP:
Kullanıcının burcuna, elementine ve doğum bilgilerine göre ruh hayvanını belirle.
Bu hayvanın neden onun totem hayvanı olduğunu açıkla.
Ortak kişilik özellikleri ve yaşam dersleri paylaş.
"mainResult" olarak ruh hayvanını ver (örn: "Kurt" veya "Kartal").
"details" olarak: [hayvanın sembolik anlamı, ortak kişilik özellikleri, hayvanın verdiği yaşam dersi, ruh hayvanından güç alma yolları]
''';
      case 'chakra':
        return '''
ÇAKRA ANALİZİ YAP:
Kullanıcının burcuna ve doğum bilgilerine göre 7 ana çakrasını analiz et.
Hangi çakraların açık, dengeli veya bloke olduğunu belirle.
En güçlü ve en zayıf çakrasını vurgula.
"mainResult" olarak en baskın çakrayı ver (örn: "Kalp Çakrası" veya "Üçüncü Göz").
"details" olarak: [en güçlü çakra ve etkisi, dikkat edilmesi gereken çakra, çakra dengeleme önerileri, genel enerji akışı durumu]
''';
      case 'past_life':
        return '''
ÖNCEKİ YAŞAM ANALİZİ YAP:
Kullanıcının doğum haritası ve burç bilgilerine göre önceki yaşam hikayesi oluştur.
Hangi çağda, hangi rolde yaşamış olabileceğini anlat.
Önceki yaşamdan taşıdığı karmaları ve yetenekleri belirle.
"mainResult" olarak önceki yaşam rolünü ver (örn: "Mısır Tapınak Rahibesi" veya "Ortaçağ Şifacısı").
"details" olarak: [önceki yaşam hikayesi, taşınan karmalar, önceki yaşamdan gelen yetenekler, bu yaşamdaki etkileri]
''';
      case 'life_path':
        return '''
YAŞAM YOLU ANALİZİ YAP:
Kullanıcının numeroloji ve burç bilgilerini birleştirerek yaşam amacını belirle.
Doğuştan gelen yetenekleri ve potansiyel zorlukları analiz et.
Yaşam yolundaki önemli dönüm noktalarını öngör.
"mainResult" olarak yaşam yolunu ver (örn: "Şifacı Yolu" veya "Lider Yolu").
"details" olarak: [yaşam amacı, doğuştan gelen yetenekler, potansiyel zorluklar, yaşam yolunda ilerleme önerileri]
''';
      case 'luck_map':
        return '''
ŞANS HARİTASI OLUŞTUR:
Kullanıcının burcuna ve bugünün gezegen konumlarına göre şans haritası çıkar.
Hangi alanlarda şanslı olduğunu belirle (aşk, para, kariyer, sağlık, sosyal).
En şanslı saati ve günün şans puanını ver.
"mainResult" olarak bugünün şans durumunu ver (örn: "Süper Şanslı!" veya "Dikkatli Ol!").
"details" olarak: [en şanslı alan ve detayı, dikkat edilmesi gereken alan, şanslı saat aralığı, şansını artırmak için öneriler]
''';
      case 'element_analysis':
        return '''
ELEMENT ANALİZİ YAP:
Kullanıcının burcuna ve doğum haritasına göre elementel dengesini analiz et.
Ateş, Su, Toprak ve Hava elementlerinin dağılımını belirle.
Baskın ve zayıf elementleri vurgula.
"mainResult" olarak baskın elementi ver (örn: "Ateş Ruhu" veya "Su Enerjisi").
"details" olarak: [baskın element ve etkisi, ikincil element, zayıf element ve dengeleme yolu, elementel uyum önerileri]
''';
      case 'astro_career':
        return '''
ASTRO KARİYER ANALİZİ YAP:
Kullanıcının burcuna, doğum haritasına ve numerolojisine göre ideal kariyer alanlarını belirle.
10. ev (kariyer evi) ve Midheaven analizini yap.
Doğuştan gelen profesyonel yetenekleri ve güçlü yönleri vurgula.
"mainResult" olarak en uygun kariyer alanını ver (örn: "Yaratıcı Sanatlar" veya "Liderlik & Yönetim").
"details" olarak: [en uygun kariyer alanları, doğuştan gelen profesyonel yetenekler, kaçınılması gereken kariyer hataları, kariyer hedefleri için öneriler]
''';
      case 'cosmic_message':
        return '''
KOZMİK MESAJ VER:
Kullanıcının burcuna ve bugünün kozmik enerjisine göre evrenden kişisel bir mesaj oluştur.
Mesaj derin, ilham verici ve kişiye özel olmalı.
Günün kozmik temasını ve evrensel enerji akışını yansıtmalı.
"mainResult" olarak kısa ve güçlü bir kozmik mesaj ver (max 8 kelime).
"details" olarak: [bugünün kozmik teması, evrenin sana fısıldadığı, dikkat etmen gereken işaretler, günün affirmasyonu]
''';
      case 'soulmate_sketch':
        return '''
RUH EŞİ PROFİLİ OLUŞTUR

Bu kişinin doğum haritasına göre ruh eşinin profilini oluştur:

1. Kişilik özellikleri (2-3 cümle)
2. Fiziksel ipuçları (göz rengi, saç, genel enerji)
3. Nasıl tanışacakları (mekan, durum)
4. İlişkinin güçlü yönleri
5. Dikkat etmeleri gereken konular

Eğlenceli, romantik ama gerçekçi ol. Zodi tarzında samimi ve dürüst yaz.

JSON yanıtında:
- "mainResult": Ruh eşinin en belirgin özelliği (2-3 kelime)
- "emoji": Ruh eşini temsil eden emoji
- "description": Detaylı profil açıklaması
- "details": ["Kişilik", "Görünüm ipucu", "Tanışma şekli", "İlişki dinamiği"]
''';
      default:
        return '''
Bu konu hakkında kullanıcının burcuna ve doğum bilgilerine göre detaylı bir astrolojik analiz yap.
"mainResult" olarak kısa bir özet ver.
"details" olarak 4 maddelik detaylı analiz sun.
''';
    }
  }

  Future<void> _generate() async {
    final coinProvider = context.read<CoinProvider>();
    final authProvider = context.read<AuthProvider>();
    final userTier = authProvider.membershipTier;
    final isIncluded = widget.config.isIncludedInTier(userTier);

    // Coin kontrolü
    if (!isIncluded) {
      final effectiveCost = widget.overrideCoinCost ?? widget.config.coinCost;
      final success = await coinProvider.spendCoins(
        effectiveCost,
        'fun_feature_${widget.config.id}',
      );
      if (!success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Yetersiz Yıldız Tozu! Bu özellik için $effectiveCost Yıldız Tozu gerekli.',
              ),
              backgroundColor: AppColors.warning,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
        return;
      }
      // Günün keşfi indirimi kullanıldıysa işaretle
      if (widget.overrideCoinCost != null) {
        await DailyDiscoveryService().markDiscountUsed();
      }
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final profile = authProvider.userProfile;
      final zodiac = authProvider.selectedZodiac;

      final result = await _geminiService.generateFunFeature(
        featureId: widget.config.id,
        promptTemplate: _getPromptTemplate(),
        birthDate: profile?.birthDate != null
            ? DateFormat('dd MMMM yyyy', 'tr_TR').format(profile!.birthDate)
            : 'Bilinmiyor',
        birthTime: profile?.birthTime ?? '',
        birthPlace: profile?.birthPlace ?? '',
        zodiacSign: zodiac?.displayName ?? 'Bilinmiyor',
        risingSign: profile?.risingSign,
        moonSign: profile?.moonSign,
      );

      // Cache'e kaydet (bugünün tarihiyle)
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final cacheKey = '${widget.config.id}_$today';
      await _cacheService.cacheResult(cacheKey, jsonEncode(result));

      if (mounted) {
        setState(() {
          _isLoading = false;
          _resultLoaded = true;
          _result = result;
        });
      }
    } catch (e) {
      debugPrint('Fun feature generation error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Bir hata oluştu. Lütfen tekrar dene.';
        });
      }
    }
  }

  Future<void> _generateWithAd() async {
    final watched = await _adService.showRewardedAd(placement: 'fun_feature_${widget.config.id}');
    if (!watched) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Reklam yüklenemedi. Lütfen biraz sonra tekrar dene.'),
            backgroundColor: AppColors.warning,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
      return;
    }

    // Reklam izlendi — coin harcamadan doğrudan generate et
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final profile = authProvider.userProfile;
      final zodiac = authProvider.selectedZodiac;

      final result = await _geminiService.generateFunFeature(
        featureId: widget.config.id,
        promptTemplate: _getPromptTemplate(),
        birthDate: profile?.birthDate != null
            ? DateFormat('dd MMMM yyyy', 'tr_TR').format(profile!.birthDate)
            : 'Bilinmiyor',
        birthTime: profile?.birthTime ?? '',
        birthPlace: profile?.birthPlace ?? '',
        zodiacSign: zodiac?.displayName ?? 'Bilinmiyor',
        risingSign: profile?.risingSign,
        moonSign: profile?.moonSign,
      );

      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final cacheKey = '${widget.config.id}_$today';
      await _cacheService.cacheResult(cacheKey, jsonEncode(result));

      if (mounted) {
        setState(() {
          _isLoading = false;
          _resultLoaded = true;
          _result = result;
        });
      }
    } catch (e) {
      debugPrint('Fun feature generation error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Bir hata oluştu. Lütfen tekrar dene.';
        });
      }
    }
  }

  Future<void> _shareResult() async {
    if (_result == null) return;
    final authProvider = context.read<AuthProvider>();
    final zodiac = authProvider.selectedZodiac;

    final card = FunFeatureShareCard(
      featureTitle: widget.config.title,
      featureEmoji: widget.config.emoji,
      mainResult: _result!['mainResult'] ?? '',
      resultEmoji: _result!['emoji'] ?? widget.config.emoji,
      description: _result!['description'] ?? '',
      details: (_result!['details'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      gradientColors: widget.config.gradient,
      zodiacSymbol: zodiac?.symbol,
      zodiacName: zodiac?.displayName,
    );

    await ShareService().shareCardWidget(
      context,
      card,
      text: '${widget.config.emoji} ${widget.config.title} — Astro Dozi\n#AstroDozi #${widget.config.title.replaceAll(' ', '')}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userTier = authProvider.membershipTier;
    final isLocked = widget.config.requiredTier != null &&
        !widget.config.canAccess(userTier);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5FF),
      appBar: AppBar(
        title: Text(
          widget.config.title,
          style: const TextStyle(fontWeight: FontWeight.w700),
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
      // Sonuç varsa butonlar altta sabit
      bottomNavigationBar: (_resultLoaded && _result != null && !isLocked)
          ? StickyBottomActions(
              children: [
                StickyBottomActions.primaryButton(
                  label: 'Paylaş',
                  icon: Icons.share_rounded,
                  gradient: widget.config.gradient,
                  onTap: _shareResult,
                ),
                StickyBottomActions.iconButton(
                  icon: Icons.refresh_rounded,
                  color: widget.config.gradient.first,
                  onTap: _generate,
                ),
              ],
            )
          : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Hero card
            _buildHeroCard(),

            const SizedBox(height: 24),

            if (isLocked)
              _buildLockedContent()
            else if (_isLoading)
              _buildLoadingState()
            else if (_error != null)
              _buildErrorState()
            else if (_resultLoaded && _result != null)
              _buildResultContent()
            else
              _buildStartButton(),
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
        gradient: LinearGradient(
          colors: widget.config.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: widget.config.gradient.first.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(widget.config.emoji, style: const TextStyle(fontSize: 56)),
          const SizedBox(height: 12),
          Text(
            widget.config.title,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.config.subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          if (!widget.config.isIncludedInTier(
              context.read<AuthProvider>().membershipTier)) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.monetization_on, size: 16, color: Colors.amber),
                  const SizedBox(width: 6),
                  if (widget.overrideCoinCost != null) ...[
                    Text(
                      '${widget.config.coinCost}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white54,
                        decoration: TextDecoration.lineThrough,
                        decorationColor: Colors.white54,
                      ),
                    ),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    '${widget.overrideCoinCost ?? widget.config.coinCost} Yıldız Tozu',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.03);
  }

  Widget _buildLockedContent() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.accentPurple.withOpacity(0.15)),
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF3E8FF), Color(0xFFEDE9FE)],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lock_rounded, size: 36, color: AppColors.accentPurple),
          ),
          const SizedBox(height: 16),
          const Text(
            'Premium Özellik',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bu özelliğe erişmek için Altın veya üzeri üyelik gerekli.',
            style: TextStyle(fontSize: 14, color: AppColors.textDark.withOpacity(0.6)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: widget.config.gradient.first,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '${widget.config.emoji} Analiz ediliyor...',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Yıldızlar senin için konuşuyor',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textDark.withOpacity(0.5),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.red.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 40, color: Colors.red),
          const SizedBox(height: 12),
          Text(
            _error ?? 'Bir hata oluştu',
            style: const TextStyle(fontSize: 14, color: AppColors.textDark),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: _generate,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Tekrar Dene'),
            style: TextButton.styleFrom(
              foregroundColor: widget.config.gradient.first,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildResultContent() {
    final mainResult = _result!['mainResult'] ?? '';
    final resultEmoji = _result!['emoji'] ?? widget.config.emoji;
    final description = _result!['description'] ?? '';
    final details = (_result!['details'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    return Column(
      children: [
        // Ana sonuç kartı
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, const Color(0xFFFAF5FF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: widget.config.gradient.first.withOpacity(0.12),
            ),
            boxShadow: [
              BoxShadow(
                color: widget.config.gradient.first.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(resultEmoji, style: const TextStyle(fontSize: 52)),
              const SizedBox(height: 12),
              Text(
                mainResult,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: widget.config.gradient.first,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.95, 0.95)),

        const SizedBox(height: 20),

        // Açıklama
        if (description.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              description,
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textDark.withOpacity(0.8),
                height: 1.7,
              ),
            ),
          ).animate(delay: 100.ms).fadeIn(duration: 300.ms),

        if (details.isNotEmpty) ...[
          const SizedBox(height: 20),
          // Detaylar
          ...details.asMap().entries.map((entry) {
            final idx = entry.key;
            final detail = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: widget.config.gradient.first.withOpacity(0.08),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: widget.config.gradient),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${idx + 1}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        detail,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textDark.withOpacity(0.75),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ).animate(delay: Duration(milliseconds: 150 + idx * 80)).fadeIn(duration: 300.ms);
          }),
        ],

        // Butonlar artık altta sabit (bottomNavigationBar)
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildStartButton() {
    final authProvider = context.read<AuthProvider>();
    final userTier = authProvider.membershipTier;
    final isIncluded = widget.config.isIncludedInTier(userTier);

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
          Icon(
            Icons.auto_awesome_rounded,
            size: 40,
            color: widget.config.gradient.first.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            isIncluded
                ? 'Analizi başlatmak için tıkla'
                : '${widget.overrideCoinCost ?? widget.config.coinCost} Yıldız Tozu karşılığında analizi al',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.textDark.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: widget.config.gradient),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: widget.config.gradient.first.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _generate,
                  borderRadius: BorderRadius.circular(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(widget.config.emoji, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      const Text(
                        'Analizi Başlat',
                        style: TextStyle(
                          fontSize: 16,
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
          // Reklam izle alternatifi (sadece coin gerekiyorsa)
          if (!isIncluded) ...[
            const SizedBox(height: 14),
            const Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('veya', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                ),
                Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: _generateWithAd,
                icon: const Icon(Icons.play_circle_filled, size: 20),
                label: const Text(
                  'Reklam İzle ve Ücretsiz Aç',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: widget.config.gradient.first,
                  side: BorderSide(color: widget.config.gradient.first.withOpacity(0.3)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}
