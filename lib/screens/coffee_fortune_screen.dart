import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/coin_provider.dart';
import '../config/membership_config.dart';
import '../services/ad_service.dart';
import '../services/share_service.dart';
import '../services/activity_log_service.dart';
import '../widgets/share_cards/coffee_share_card.dart';
import '../screens/premium_screen.dart';
import '../theme/cosmic_page_route.dart';

class CoffeeFortuneScreen extends StatefulWidget {
  const CoffeeFortuneScreen({super.key});

  @override
  State<CoffeeFortuneScreen> createState() => _CoffeeFortuneScreenState();
}

class _CoffeeFortuneScreenState extends State<CoffeeFortuneScreen> {
  String _step = 'intro'; // intro, capture, analyzing, result
  // 4 slot: 0=fincan iç (düz), 1=fincan iç (yan), 2=fincan iç (diğer yan), 3=tabaktaki telve
  final List<File?> _images = [null, null, null, null];
  static const List<String> _slotLabels = [
    'Fincan İç\n(Düz Bakış)',
    'Fincan İç\n(Yan Açı)',
    'Fincan İç\n(Diğer Yan)',
    'Tabak\n(Telve)',
  ];
  static const List<IconData> _slotIcons = [
    Icons.coffee,
    Icons.rotate_left,
    Icons.rotate_right,
    Icons.circle_outlined,
  ];
  final ImagePicker _picker = ImagePicker();
  Map<String, dynamic>? _fortuneResult;
  String? _errorMessage;
  final _adService = AdService();
  final _activityLog = ActivityLogService();
  int _readingCount = 0;

  int get _imageCount => _images.where((f) => f != null).length;

  @override
  void initState() {
    super.initState();
    _adService.loadRewardedAd();
  }

  Future<void> _pickImageForSlot(int slot, ImageSource source) async {
    final XFile? image = await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (image != null && mounted) {
      setState(() {
        _images[slot] = File(image.path);
        _errorMessage = null;
      });
    }
  }

