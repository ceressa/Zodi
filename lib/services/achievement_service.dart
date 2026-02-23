import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/achievement.dart';
import '../widgets/achievement_celebration_dialog.dart';

class AchievementService {
  static final AchievementService _instance = AchievementService._internal();
  factory AchievementService() => _instance;
  AchievementService._internal();

  static const String _progressKey = 'achievement_progress';
  static const String _unlockedKey = 'achievement_unlocked';

  /// Get progress for an achievement
  Future<int> getProgress(String achievementId) async {
    final prefs = await SharedPreferences.getInstance();
    final progressMap = _getProgressMap(prefs);
    return progressMap[achievementId] ?? 0;
  }

  /// Increment progress and check for unlock
  Future<String?> incrementProgress(String achievementId) async {
    final prefs = await SharedPreferences.getInstance();
    final progressMap = _getProgressMap(prefs);
    final unlockedSet = _getUnlockedSet(prefs);

    // Already unlocked
    if (unlockedSet.contains(achievementId)) return null;

    final currentProgress = progressMap[achievementId] ?? 0;
    progressMap[achievementId] = currentProgress + 1;
    await prefs.setString(_progressKey, jsonEncode(progressMap));

    // Check if achievement is unlocked
    final achievement = Achievement.allAchievements.firstWhere(
      (a) => a.id == achievementId,
      orElse: () => Achievement.allAchievements.first,
    );

    if (progressMap[achievementId]! >= achievement.requiredCount) {
      unlockedSet.add(achievementId);
      await prefs.setStringList(_unlockedKey, unlockedSet.toList());
      return achievementId; // Return unlocked achievement ID
    }

    return null;
  }

  /// Check if achievement is unlocked
  Future<bool> isUnlocked(String achievementId) async {
    final prefs = await SharedPreferences.getInstance();
    return _getUnlockedSet(prefs).contains(achievementId);
  }

  /// Get all unlocked achievements
  Future<Set<String>> getUnlockedAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    return _getUnlockedSet(prefs);
  }

  /// Get all progress
  Future<Map<String, int>> getAllProgress() async {
    final prefs = await SharedPreferences.getInstance();
    return _getProgressMap(prefs);
  }

  Map<String, int> _getProgressMap(SharedPreferences prefs) {
    final jsonStr = prefs.getString(_progressKey);
    if (jsonStr == null) return {};
    final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
    return decoded.map((k, v) => MapEntry(k, (v as num).toInt()));
  }

  Set<String> _getUnlockedSet(SharedPreferences prefs) {
    return prefs.getStringList(_unlockedKey)?.toSet() ?? {};
  }

  /// Increment progress and show celebration popup if unlocked
  /// Convenience method that handles both tracking and UI celebration
  Future<void> trackAndCelebrate(BuildContext context, String achievementId) async {
    final unlocked = await incrementProgress(achievementId);
    if (unlocked != null && context.mounted) {
      await AchievementCelebrationDialog.show(context, unlocked);
    }
  }
}
