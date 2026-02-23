import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/achievement.dart';
import '../services/achievement_service.dart';

class AchievementScreen extends StatefulWidget {
  const AchievementScreen({super.key});

  @override
  State<AchievementScreen> createState() => _AchievementScreenState();
}

class _AchievementScreenState extends State<AchievementScreen> {
  final AchievementService _service = AchievementService();
  Set<String> _unlocked = {};
  Map<String, int> _progress = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final unlocked = await _service.getUnlockedAchievements();
    final progress = await _service.getAllProgress();
    if (mounted) {
      setState(() {
        _unlocked = unlocked;
        _progress = progress;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ['daily', 'quiz', 'social', 'explore'];
    final categoryNames = {
      'daily': '\ud83d\udcc5 G\u00fcnl\u00fck',
      'quiz': '\ud83d\udcda Quiz',
      'social': '\ud83d\udc65 Sosyal',
      'explore': '\ud83d\udd2e Ke\u015fif',
    };

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
          'Rozetlerim',
          style: TextStyle(
            color: Color(0xFF1E1B4B),
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4C1D95), Color(0xFF7C3AED)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        '${_unlocked.length}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Kazan\u0131lan',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                  Column(
                    children: [
                      Text(
                        '${Achievement.allAchievements.length}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Toplam',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),
            const SizedBox(height: 24),

            // Categories
            ...categories.map((category) {
              final achievements = Achievement.allAchievements
                  .where((a) => a.category == category)
                  .toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    categoryNames[category] ?? category,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E1B4B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...achievements.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final achievement = entry.value;
                    final isUnlocked = _unlocked.contains(achievement.id);
                    final progress = _progress[achievement.id] ?? 0;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isUnlocked
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isUnlocked
                              ? achievement.gradient.first.withValues(alpha: 0.3)
                              : const Color(0xFFE5E7EB),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: isUnlocked
                                  ? LinearGradient(colors: achievement.gradient)
                                  : LinearGradient(
                                      colors: [Colors.grey.shade300, Colors.grey.shade400]),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: Text(
                                isUnlocked ? achievement.emoji : '\ud83d\udd12',
                                style: const TextStyle(fontSize: 22),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  achievement.title,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: isUnlocked
                                        ? const Color(0xFF1E1B4B)
                                        : Colors.grey.shade500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  achievement.description,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                // Progress bar
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(3),
                                  child: LinearProgressIndicator(
                                    value: (progress / achievement.requiredCount)
                                        .clamp(0.0, 1.0),
                                    backgroundColor: const Color(0xFFE5E7EB),
                                    color: isUnlocked
                                        ? achievement.gradient.first
                                        : Colors.grey.shade400,
                                    minHeight: 5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '$progress/${achievement.requiredCount}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isUnlocked
                                  ? achievement.gradient.first
                                  : Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    )
                        .animate(delay: Duration(milliseconds: idx * 60))
                        .fadeIn(duration: 300.ms);
                  }),
                  const SizedBox(height: 20),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
