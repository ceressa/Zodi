import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/achievement_service.dart';
import '../widgets/achievement_celebration_dialog.dart';

class AstroQuizScreen extends StatefulWidget {
  const AstroQuizScreen({super.key});

  @override
  State<AstroQuizScreen> createState() => _AstroQuizScreenState();
}

class _AstroQuizScreenState extends State<AstroQuizScreen> {
  final AchievementService _achievementService = AchievementService();
  int _currentQuestion = 0;
  int _correctAnswers = 0;
  bool _answered = false;
  int? _selectedAnswer;
  late List<_QuizQuestion> _questions;
  bool _quizComplete = false;

  @override
  void initState() {
    super.initState();
    _questions = List.from(_allQuestions)..shuffle(Random());
    _questions = _questions.take(10).toList();
  }

  void _answerQuestion(int index) {
    if (_answered) return;
    setState(() {
      _answered = true;
      _selectedAnswer = index;
      if (index == _questions[_currentQuestion].correctIndex) {
        _correctAnswers++;
      }
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (_currentQuestion < _questions.length - 1) {
        setState(() {
          _currentQuestion++;
          _answered = false;
          _selectedAnswer = null;
        });
      } else {
        _finishQuiz();
      }
    });
  }

  Future<void> _finishQuiz() async {
    setState(() => _quizComplete = true);

    // Track achievements — rozet kazanıldıysa kutla
    final unlockedIds = <String>[];
    final r1 = await _achievementService.incrementProgress('quiz_beginner');
    if (r1 != null) unlockedIds.add(r1);
    final r2 = await _achievementService.incrementProgress('quiz_master');
    if (r2 != null) unlockedIds.add(r2);
    if (_correctAnswers == _questions.length) {
      final r3 = await _achievementService.incrementProgress('perfect_score');
      if (r3 != null) unlockedIds.add(r3);
    }

    // Kazanılan rozetleri kutla
    if (mounted && unlockedIds.isNotEmpty) {
      for (final id in unlockedIds) {
        await AchievementCelebrationDialog.show(context, id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E1B4B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Astroloji Quiz',
          style: TextStyle(
            color: Color(0xFF1E1B4B),
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _quizComplete ? _buildResult() : _buildQuestion(),
      ),
    );
  }

  Widget _buildQuestion() {
    final question = _questions[_currentQuestion];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Progress
          Row(
            children: [
              Text(
                'Soru ${_currentQuestion + 1}/${_questions.length}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF7C3AED),
                ),
              ),
              const Spacer(),
              Text(
                '$_correctAnswers do\u011fru',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF10B981),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (_currentQuestion + 1) / _questions.length,
              backgroundColor: const Color(0xFFE5E7EB),
              color: const Color(0xFF7C3AED),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 32),

          // Question card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4C1D95), Color(0xFF7C3AED)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7C3AED).withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  question.emoji,
                  style: const TextStyle(fontSize: 40),
                ),
                const SizedBox(height: 16),
                Text(
                  question.question,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms),

          const SizedBox(height: 24),

          // Answers
          ...question.answers.asMap().entries.map((entry) {
            final idx = entry.key;
            final answer = entry.value;
            final isCorrect = idx == question.correctIndex;
            final isSelected = idx == _selectedAnswer;

            Color bgColor = Colors.white;
            Color borderColor = const Color(0xFF7C3AED).withValues(alpha: 0.10);
            Color textColor = const Color(0xFF1E1B4B);

            if (_answered) {
              if (isCorrect) {
                bgColor = const Color(0xFFDCFCE7);
                borderColor = const Color(0xFF10B981);
                textColor = const Color(0xFF065F46);
              } else if (isSelected && !isCorrect) {
                bgColor = const Color(0xFFFEE2E2);
                borderColor = const Color(0xFFEF4444);
                textColor = const Color(0xFF991B1B);
              }
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _answerQuestion(idx),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3E8FF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              String.fromCharCode(65 + idx),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF7C3AED),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            answer,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                        ),
                        if (_answered && isCorrect)
                          const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 24),
                        if (_answered && isSelected && !isCorrect)
                          const Icon(Icons.cancel, color: Color(0xFFEF4444), size: 24),
                      ],
                    ),
                  ),
                ),
              ),
            )
                .animate(delay: Duration(milliseconds: idx * 80))
                .fadeIn(duration: 300.ms)
                .slideX(begin: 0.05, end: 0);
          }),
        ],
      ),
    );
  }

  Widget _buildResult() {
    final percentage = (_correctAnswers / _questions.length * 100).round();
    String title;
    String emoji;
    if (percentage >= 90) {
      title = 'Kozmik Deha!';
      emoji = '\u2b50';
    } else if (percentage >= 70) {
      title = 'Y\u0131ld\u0131z \u00d6\u011frencisi!';
      emoji = '\u2b50';
    } else if (percentage >= 50) {
      title = 'Geli\u015fen Astrolog!';
      emoji = '\ud83c\udf19';
    } else {
      title = '\u00c7\u0131rak Kahin';
      emoji = '\ud83d\udcd6';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 72)),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E1B4B),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '$_correctAnswers / ${_questions.length} do\u011fru (%$percentage)',
              style: const TextStyle(
                fontSize: 18,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              height: 54,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7C3AED), Color(0xFFA78BFA)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _currentQuestion = 0;
                      _correctAnswers = 0;
                      _answered = false;
                      _selectedAnswer = null;
                      _quizComplete = false;
                      _questions = List.from(_allQuestions)..shuffle(Random());
                      _questions = _questions.take(10).toList();
                    });
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: const Center(
                    child: Text(
                      'Tekrar Dene',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Geri D\u00f6n',
                style: TextStyle(
                  color: Color(0xFF7C3AED),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.9, 0.9)),
      ),
    );
  }

  static final List<_QuizQuestion> _allQuestions = [
    const _QuizQuestion(
      question: 'Astrolojide ka\u00e7 bur\u00e7 vard\u0131r?',
      answers: ['10', '12', '14', '8'],
      correctIndex: 1,
      emoji: '\u2648',
    ),
    const _QuizQuestion(
      question: 'Hangi gezegen a\u015fk\u0131 temsil eder?',
      answers: ['Mars', 'J\u00fcpiter', 'Ven\u00fcs', 'Sat\u00fcrn'],
      correctIndex: 2,
      emoji: '\ud83d\udc95',
    ),
    const _QuizQuestion(
      question: 'Y\u00fckselen bur\u00e7 neyi temsil eder?',
      answers: ['\u0130\u00e7 d\u00fcnyan\u0131', 'D\u0131\u015f g\u00f6r\u00fcn\u00fc\u015f\u00fcn\u00fc', 'Kariyer hedeflerini', 'A\u015fk hayat\u0131n\u0131'],
      correctIndex: 1,
      emoji: '\u2b06\ufe0f',
    ),
    const _QuizQuestion(
      question: 'Merk\u00fcr retrosu ileti\u015fimde ne yapar?',
      answers: ['G\u00fc\u00e7lendirir', 'Aksat\u0131r', 'De\u011fi\u015ftirmez', 'H\u0131zland\u0131r\u0131r'],
      correctIndex: 1,
      emoji: '\u263f\ufe0f',
    ),
    const _QuizQuestion(
      question: 'Aslan burcu hangi elemente aittir?',
      answers: ['Su', 'Toprak', 'Hava', 'Ate\u015f'],
      correctIndex: 3,
      emoji: '\ud83e\udd81',
    ),
    const _QuizQuestion(
      question: 'Hangi bur\u00e7 su elementine aittir?',
      answers: ['Ko\u00e7', '\u0130kizler', 'Akrep', 'Ba\u015fak'],
      correctIndex: 2,
      emoji: '\ud83d\udca7',
    ),
    const _QuizQuestion(
      question: 'Ay burcu neyi temsil eder?',
      answers: ['Mant\u0131\u011f\u0131n\u0131', 'Duygular\u0131n\u0131', 'Kariyerini', 'Sa\u011fl\u0131\u011f\u0131n\u0131'],
      correctIndex: 1,
      emoji: '\ud83c\udf19',
    ),
    const _QuizQuestion(
      question: 'Yay burcunun y\u00f6netici gezegeni hangisidir?',
      answers: ['Mars', 'Ven\u00fcs', 'J\u00fcpiter', 'Sat\u00fcrn'],
      correctIndex: 2,
      emoji: '\u2650',
    ),
    const _QuizQuestion(
      question: 'Dolunay hangi enerjiyi temsil eder?',
      answers: ['Ba\u015flang\u0131\u00e7', 'Tamamlanma', '\u00c7at\u0131\u015fma', 'Dinlenme'],
      correctIndex: 1,
      emoji: '\ud83c\udf15',
    ),
    const _QuizQuestion(
      question: 'Kova burcu hangi elemente aittir?',
      answers: ['Su', 'Ate\u015f', 'Hava', 'Toprak'],
      correctIndex: 2,
      emoji: '\u2652',
    ),
    const _QuizQuestion(
      question: 'Terazi burcunun y\u00f6netici gezegeni?',
      answers: ['Merk\u00fcr', 'Ven\u00fcs', 'Mars', 'Nept\u00fcn'],
      correctIndex: 1,
      emoji: '\u264e',
    ),
    const _QuizQuestion(
      question: 'Hangi ev kariyer ve toplumsal stat\u00fcy\u00fc temsil eder?',
      answers: ['4. Ev', '7. Ev', '10. Ev', '12. Ev'],
      correctIndex: 2,
      emoji: '\ud83c\udfe2',
    ),
    const _QuizQuestion(
      question: 'Pl\u00fcton hangi burcun y\u00f6netici gezegenidir?',
      answers: ['Akrep', 'Bal\u0131k', 'Yenge\u00e7', 'O\u011flak'],
      correctIndex: 0,
      emoji: '\u264f',
    ),
    const _QuizQuestion(
      question: 'Yeni ay hangi enerjiyi temsil eder?',
      answers: ['Biti\u015f', 'Yeni ba\u015flang\u0131\u00e7lar', 'Kaos', 'Durgunluk'],
      correctIndex: 1,
      emoji: '\ud83c\udf11',
    ),
    const _QuizQuestion(
      question: 'Uran\u00fcs hangi burcun modern y\u00f6netici gezegenidir?',
      answers: ['Terazi', 'Kova', '\u0130kizler', 'Yay'],
      correctIndex: 1,
      emoji: '\u26a1',
    ),
    const _QuizQuestion(
      question: 'Bo\u011fa burcunun elementi nedir?',
      answers: ['Ate\u015f', 'Su', 'Toprak', 'Hava'],
      correctIndex: 2,
      emoji: '\u2649',
    ),
    const _QuizQuestion(
      question: 'Mars hangi burcun y\u00f6netici gezegenidir?',
      answers: ['Bo\u011fa', 'Aslan', 'Ko\u00e7', 'O\u011flak'],
      correctIndex: 2,
      emoji: '\u2648',
    ),
    const _QuizQuestion(
      question: 'Nept\u00fcn neyi temsil eder?',
      answers: ['Disiplin', 'Hayal g\u00fcc\u00fc ve sezgi', 'G\u00fc\u00e7 ve kontrol', '\u0130leti\u015fim'],
      correctIndex: 1,
      emoji: '\ud83d\udd2e',
    ),
    const _QuizQuestion(
      question: 'Sat\u00fcrn\'\u00fcn d\u00f6n\u00fc\u015f\u00fc yakla\u015f\u0131k ka\u00e7 y\u0131lda ger\u00e7ekle\u015fir?',
      answers: ['12 y\u0131l', '29 y\u0131l', '7 y\u0131l', '84 y\u0131l'],
      correctIndex: 1,
      emoji: '\ud83e\ude90',
    ),
    const _QuizQuestion(
      question: '7. ev astrolojide neyi temsil eder?',
      answers: ['Sa\u011fl\u0131k', '\u0130li\u015fkiler ve ortakl\u0131klar', 'Kariyer', 'Aile'],
      correctIndex: 1,
      emoji: '\ud83d\udc8d',
    ),
  ];
}

class _QuizQuestion {
  final String question;
  final List<String> answers;
  final int correctIndex;
  final String emoji;

  const _QuizQuestion({
    required this.question,
    required this.answers,
    required this.correctIndex,
    required this.emoji,
  });
}
