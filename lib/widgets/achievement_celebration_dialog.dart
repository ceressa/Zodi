import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import '../models/achievement.dart';

/// Rozet kazanıldığında gösterilen kutlama popup'ı
class AchievementCelebrationDialog extends StatefulWidget {
  final Achievement achievement;

  const AchievementCelebrationDialog({super.key, required this.achievement});

  /// Rozet kazanıldığında bu metodu çağır
  static Future<void> show(BuildContext context, String achievementId) async {
    final achievement = Achievement.allAchievements.firstWhere(
      (a) => a.id == achievementId,
      orElse: () => Achievement.allAchievements.first,
    );

    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Rozet Kutlama',
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) {
        return AchievementCelebrationDialog(achievement: achievement);
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.elasticOut),
          child: FadeTransition(
            opacity: anim1,
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<AchievementCelebrationDialog> createState() =>
      _AchievementCelebrationDialogState();
}

class _AchievementCelebrationDialogState
    extends State<AchievementCelebrationDialog> {
  late final ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    // Hemen confetti başlat
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _confettiController.play();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Confetti
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            numberOfParticles: 30,
            maxBlastForce: 20,
            minBlastForce: 8,
            emissionFrequency: 0.05,
            gravity: 0.15,
            colors: [
              ...widget.achievement.gradient,
              const Color(0xFFD4AF37),
              const Color(0xFFF9D976),
              Colors.white,
            ],
          ),
        ),

        // Dialog
        Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.fromLTRB(28, 36, 28, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: widget.achievement.gradient.first.withOpacity(0.3),
                    blurRadius: 40,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Rozet ikonu
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: widget.achievement.gradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: widget.achievement.gradient.first.withOpacity(0.4),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        widget.achievement.emoji,
                        style: const TextStyle(fontSize: 44),
                      ),
                    ),
                  )
                      .animate()
                      .scale(
                        begin: const Offset(0.0, 0.0),
                        end: const Offset(1.0, 1.0),
                        duration: 600.ms,
                        curve: Curves.elasticOut,
                      ),

                  const SizedBox(height: 20),

                  // Tebrikler
                  const Text(
                    '🎉 Tebrikler!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1E1B4B),
                    ),
                  ).animate(delay: 200.ms).fadeIn(duration: 300.ms),

                  const SizedBox(height: 8),

                  // Rozet adı
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: widget.achievement.gradient,
                    ).createShader(bounds),
                    child: Text(
                      widget.achievement.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ).animate(delay: 300.ms).fadeIn(duration: 300.ms),

                  const SizedBox(height: 6),

                  // Açıklama
                  Text(
                    widget.achievement.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color(0xFF1E1B4B).withOpacity(0.6),
                    ),
                    textAlign: TextAlign.center,
                  ).animate(delay: 400.ms).fadeIn(duration: 300.ms),

                  const SizedBox(height: 8),

                  // Rozet kazanıldı etiketi
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          widget.achievement.gradient.first.withOpacity(0.1),
                          widget.achievement.gradient.last.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: widget.achievement.gradient.first.withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      'Yeni Rozet Kazanıldı!',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: widget.achievement.gradient.first,
                      ),
                    ),
                  ).animate(delay: 500.ms).fadeIn(duration: 300.ms),

                  const SizedBox(height: 24),

                  // Kapat butonu
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: widget.achievement.gradient),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          borderRadius: BorderRadius.circular(16),
                          child: const Center(
                            child: Text(
                              'Harika! ✨',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ).animate(delay: 600.ms).fadeIn(duration: 300.ms),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
