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
import '../services/ad_service.dart';
import '../services/share_service.dart';
import '../widgets/share_cards/coffee_share_card.dart';
import '../widgets/premium_lock_overlay.dart';
import '../screens/premium_screen.dart';
import '../theme/cosmic_page_route.dart';

class CoffeeFortuneScreen extends StatefulWidget {
  const CoffeeFortuneScreen({super.key});

  @override
  State<CoffeeFortuneScreen> createState() => _CoffeeFortuneScreenState();
}

class _CoffeeFortuneScreenState extends State<CoffeeFortuneScreen> {
  String _step = 'intro'; // intro, capture, analyzing, result
  File? _uploadedImage;
  final ImagePicker _picker = ImagePicker();
  Map<String, dynamic>? _fortuneResult;
  String? _errorMessage;
  final _adService = AdService();
  int _readingCount = 0;

  Future<void> _pickImageFromCamera() async {
    final authProvider = context.read<AuthProvider>();
    
    // Premium kontrolü
    if (!authProvider.isPremium) {
      final unlocked = await _adService.showRewardedAd(placement: 'coffee_fortune');
      if (!unlocked) {
        if (mounted) {
          _showPremiumDialog();
        }
        return;
      }
    }
    
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (image != null) {
      setState(() {
        _uploadedImage = File(image.path);
        _step = 'analyzing';
        _errorMessage = null;
      });
      await _analyzeCoffeeCup();
    }
  }

  Future<void> _pickImageFromGallery() async {
    final authProvider = context.read<AuthProvider>();
    
    // Premium kontrolü
    if (!authProvider.isPremium) {
      final unlocked = await _adService.showRewardedAd(placement: 'coffee_fortune');
      if (!unlocked) {
        if (mounted) {
          _showPremiumDialog();
        }
        return;
      }
    }
    
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (image != null) {
      setState(() {
        _uploadedImage = File(image.path);
        _step = 'analyzing';
        _errorMessage = null;
      });
      await _analyzeCoffeeCup();
    }
  }

  void _showPremiumDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Premium Özellik'),
        content: const Text('Kahve falı yorumu premium kullanıcılar için özel bir özelliktir. Reklam izleyerek veya premium üyelikle erişebilirsin.'),
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
      final apiKey = dotenv.env['GEMINI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw StateError('GEMINI_API_KEY not configured');
      }
      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: apiKey,
      );

      final imageBytes = await _uploadedImage!.readAsBytes();

      final prompt = '''
Sen deneyimli bir Türk kahve falcısısın. Zodi uygulamasında çalışıyorsun.
Fincan fotoğrafını analiz et ve kahve falı yorumu yap.

Eğer fotoğrafta kahve fincanı göremiyorsan, yine de eğlenceli ve mistik bir yorum yap.

Yorumunu aşağıdaki JSON formatında ver:
{
  "isValid": true,
  "love": "Aşk ve ilişkiler yorumu (2-3 cümle, samimi ve dürüst)",
  "career": "Kariyer ve iş yorumu (2-3 cümle)",
  "general": "Genel yorum ve tavsiyeler (2-3 cümle)",
  "health": "Sağlık ve enerji yorumu (1-2 cümle)",
  "symbols": ["Fincanda gördüğün 3-5 sembol"],
  "luckyMessage": "Kısa bir şans mesajı (1 cümle, vurucu)",
  "overallMood": "positive veya neutral veya cautious"
}
''';

      final response = await model.generateContent([
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', imageBytes),
        ]),
      ]);

      final text = response.text ?? '{}';
      final jsonMatch = RegExp(r'```json\s*([\s\S]*?)\s*```').firstMatch(text);
      final jsonStr = jsonMatch?.group(1) ?? text;

      final decoded = jsonDecode(jsonStr);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Invalid response format');
      }
      final result = decoded;

      _readingCount++;

      // İlk okumadan sonra interstitial göster
      if (_readingCount > 1) {
        _adService.trackScreenNavigation();
        _adService.showInterstitialIfNeeded();
      }

      setState(() {
        _fortuneResult = result;
        _step = 'result';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Fincan analiz edilirken bir sorun oluştu. Tekrar deneyin!';
        _step = 'capture';
      });
    }
  }

  void _shareResult() {
    if (_fortuneResult == null) return;

    final card = CoffeeShareCard(
      loveReading: _fortuneResult!['love'] ?? '',
      careerReading: _fortuneResult!['career'] ?? '',
      generalReading: _fortuneResult!['general'] ?? '',
      luckyMessage: _fortuneResult!['luckyMessage'],
      cupImage: _uploadedImage,
    );

    ShareService().shareCardWidget(
      context,
      card,
      text: '☕ Kahve Falım — Zodi\n#Zodi #KahveFalı',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                begin: 0, end: 0.05, duration: 2.seconds, curve: Curves.easeInOut)
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
              _buildStep('2️⃣', 'Fotoğrafını çek', 'fincanının içinden'),
              const SizedBox(height: 16),
              _buildStep('3️⃣', 'AI analiz etsin', 've yorumunu al!'),
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
            '💡 En iyi sonuç için fotoğrafı iyi ışıkta çekin\n🔮 AI fincanınızdaki şekilleri gerçekten analiz eder!',
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
        const SizedBox(height: 40),
        const Text(
          'Fincanın Hazır mı?',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF92400E),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Kamera ile çek veya galeriden seç',
          style: TextStyle(fontSize: 16, color: Color(0xFFD97706)),
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

        const SizedBox(height: 32),

        // Kamera butonu
        GestureDetector(
          onTap: _pickImageFromCamera,
          child: Container(
            padding: const EdgeInsets.all(36),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                  color: Colors.white.withOpacity(0.5), width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(Icons.camera_alt, size: 64, color: Colors.white)
                    .animate(onPlay: (controller) => controller.repeat())
                    .moveY(
                        begin: 0,
                        end: -10,
                        duration: 2.seconds,
                        curve: Curves.easeInOut)
                    .then()
                    .moveY(
                        begin: -10,
                        end: 0,
                        duration: 2.seconds,
                        curve: Curves.easeInOut),
                const SizedBox(height: 12),
                const Text(
                  'Kamera ile Çek',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Galeri butonu
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _pickImageFromGallery,
            icon: const Icon(Icons.photo_library, color: Color(0xFFD97706)),
            label: const Text(
              'Galeriden Seç',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFFD97706),
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Color(0xFFD97706), width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

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

  Widget _buildAnalyzingStep() {
    return Column(
      children: [
        if (_uploadedImage != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.file(
              _uploadedImage!,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
            ),
          ).animate().scale(begin: const Offset(0.8, 0.8), duration: 500.ms),
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

  Widget _buildResultStep() {
    if (_fortuneResult == null) return const SizedBox();

    final mood = _fortuneResult!['overallMood'] ?? 'neutral';
    final symbols = (_fortuneResult!['symbols'] as List<dynamic>?) ?? [];

    return Column(
      children: [
        // Fincan fotoğrafı küçük
        if (_uploadedImage != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              _uploadedImage!,
              width: 120,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
        const SizedBox(height: 16),

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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
          ).animate().fadeIn(delay: 800.ms).scale(begin: const Offset(0.9, 0.9)),
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
            onPressed: () => setState(() {
              _step = 'capture';
              _fortuneResult = null;
              _uploadedImage = null;
            }),
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
