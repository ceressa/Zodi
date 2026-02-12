class InteractionHistory {
  final DateTime timestamp;
  final String interactionType; // 'daily', 'compatibility', 'analysis', 'dream'
  final String content;
  final Map<String, dynamic> context;
  final double? userRating; // 1-5 yıldız
  final String? userFeedback;

  InteractionHistory({
    required this.timestamp,
    required this.interactionType,
    required this.content,
    this.context = const {},
    this.userRating,
    this.userFeedback,
  });

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'interactionType': interactionType,
        'content': content,
        'context': context,
        'userRating': userRating,
        'userFeedback': userFeedback,
      };

  factory InteractionHistory.fromJson(Map<String, dynamic> json) =>
      InteractionHistory(
        timestamp: DateTime.parse(json['timestamp']),
        interactionType: json['interactionType'] ?? '',
        content: json['content'] ?? '',
        context: Map<String, dynamic>.from(json['context'] ?? {}),
        userRating: json['userRating']?.toDouble(),
        userFeedback: json['userFeedback'],
      );
}

class UserBehaviorPattern {
  final int totalInteractions;
  final Map<String, int> interactionCounts; // type -> count
  final List<String> favoriteTopics;
  final double averageRating;
  final Map<String, dynamic> preferences;
  final DateTime lastInteraction;

  UserBehaviorPattern({
    required this.totalInteractions,
    required this.interactionCounts,
    required this.favoriteTopics,
    required this.averageRating,
    required this.preferences,
    required this.lastInteraction,
  });

  Map<String, dynamic> toJson() => {
        'totalInteractions': totalInteractions,
        'interactionCounts': interactionCounts,
        'favoriteTopics': favoriteTopics,
        'averageRating': averageRating,
        'preferences': preferences,
        'lastInteraction': lastInteraction.toIso8601String(),
      };

  factory UserBehaviorPattern.fromJson(Map<String, dynamic> json) =>
      UserBehaviorPattern(
        totalInteractions: json['totalInteractions'] ?? 0,
        interactionCounts:
            Map<String, int>.from(json['interactionCounts'] ?? {}),
        favoriteTopics: List<String>.from(json['favoriteTopics'] ?? []),
        averageRating: (json['averageRating'] ?? 0.0).toDouble(),
        preferences: Map<String, dynamic>.from(json['preferences'] ?? {}),
        lastInteraction: DateTime.parse(
            json['lastInteraction'] ?? DateTime.now().toIso8601String()),
      );
}
