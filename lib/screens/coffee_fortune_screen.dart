import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../constants/colors.dart';

class CoffeeFortuneScreen extends StatefulWidget {
  const CoffeeFortuneScreen({super.key});

  @override
  State<CoffeeFortuneScreen> createState() => _CoffeeFortuneScreenState();
}

class _CoffeeFortuneScreenState extends State<CoffeeFortuneScreen> {
  String _step = 'intro'; // intro, capture, analyzing, result
  File? _uploadedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _uploadedImage = File(image.path);
        _step = 'analyzing';
      });
      await Future.delayed(const Duration(seconds: 3));
      setState(() {
        _step = 'result';
      });
    }
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
          const Spacer(),
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
                begin: 0.05, end: -0.05, duration: 2.seconds, curve: Curves.easeInOut),
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
          'Fincanındaki sırrı keşfet ✨',
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
              _buildStep('3️⃣', 'Yorumunu al', 'hemen!'),
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
            '💡 En iyi sonuç için fotoğrafı iyi ışıkta çekin',
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
          child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
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
          'Fotoğrafını yükle başlayalım',
          style: TextStyle(fontSize: 16, color: Color(0xFFD97706)),
        ),
        const SizedBox(height: 32),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            padding: const EdgeInsets.all(48),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.5), width: 4),
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
                const Icon(Icons.camera_alt, size: 80, color: Colors.white)
                    .animate(onPlay: (controller) => controller.repeat())
                    .moveY(begin: 0, end: -10, duration: 2.seconds, curve: Curves.easeInOut)
                    .then()
                    .moveY(begin: -10, end: 0, duration: 2.seconds, curve: Curves.easeInOut),
                const SizedBox(height: 16),
                const Text(
                  'Fotoğraf Yükle',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'veya kamera ile çek',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => setState(() => _step = 'intro'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Color(0xFFD97706)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Geri Dön',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFFD97706),
              ),
            ),
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
              fit: BoxFit.cover,
            ),
          )
              .animate()
              .scale(begin: const Offset(0.8, 0.8), duration: 500.ms),
        const SizedBox(height: 32),
        const Icon(Icons.refresh, size: 64, color: Color(0xFFD97706))
            .animate(onPlay: (controller) => controller.repeat())
            .rotate(duration: 2.seconds),
        const SizedBox(height: 16),
        const Text(
          'Falın Yorumlanıyor...',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF92400E),
          ),
        ),
        const SizedBox(height: 24),
        ...[
          'Şekiller analiz ediliyor',
          'Semboller yorumlanıyor',
          'Gelecek görülüyor',
        ]
            .asMap()
            .entries
            .map((entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    '${entry.value}...',
                    style: const TextStyle(color: Color(0xFFD97706)),
                  )
                      .animate(delay: Duration(milliseconds: entry.key * 500))
                      .fadeIn(),
                ))
            .toList(),
      ],
    );
  }

  Widget _buildResultStep() {
    return Column(
      children: [
        const Icon(Icons.check_circle, size: 64, color: Colors.green)
            .animate()
            .scale(begin: const Offset(0, 0), duration: 500.ms, curve: Curves.elasticOut),
        const SizedBox(height: 16),
        const Text(
          'Falın Hazır! ✨',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF92400E),
          ),
        ),
        const SizedBox(height: 32),
        _buildResultCard(
          '💕',
          'Aşk & İlişkiler',
          'Kalbinde büyük bir değişim kapıda! Yakında beklenmedik bir rastlantı hayatını değiştirebilir. Kalbinin sesini dinle ve içinden geleni yap.',
          const [Color(0xFFF472B6), Color(0xFFBE185D)],
        ),
        const SizedBox(height: 16),
        _buildResultCard(
          '💼',
          'Kariyer & İş',
          'İş hayatında yeni bir fırsat beliriyor. Üstündeki baskı azalacak ve yeteneklerini gösterebileceğin bir dönem başlıyor.',
          const [Color(0xFF38BDF8), Color(0xFF3B82F6)],
        ),
        const SizedBox(height: 16),
        _buildResultCard(
          '✨',
          'Genel',
          'Sabır ve kararlılığın meyvelerini toplamaya başlayacaksın. Kendine güven, yıldızlar senin yanında!',
          const [Color(0xFFA78BFA), Color(0xFF7C3AED)],
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => setState(() => _step = 'intro'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.refresh),
                SizedBox(width: 8),
                Text('Tekrar Baktır', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Color(0xFFD97706)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Paylaş',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFD97706),
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colors[0].withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
              height: 1.5,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0);
  }
}