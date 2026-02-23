import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/firebase_service.dart';

class PersonalityQuizScreen extends StatefulWidget {
  final bool isOnboarding; // true = after signup, false = from settings

  const PersonalityQuizScreen({super.key, this.isOnboarding = true});

  @override
  State<PersonalityQuizScreen> createState() => _PersonalityQuizScreenState();
}

class _PersonalityQuizScreenState extends State<PersonalityQuizScreen> {
  int _currentQuestion = 0;
  final Map<String, String> _answers = {};
  bool _showResult = false;
  String? _personalityType;
  String? _personalityEmoji;
  String? _personalityDesc;

  static const List<_PersonalityQuestion> _questions = [
    _PersonalityQuestion(
      question: 'Bir partiye gittiğinde genelde ne yaparsın?',
      emoji: '🎉',
      options: [
        _Option(text: 'Herkesin dikkatini çekerim', trait: 'extrovert'),
        _Option(text: 'Birkaç kişiyle derin sohbet ederim', trait: 'introvert'),
        _Option(text: 'DJ\'i eleştiririm', trait: 'analytical'),
        _Option(text: 'Neden partiye geldim diye düşünürüm', trait: 'dreamer'),
      ],
    ),
    _PersonalityQuestion(
      question: 'Stresli bir gün geçirdiğinde ne yaparsın?',
      emoji: '😤',
      options: [
        _Option(text: 'Spor yapar enerji atarım', trait: 'active'),
        _Option(text: 'Müzik dinler meditasyon yaparım', trait: 'spiritual'),
        _Option(text: 'Her şeyi analiz edip plan yaparım', trait: 'analytical'),
        _Option(text: 'Arkadaşlarıma anlat anlat bitmez', trait: 'social'),
      ],
    ),
    _PersonalityQuestion(
      question: 'Aşk hayatında en çok neye önem verirsin?',
      emoji: '💕',
      options: [
        _Option(text: 'Tutku ve heyecan', trait: 'passionate'),
        _Option(text: 'Güven ve sadakat', trait: 'loyal'),
        _Option(text: 'Entelektüel uyum', trait: 'intellectual'),
        _Option(text: 'Özgürlük ve macera', trait: 'adventurous'),
      ],
    ),
    _PersonalityQuestion(
      question: 'Tatil planı yapıyorsun. Tercihin ne olur?',
      emoji: '✈️',
      options: [
        _Option(text: 'Egzotik bir ülkeye macera turu', trait: 'adventurous'),
        _Option(text: 'Sahilde kitap okumak', trait: 'peaceful'),
        _Option(text: 'Kültürel şehir turu', trait: 'intellectual'),
        _Option(text: 'Arkadaşlarla festival', trait: 'social'),
      ],
    ),
    _PersonalityQuestion(
      question: 'Hayattaki en büyük motivasyonun ne?',
      emoji: '🎯',
      options: [
        _Option(text: 'Başarı ve tanınmak', trait: 'ambitious'),
        _Option(text: 'İç huzur ve denge', trait: 'spiritual'),
        _Option(text: 'Sevdiklerimi mutlu etmek', trait: 'caring'),
        _Option(text: 'Yeni şeyler keşfetmek', trait: 'curious'),
      ],
    ),
  ];

  void _selectOption(String trait) {
    _answers[_questions[_currentQuestion].emoji] = trait;

    if (_currentQuestion < _questions.length - 1) {
      setState(() => _currentQuestion++);
    } else {
      _calculateResult();
    }
  }

