class StreakData {
  final int currentStreak;
  final int longestStreak;
  final DateTime lastVisit;
  final bool protectionActive;
  final DateTime? protectionUsedDate;

  StreakData({
    required this.currentStreak,
    required this.longestStreak,
    required this.lastVisit,
    this.protectionActive = false,
    this.protectionUsedDate,
  });

  factory StreakData.fromJson(Map<String, dynamic> json) {
    return StreakData(
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      lastVisit: DateTime.parse(json['lastVisit'] ?? DateTime.now().toIso8601String()),
      protectionActive: json['protectionActive'] ?? false,
      protectionUsedDate: json['protectionUsedDate'] != null
          ? DateTime.parse(json['protectionUsedDate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastVisit': lastVisit.toIso8601String(),
      'protectionActive': protectionActive,
      'protectionUsedDate': protectionUsedDate?.toIso8601String(),
    };
  }

  StreakData copyWith({
    int? currentStreak,
    int? longestStreak,
    DateTime? lastVisit,
    bool? protectionActive,
    DateTime? protectionUsedDate,
  }) {
    return StreakData(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastVisit: lastVisit ?? this.lastVisit,
      protectionActive: protectionActive ?? this.protectionActive,
      protectionUsedDate: protectionUsedDate ?? this.protectionUsedDate,
    );
  }
}

class UserStatistics {
  final int totalDaysActive;
  final int currentStreak;
  final int longestStreak;
  final Map<String, int> featureUsageCounts;
  final DateTime firstUseDate;
  final DateTime lastUseDate;

  UserStatistics({
    required this.totalDaysActive,
    required this.currentStreak,
    required this.longestStreak,
    required this.featureUsageCounts,
    required this.firstUseDate,
    required this.lastUseDate,
  });

  factory UserStatistics.fromJson(Map<String, dynamic> json) {
    return UserStatistics(
      totalDaysActive: json['totalDaysActive'] ?? 0,
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      featureUsageCounts: Map<String, int>.from(json['featureUsageCounts'] ?? {}),
      firstUseDate: DateTime.parse(json['firstUseDate'] ?? DateTime.now().toIso8601String()),
      lastUseDate: DateTime.parse(json['lastUseDate'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalDaysActive': totalDaysActive,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'featureUsageCounts': featureUsageCounts,
      'firstUseDate': firstUseDate.toIso8601String(),
      'lastUseDate': lastUseDate.toIso8601String(),
    };
  }
}
