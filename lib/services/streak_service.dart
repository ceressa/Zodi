import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/streak_data.dart';
import 'firebase_service.dart';
import 'storage_service.dart';
import 'coin_service.dart';

class StreakService {
  static final StreakService _instance = StreakService._internal();
  factory StreakService() => _instance;
  StreakService._internal();

  final FirebaseService _firebaseService = FirebaseService();
  final StorageService _storageService = StorageService();

  /// Record a daily visit and update streak
  /// Called on app launch to track consecutive usage
  Future<void> recordDailyVisit(String userId) async {
    try {
      final streakData = await getStreakData(userId);
      final today = _startOfDay(DateTime.now());
      final lastVisit = _startOfDay(streakData.lastVisit);

      final daysDiff = today.difference(lastVisit).inDays;

      StreakData updatedStreak;

      if (daysDiff == 0) {
        // Same day, no change
        return;
      } else if (daysDiff == 1) {
        // Consecutive day, increment streak
        updatedStreak = streakData.copyWith(
          currentStreak: streakData.currentStreak + 1,
          longestStreak: streakData.currentStreak + 1 > streakData.longestStreak
              ? streakData.currentStreak + 1
              : streakData.longestStreak,
          lastVisit: today,
        );
      } else if (daysDiff == 2 && streakData.protectionActive) {
        // Missed one day but protection active
        updatedStreak = streakData.copyWith(
          currentStreak: streakData.currentStreak + 1,
          longestStreak: streakData.currentStreak + 1 > streakData.longestStreak
              ? streakData.currentStreak + 1
              : streakData.longestStreak,
          lastVisit: today,
          protectionActive: false,
          protectionUsedDate: today,
        );
      } else {
        // Streak broken
        updatedStreak = streakData.copyWith(
          currentStreak: 1,
          lastVisit: today,
          protectionActive: false,
        );
      }

      await _saveStreakData(userId, updatedStreak);

      // Award coin bonus for streak milestones (7, 14, 21, 28, etc.)
      if (updatedStreak.currentStreak % 7 == 0) {
        final coinService = CoinService();
        await coinService.awardStreakMilestone(updatedStreak.currentStreak);
      }
    } catch (e) {
      print('Error recording daily visit: $e');
    }
  }

  /// Get current streak data for a user
  Future<StreakData> getStreakData(String userId) async {
    try {
      // Try to get from Firebase first
      final userData = await _firebaseService.getUserProfile();
      
      if (userData != null && userData.streak != null) {
        return StreakData.fromJson(Map<String, dynamic>.from(userData.streak!));
      }

      // Return default streak data if not found
      return StreakData(
        currentStreak: 0,
        longestStreak: 0,
        lastVisit: DateTime.now(),
        protectionActive: false,
      );
    } catch (e) {
      print('Error getting streak data: $e');
      return StreakData(
        currentStreak: 0,
        longestStreak: 0,
        lastVisit: DateTime.now(),
        protectionActive: false,
      );
    }
  }

  /// Use streak protection to save a broken streak (Premium feature)
  /// Returns true if protection was successfully activated
  Future<bool> useStreakProtection(String userId) async {
    try {
      final streakData = await getStreakData(userId);
      
      // Check if protection is already active
      if (streakData.protectionActive) {
        return false;
      }

      // Check if protection was used recently (within 30 days)
      if (streakData.protectionUsedDate != null) {
        final daysSinceLastUse = DateTime.now()
            .difference(streakData.protectionUsedDate!)
            .inDays;
        
        if (daysSinceLastUse < 30) {
          return false;
        }
      }

      // Activate protection
      final updatedStreak = streakData.copyWith(
        protectionActive: true,
      );

      await _saveStreakData(userId, updatedStreak);
      return true;
    } catch (e) {
      print('Error using streak protection: $e');
      return false;
    }
  }

  /// Get user statistics including streak and feature usage
  Future<UserStatistics> getStatistics(String userId) async {
    try {
      final userData = await _firebaseService.getUserProfile();
      
      if (userData == null) {
        return _getDefaultStatistics();
      }

      final streakData = await getStreakData(userId);
      
      // Get feature usage counts from user progress
      final actionCounts = userData.progress?['actionCounts'] as Map<String, dynamic>? ?? {};
      
      // Convert to Map<String, int>
      final featureUsageCounts = <String, int>{};
      actionCounts.forEach((key, value) {
        featureUsageCounts[key] = value as int? ?? 0;
      });

      // Calculate total days active
      final createdAt = userData.createdAt;
      final lastVisit = streakData.lastVisit;
      
      // Count unique days between first and last visit
      // For now, use a simple approximation
      final totalDaysActive = _calculateTotalDaysActive(featureUsageCounts);

      return UserStatistics(
        totalDaysActive: totalDaysActive,
        currentStreak: streakData.currentStreak,
        longestStreak: streakData.longestStreak,
        featureUsageCounts: featureUsageCounts,
        firstUseDate: createdAt,
        lastUseDate: lastVisit,
      );
    } catch (e) {
      print('Error getting statistics: $e');
      return _getDefaultStatistics();
    }
  }

  /// Save streak data to Firebase
  Future<void> _saveStreakData(String userId, StreakData streakData) async {
    try {
      await _firebaseService.updateCustomFields({
        'streak': streakData.toJson(),
      });

      // Also cache locally
      await _storageService.saveString(
        'streak_data_$userId',
        streakData.toJson().toString(),
      );
    } catch (e) {
      print('Error saving streak data: $e');
    }
  }

  /// Get start of day (midnight) for date comparison
  DateTime _startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Calculate total days active based on feature usage
  int _calculateTotalDaysActive(Map<String, int> featureUsageCounts) {
    // Simple heuristic: sum of all actions divided by average actions per day
    final totalActions = featureUsageCounts.values.fold(0, (sum, count) => sum + count);
    
    // Assume average 3-5 actions per active day
    final estimatedDays = (totalActions / 4).ceil();
    
    return estimatedDays > 0 ? estimatedDays : 1;
  }

  /// Get default statistics for new users
  UserStatistics _getDefaultStatistics() {
    return UserStatistics(
      totalDaysActive: 1,
      currentStreak: 0,
      longestStreak: 0,
      featureUsageCounts: {},
      firstUseDate: DateTime.now(),
      lastUseDate: DateTime.now(),
    );
  }

  /// Track a feature usage for statistics
  Future<void> trackFeatureUsage(String userId, String featureName) async {
    try {
      final userData = await _firebaseService.getUserProfile();
      
      if (userData == null) return;

      final actionCounts = Map<String, dynamic>.from(userData.progress?['actionCounts'] ?? {});
      
      // Increment count for this feature
      actionCounts[featureName] = (actionCounts[featureName] ?? 0) + 1;

      await _firebaseService.updateCustomFields({
        'progress.actionCounts': actionCounts,
      });
    } catch (e) {
      print('Error tracking feature usage: $e');
    }
  }
}