  void _calculateResult() {
    // Count traits
    final traitCounts = <String, int>{};
    for (final trait in _answers.values) {
      traitCounts[trait] = (traitCounts[trait] ?? 0) + 1;
    }

    // Find dominant trait
    final dominantTrait = traitCounts.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;

    // Map to personality type
    final Map<String, Map<String, String>> personalityMap = {
      'extrovert': {'type': 'Parlayan Yıldız', 'emoji': '⭐', 'desc': 'Enerjin bulaşıcı, karizma taşıyorsun! Güneş gibi etrafına ışık saçıyorsun. İnsanlar seni sevmeden edemiyor.'},
      'introvert': {'type': 'Gizemli Ay', 'emoji': '🌙', 'desc': 'Derinlikli ve sezgisel bir ruha sahipsin. Az konuşur ama çok şey anlatırsın. İç dünyan bir okyanus kadar derin.'},
      'analytical': {'type': 'Kozmik Stratejist', 'emoji': '🧠', 'desc': 'Keskin zekân ve analitik bakış açınla öne çıkıyorsun. Her şeyi mantık süzgecinden geçirirsin ama kalbini de dinlemeyi unutma!'},
      'dreamer': {'type': 'Yıldız Gezgini', 'emoji': '🌌', 'desc': 'Hayal gücün sınırsız, ruhun özgür! Bu dünya sana dar geliyor çünkü yıldızlara aitsin. Yaratıcılığın süper gücün.'},
      'active': {'type': 'Ateş Savaşçısı', 'emoji': '🔥', 'desc': 'Durağanlığa tahammülün yok, sürekli hareket halinde olmalısın! Enerjin tükenmez, azmin kırılmaz.'},
      'spiritual': {'type': 'Kozmik Bilge', 'emoji': '🔮', 'desc': 'Evrenle derin bir bağın var. Sezgilerin güçlü, iç sesin çok net. Ruhani bir yolculuğun tam ortasındasın.'},
      'social': {'type': 'Yıldız Elçisi', 'emoji': '💫', 'desc': 'İnsanları bir araya getirme yeteneğin benzersiz! Sosyal enerjin eksiksiz, bağ kurma becerilerin muhteşem.'},
      'passionate': {'type': 'Ateş Kalbi', 'emoji': '❤️‍🔥', 'desc': 'Tutkuyla yanıp tutuşan bir kalbin var! Sevdiğin zaman sonuna kadar seversin. Yoğun duygular senin doğan.'},
      'loyal': {'type': 'Sadık Kalkan', 'emoji': '🛡️', 'desc': 'Güvenilirliğin ve sadakatin rakipsiz. Sevdiklerini korumak için her şeyi yaparsın. Kayalar gibi sağlam bir temelin var.'},
      'intellectual': {'type': 'Bilge Kaşif', 'emoji': '📚', 'desc': 'Bilgi senin süper gücün! Her şeyi sorgulamak ve öğrenmek doğanızda var. Zihinsel uyum senin için en önemli bağ.'},
      'adventurous': {'type': 'Kozmik Kaşif', 'emoji': '🚀', 'desc': 'Macera senin ikinci adın! Rutin seni öldürür, yenilik seni diriltir. Keşfetmek için doğdun.'},
      'peaceful': {'type': 'Huzur Meleği', 'emoji': '🕊️', 'desc': 'İç huzurun önceliğin, dengeyi her yerde arıyorsun. Sakin enerjin çevrene de yayılıyor. Şifa veren bir auran var.'},
      'ambitious': {'type': 'Yıldız Avcısı', 'emoji': '🎯', 'desc': 'Hedeflerin büyük, azmin sarsılmaz! Zirveye çıkmak için doğdun. Başarı senin doğal halin.'},
      'caring': {'type': 'Işık Savaşçısı', 'emoji': '🌸', 'desc': 'Sevgin sonsuz, şefkatin derin. Başkalarını mutlu etmek seni mutlu ediyor. Kalbin bir pusula gibi doğru yolu gösterir.'},
      'curious': {'type': 'Kozmik Meraklı', 'emoji': '🔭', 'desc': 'Merak motorun, sorular yakıtın! Her yeni keşif seni hayata bağlıyor. Öğrenmeye olan tutkunla fark yaratıyorsun.'},
    };

    final result = personalityMap[dominantTrait] ?? personalityMap['dreamer']!;

    setState(() {
      _personalityType = result['type'];
      _personalityEmoji = result['emoji'];
      _personalityDesc = result['desc'];
      _showResult = true;
    });

    // Save to Firebase
    _saveResult(result['type']!, dominantTrait);
  }

  Future<void> _saveResult(String personalityType, String dominantTrait) async {
    try {
      final firebaseService = FirebaseService();
      if (firebaseService.isAuthenticated) {
        await firebaseService.updateUserField('personalityType', personalityType);
        await firebaseService.updateUserField('dominantTrait', dominantTrait);
      }
    } catch (e) {
      debugPrint('Error saving personality: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5FF),
      body: SafeArea(
        child: _showResult ? _buildResult() : _buildQuiz(),
      ),
    );
  }

  Widget _buildQuiz() {
    final question = _questions[_currentQuestion];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Skip button (only in onboarding)
          if (widget.isOnboarding)
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Atla',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

          const SizedBox(height: 20),

          // Progress dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_questions.length, (i) {
              return Container(
                width: i == _currentQuestion ? 24 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: i <= _currentQuestion
                      ? const Color(0xFF7C3AED)
                      : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),

          const SizedBox(height: 40),

          // Emoji
          Text(question.emoji, style: const TextStyle(fontSize: 56))
              .animate().scale(duration: 400.ms, curve: Curves.elasticOut),

          const SizedBox(height: 24),

          // Question
          Text(
            question.question,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E1B4B),
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(duration: 400.ms),

          const SizedBox(height: 32),

          // Options
          ...question.options.asMap().entries.map((entry) {
            final idx = entry.key;
            final option = entry.value;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _selectOption(option.trait),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF7C3AED).withValues(alpha: 0.12),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      option.text,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E1B4B),
                      ),
                    ),
                  ),
                ),
              ),
            )
                .animate(delay: Duration(milliseconds: idx * 80))
                .fadeIn(duration: 300.ms)
                .slideY(begin: 0.1, end: 0);
          }),
        ],
      ),
    );
  }

  Widget _buildResult() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),

          // Personality emoji
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7C3AED), Color(0xFFA78BFA)],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7C3AED).withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: Text(
                _personalityEmoji ?? '🌟',
                style: const TextStyle(fontSize: 48),
              ),
            ),
          ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),

          const SizedBox(height: 24),

          Text(
            _personalityType ?? '',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E1B4B),
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF7C3AED).withValues(alpha: 0.10),
              ),
            ),
            child: Text(
              _personalityDesc ?? '',
              style: const TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Color(0xFF475569),
              ),
              textAlign: TextAlign.center,
            ),
          ).animate().fadeIn(delay: 400.ms, duration: 400.ms),

          const SizedBox(height: 32),

          // Continue button
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7C3AED), Color(0xFFA78BFA)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7C3AED).withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(16),
                child: Center(
                  child: Text(
                    widget.isOnboarding ? 'Keşfetmeye Başla!' : 'Tamam',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                    ),
                  ),
                ),
              ),
            ),
          ).animate().fadeIn(delay: 600.ms, duration: 400.ms),
        ],
      ),
    );
  }
}

class _PersonalityQuestion {
  final String question;
  final String emoji;
  final List<_Option> options;

  const _PersonalityQuestion({
    required this.question,
    required this.emoji,
    required this.options,
  });
}

class _Option {
  final String text;
  final String trait;

  const _Option({required this.text, required this.trait});
}