  void _showImageSourceDialog(int slot) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFEF3C7),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _slotLabels[slot].replaceAll('\n', ' '),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF92400E),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildSourceButton(
                    icon: Icons.camera_alt,
                    label: 'Kamera',
                    onTap: () {
                      Navigator.pop(ctx);
                      _pickImageForSlot(slot, ImageSource.camera);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSourceButton(
                    icon: Icons.photo_library,
                    label: 'Galeri',
                    onTap: () {
                      Navigator.pop(ctx);
                      _pickImageForSlot(slot, ImageSource.gallery);
                    },
                  ),
                ),
              ],
            ),
            if (_images[slot] != null) ...[
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  setState(() => _images[slot] = null);
                },
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: const Text('Fotoğrafı Kaldır',
                    style: TextStyle(color: Colors.red)),
              ),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF59E0B).withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF59E0B)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: const Color(0xFFD97706)),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Color(0xFF92400E))),
          ],
        ),
      ),
    );
  }

  Future<void> _startAnalysis() async {
    if (_imageCount == 0) {
      setState(() => _errorMessage = 'En az 1 fotoğraf eklemelisin!');
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final tier = authProvider.membershipTier;

    // Premium/Ad Gate
    if (tier != MembershipTier.elmas && tier != MembershipTier.platinyum) {
      // Altın tier: 5 Yıldız Tozu VEYA reklam
      if (tier == MembershipTier.altin) {
        final coinProvider = context.read<CoinProvider>();
        if (coinProvider.balance >= 5) {
          final useCoin = await _showCoinOrAdDialog(5);
          if (useCoin == null) return; // iptal
          if (useCoin) {
            await coinProvider.spendCoins(5, 'coffee_fortune');
          } else {
            final unlocked =
                await _adService.showRewardedAd(placement: 'coffee_fortune');
            if (!unlocked) {
              if (mounted) _showPremiumDialog();
              return;
            }
          }
        } else {
          final unlocked =
              await _adService.showRewardedAd(placement: 'coffee_fortune');
          if (!unlocked) {
            if (mounted) _showPremiumDialog();
            return;
          }
        }
      } else {
        // Standard: reklam zorunlu
        final unlocked =
            await _adService.showRewardedAd(placement: 'coffee_fortune');
        if (!unlocked) {
          if (mounted) _showPremiumDialog();
          return;
        }
      }
    }

    setState(() {
      _step = 'analyzing';
      _errorMessage = null;
    });
    await _analyzeCoffeeCup();
  }

  Future<bool?> _showCoinOrAdDialog(int coinCost) async {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFFEF3C7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Kahve Falı',
            style: TextStyle(
                color: Color(0xFF92400E), fontWeight: FontWeight.bold)),
        content: Text(
            '$coinCost Yıldız Tozu harcayarak veya reklam izleyerek falına baktırabilirsin.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: const Text('İptal'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(ctx, false),
            icon: const Icon(Icons.play_circle_outline, size: 18),
            label: const Text('Reklam İzle'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD97706),
              foregroundColor: Colors.white,
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(ctx, true),
            icon: const Text('🪙', style: TextStyle(fontSize: 16)),
            label: Text('$coinCost Yıldız Tozu'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFB800),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showPremiumDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Premium Özellik'),
        content: const Text(
            'Kahve falı yorumu için reklam izle veya premium üyeliğe geç.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                CosmicBottomSheetRoute(page: const PremiumScreen()),
              );
            },
            child: const Text('Premium\'a Geç'),
          ),
        ],
      ),
    );
  }

  Future<void> _analyzeCoffeeCup() async {
    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: apiKey,
      );

      // Tüm resimleri DataPart olarak hazırla
      final parts = <Part>[];

      final prompt = '''
Sen deneyimli bir Türk kahve falcısısın. Zodi uygulamasında çalışıyorsun.
Kullanıcı kahve fincanının farklı açılardan fotoğraflarını ve/veya tabaktaki telveyi gönderdi.

ÖNEMLİ KURALLAR:
1. TÜM görselleri birlikte analiz et. Sadece bir açıdan bakma, tüm görsellerdeki şekilleri birleştirerek kapsamlı bir yorum yap.
2. Eğer fotoğraflarda kahve fincanı/telve GÖREMİYORSAN → "isValid": false yap ve "warningMessage"'a eğlenceli bir uyarı yaz.
3. Uygunsuz/NSFW içerik → "isValid": false, "warningMessage": "Hmm, bu pek kahve falına uygun bir görüntü değil. Fincanını getir, sırlarını anlatayım. ☕"
4. Alakasız resim (manzara, yemek, selfie vs.) → "isValid": false, "warningMessage": eğlenceli/mizahi bir uyarı. Örnek: "Güzel manzara ama ben kahve falcısıyım, turist rehberi değil! ☕"
5. Kaba/hakaret içeren el işareti → "isValid": false, "warningMessage": "Ay canım, bu el işaretleriyle fal bakmam ben! Fincanını düzgünce göster, sırlarını açayım. ☕😄"

Eğer geçerli bir kahve fincanı/telve görüyorsan, detaylı yorum yap.

Yorumunu MUTLAKA aşağıdaki JSON formatında ver:
{
  "isValid": true/false,
  "warningMessage": "Eğer isValid false ise burada eğlenceli uyarı mesajı (Türkçe)",
  "love": "Aşk ve ilişkiler yorumu (2-3 cümle, samimi ve dürüst)",
  "career": "Kariyer ve iş yorumu (2-3 cümle)",
  "general": "Genel yorum ve tavsiyeler (2-3 cümle)",
  "health": "Sağlık ve enerji yorumu (1-2 cümle)",
  "symbols": ["Fincanda gördüğün 3-5 sembol"],
  "luckyMessage": "Kısa bir şans mesajı (1 cümle, vurucu)",
  "overallMood": "positive veya neutral veya cautious"
}
''';

      parts.add(TextPart(prompt));

      for (int i = 0; i < _images.length; i++) {
        if (_images[i] != null) {
          final bytes = await _images[i]!.readAsBytes();
          parts.add(DataPart('image/jpeg', bytes));
        }
      }

      final response = await model.generateContent([Content.multi(parts)]);

      final text = response.text ?? '{}';
      final jsonMatch =
          RegExp(r'```json\s*([\s\S]*?)\s*```').firstMatch(text);
      final jsonStr = jsonMatch?.group(1) ?? text;

      Map<String, dynamic> result;
      try {
        result = jsonDecode(jsonStr) as Map<String, dynamic>;
      } catch (e) {
        debugPrint('❌ Coffee fortune JSON parse error: $e');
        result = {
          'isValid': false,
          'warningMessage':
              'Falını okurken bir sorun oluştu. Tekrar dener misin? ☕',
        };
      }

      _readingCount++;

      // İlk okumadan sonra interstitial göster
      if (_readingCount > 1) {
        _adService.trackScreenNavigation();
        _adService.showInterstitialIfNeeded();
      }

      if (!mounted) return;

      // isValid kontrolü
      final isValid = result['isValid'] ?? true;
      if (!isValid) {
        setState(() {
          _fortuneResult = result;
          _step = 'invalid';
        });
      } else {
        setState(() {
          _fortuneResult = result;
          _step = 'result';
        });
        _activityLog.logCoffeeFortune();
      }
    } catch (e) {
      debugPrint('❌ Coffee fortune analysis error: $e');
      if (mounted) {
        setState(() {
          _errorMessage =
              'Fincan analiz edilirken bir sorun oluştu. Tekrar deneyin!';
          _step = 'capture';
        });
      }
    }
  }

  void _shareResult() {
    if (_fortuneResult == null) return;

    final card = CoffeeShareCard(
      loveReading: _fortuneResult!['love'] ?? '',
      careerReading: _fortuneResult!['career'] ?? '',
      generalReading: _fortuneResult!['general'] ?? '',
      luckyMessage: _fortuneResult!['luckyMessage'],
      cupImage: _images.firstWhere((f) => f != null, orElse: () => null),
    );

    ShareService().shareCardWidget(
      context,
      card,
      text: '☕ Kahve Falım — Astro Dozi\n#AstroDozi #KahveFalı',
    );
  }

  void _resetAll() {
    setState(() {
      _step = 'capture';
      _fortuneResult = null;
      _errorMessage = null;
      for (int i = 0; i < _images.length; i++) {
        _images[i] = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5FF),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFEF3C7), Color(0xFFFED7AA), Color(0xFFFEF08A)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: _buildContent(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.brown),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              'Kahve Falı',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF92400E),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_step) {
      case 'intro':
        return _buildIntroStep();
      case 'capture':
        return _buildCaptureStep();
      case 'analyzing':
        return _buildAnalyzingStep();
      case 'result':
        return _buildResultStep();
      case 'invalid':
        return _buildInvalidStep();
      default:
        return _buildIntroStep();
    }
  }

  Widget _buildIntroStep() {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Text(
          '☕',
          style: TextStyle(fontSize: 64),
        )
            .animate(onPlay: (controller) => controller.repeat())
            .rotate(
                begin: 0,
                end: 0.05,
                duration: 2.seconds,
                curve: Curves.easeInOut)
            .then()
            .rotate(
                begin: 0.05,
                end: -0.05,
                duration: 2.seconds,
                curve: Curves.easeInOut),
        const SizedBox(height: 16),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFD97706), Color(0xFFF59E0B)],
          ).createShader(bounds),
          child: const Text(
            'Kahve Falı',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'AI destekli gerçek fincan analizi ✨',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF92400E),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildStep('1️⃣', 'Kahveni iç', 've fincanını ters çevir'),
              const SizedBox(height: 16),
              _buildStep('2️⃣', 'Farklı açılardan fotoğraf çek',
                  '(1-4 fotoğraf)'),
              const SizedBox(height: 16),
              _buildStep('3️⃣', 'AI tüm açıları analiz etsin',
                  've kapsamlı yorumunu al!'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => setState(() => _step = 'capture'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 8,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.coffee),
                SizedBox(width: 8),
                Text(
                  'Falıma Bakılsın',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 8),
                Icon(Icons.auto_awesome),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFED7AA),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF59E0B), width: 2),
          ),
          child: const Text(
            '💡 Birden fazla açıdan fotoğraf yükle, daha kapsamlı yorum al!\n🔮 AI fincanındaki şekilleri gerçekten analiz eder!',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF92400E),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildStep(String emoji, String title, String subtitle) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: Color(0xFFFED7AA),
            shape: BoxShape.circle,
          ),
          child:
              Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              children: [
                TextSpan(
                  text: title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: ' $subtitle'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCaptureStep() {
    return Column(
      children: [
        const SizedBox(height: 16),
        const Text(
          'Fincan Fotoğrafları',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF92400E),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'En az 1 fotoğraf ekle (4\'e kadar ekleyebilirsin)',
          style: TextStyle(fontSize: 14, color: const Color(0xFFD97706).withOpacity(0.8)),
        ),

        if (_errorMessage != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
        ],

        const SizedBox(height: 20),

        // 2x2 Grid for 4 image slots
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
          children: List.generate(4, (index) => _buildImageSlot(index)),
        ),

        const SizedBox(height: 24),

        // Analiz Et butonu
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _imageCount > 0 ? _startAnalysis : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 6,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.auto_awesome),
                const SizedBox(width: 8),
                Text(
                  _imageCount > 0
                      ? 'Falımı Oku ($_imageCount fotoğraf)'
                      : 'Fotoğraf Ekle',
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        TextButton(
          onPressed: () => setState(() => _step = 'intro'),
          child: const Text(
            'Geri Dön',
            style: TextStyle(color: Color(0xFFD97706)),
          ),
        ),
      ],
    );
  }

  Widget _buildImageSlot(int index) {
    final file = _images[index];
    final hasImage = file != null;

    return GestureDetector(
      onTap: () => _showImageSourceDialog(index),
      child: Container(
        decoration: BoxDecoration(
          color: hasImage
              ? Colors.transparent
              : Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: hasImage
                ? const Color(0xFFF59E0B)
                : const Color(0xFFD97706).withOpacity(0.3),
            width: hasImage ? 3 : 2,
          ),
          boxShadow: hasImage
              ? [
                  BoxShadow(
                    color: const Color(0xFFF59E0B).withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: hasImage
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(file, fit: BoxFit.cover),
                    // Overlay with label
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                        child: Text(
                          _slotLabels[index].replaceAll('\n', ' '),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    // Değiştir ikonu
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit,
                            size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_slotIcons[index],
                        size: 32,
                        color: const Color(0xFFD97706).withOpacity(0.5)),
                    const SizedBox(height: 8),
                    Text(
                      _slotLabels[index],
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF92400E).withOpacity(0.6),
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Icon(Icons.add_circle_outline,
                        size: 20,
                        color: const Color(0xFFD97706).withOpacity(0.4)),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildAnalyzingStep() {
    // İlk yüklenen resmi göster
    final firstImage = _images.firstWhere((f) => f != null, orElse: () => null);

    return Column(
      children: [
        if (firstImage != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.file(
              firstImage,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
          ).animate().scale(begin: const Offset(0.8, 0.8), duration: 500.ms),
        if (_imageCount > 1) ...[
          const SizedBox(height: 8),
          Text(
            '$_imageCount fotoğraf analiz ediliyor...',
            style: const TextStyle(
                fontSize: 13,
                color: Color(0xFFD97706),
                fontWeight: FontWeight.w600),
          ),
        ],
        const SizedBox(height: 32),
        const Text('🔮', style: TextStyle(fontSize: 64))
            .animate(onPlay: (controller) => controller.repeat())
            .rotate(duration: 3.seconds),
        const SizedBox(height: 16),
        const Text(
          'Fincanın Okunuyor...',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF92400E),
          ),
        ),
        const SizedBox(height: 24),
        ...[
          'Şekiller tespit ediliyor',
          'Tüm açılar karşılaştırılıyor',
          'Semboller yorumlanıyor',
          'Kozmik bağlantı kuruluyor',
          'Falın hazırlanıyor',
        ]
            .asMap()
            .entries
            .map((entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFD97706),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${entry.value}...',
                        style: const TextStyle(color: Color(0xFFD97706)),
                      ),
                    ],
                  )
                      .animate(delay: Duration(milliseconds: entry.key * 800))
                      .fadeIn(),
                )),
      ],
    );
  }

  /// Geçersiz resim (kahve fincanı değil) sonuç ekranı
  Widget _buildInvalidStep() {
    final warning =
        _fortuneResult?['warningMessage'] ?? 'Kahve fincanı bulamadım! ☕';

    return Column(
      children: [
        const SizedBox(height: 40),
        const Text('🤔', style: TextStyle(fontSize: 72))
            .animate()
            .shake(duration: 600.ms),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(24),
            border:
                Border.all(color: const Color(0xFFF59E0B).withOpacity(0.5)),
          ),
          child: Column(
            children: [
              const Text(
                'Hmm, Bir Sorun Var!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF92400E),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                warning,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFFD97706),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _resetAll,
            icon: const Icon(Icons.camera_alt),
            label: const Text('Tekrar Dene',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Ana Sayfaya Dön',
              style: TextStyle(color: Color(0xFFD97706))),
        ),
      ],
    );
  }

  Widget _buildResultStep() {
    if (_fortuneResult == null) return const SizedBox();

    final mood = _fortuneResult!['overallMood'] ?? 'neutral';
    final symbols = (_fortuneResult!['symbols'] as List<dynamic>?) ?? [];

    return Column(
      children: [
        // Fincan fotoğrafları küçük row
        if (_imageCount > 0) ...[
          SizedBox(
            height: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _images
                  .where((f) => f != null)
                  .map((f) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(f!, width: 70, height: 70,
                              fit: BoxFit.cover),
                        ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 16),
        ],

        Text(
          mood == 'positive'
              ? '🌟 Harika bir fincan!'
              : mood == 'cautious'
                  ? '⚠️ Dikkatli ol!'
                  : '✨ Falın Hazır!',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF92400E),
          ),
        ).animate().fadeIn().scale(begin: const Offset(0.8, 0.8)),

        // Semboller
        if (symbols.isNotEmpty) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: symbols.map((s) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFF59E0B)),
                ),
                child: Text(
                  s.toString(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF92400E),
                  ),
                ),
              );
            }).toList(),
          ),
        ],

        const SizedBox(height: 24),

        // Sonuç kartları
        _buildResultCard(
          '💕',
          'Aşk & İlişkiler',
          _fortuneResult!['love'] ?? '',
          const [Color(0xFFF472B6), Color(0xFFBE185D)],
        ),
        const SizedBox(height: 12),
        _buildResultCard(
          '💼',
          'Kariyer & İş',
          _fortuneResult!['career'] ?? '',
          const [Color(0xFF38BDF8), Color(0xFF3B82F6)],
        ),
        const SizedBox(height: 12),
        _buildResultCard(
          '💚',
          'Sağlık & Enerji',
          _fortuneResult!['health'] ?? '',
          const [Color(0xFF34D399), Color(0xFF059669)],
        ),
        const SizedBox(height: 12),
        _buildResultCard(
          '✨',
          'Genel Yorum',
          _fortuneResult!['general'] ?? '',
          const [Color(0xFFA78BFA), Color(0xFF7C3AED)],
        ),

        // Şans mesajı
        if (_fortuneResult!['luckyMessage'] != null) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFF59E0B)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text('🍀', style: TextStyle(fontSize: 28)),
                const SizedBox(height: 8),
                Text(
                  _fortuneResult!['luckyMessage'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ).animate().fadeIn(delay: 800.ms).scale(
              begin: const Offset(0.9, 0.9)),
        ],

        const SizedBox(height: 24),

        // Paylaş butonu
        SizedBox(
          width: double.infinity,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFD97706), Color(0xFFF59E0B)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _shareResult,
                borderRadius: BorderRadius.circular(16),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.share, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Falımı Paylaş',
                        style: TextStyle(
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
          ),
        ),

        const SizedBox(height: 12),

        // Tekrar baktır
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _resetAll,
            icon: const Icon(Icons.refresh, color: Color(0xFFD97706)),
            label: const Text(
              'Yeni Fal Baktır',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFD97706),
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Color(0xFFD97706)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultCard(
      String emoji, String title, String description, List<Color> colors) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors[0].withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.95),
              height: 1.5,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0);
  }
}
