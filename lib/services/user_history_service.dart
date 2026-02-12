import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/interaction_history.dart';
import '../models/user_profile.dart';

class UserHistoryService {
  static const String _keyInteractionHistory = 'interactionHistory';
  static const String _keyUserProfile = 'userProfile';
  static const String _keyBehaviorPattern = 'behaviorPattern';
  static const int _maxHistoryItems = 100;

  // Kullanıcı profili
  Future<void> saveUserProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserProfile, jsonEncode(profile.toJson()));
  }

  Future<UserProfile?> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_keyUserProfile);
    if (json == null) return null;
    return UserProfile.fromJson(jsonDecode(json));
  }

  // Etkileşim geçmişi
  Future<void> addInteraction(InteractionHistory interaction) async {
    final history = await getInteractionHistory();
    history.insert(0, interaction);

    // Son 100 etkileşimi tut
    if (history.length > _maxHistoryItems) {
      history.removeRange(_maxHistoryItems, history.length);
    }

    await _saveHistory(history);
    await _updateBehaviorPattern(history);
  }

  Future<List<InteractionHistory>> getInteractionHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_keyInteractionHistory);
    if (json == null) return [];

    final List<dynamic> list = jsonDecode(json);
    return list.map((item) => InteractionHistory.fromJson(item)).toList();
  }

  Future<void> _saveHistory(List<InteractionHistory> history) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(history.map((h) => h.toJson()).toList());
    await prefs.setString(_keyInteractionHistory, json);
  }

  // Davranış kalıpları
  Future<void> _updateBehaviorPattern(
      List<InteractionHistory> history) async {
    if (history.isEmpty) return;

    final interactionCounts = <String, int>{};
    final ratings = <double>[];
    final topics = <String>[];

    for (var interaction in history) {
      // Etkileşim türlerini say
      interactionCounts[interaction.interactionType] =
          (interactionCounts[interaction.interactionType] ?? 0) + 1;

      // Puanları topla
      if (interaction.userRating != null) {
        ratings.add(interaction.userRating!);
      }

      // Konuları topla
      if (interaction.context.containsKey('topic')) {
        topics.add(interaction.context['topic']);
      }
    }

    // En çok kullanılan konuları bul
    final topicCounts = <String, int>{};
    for (var topic in topics) {
      topicCounts[topic] = (topicCounts[topic] ?? 0) + 1;
    }
    final favoriteTopics = topicCounts.entries
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final pattern = UserBehaviorPattern(
      totalInteractions: history.length,
      interactionCounts: interactionCounts,
      favoriteTopics:
          favoriteTopics.take(5).map((e) => e.key).toList(),
      averageRating:
          ratings.isEmpty ? 0.0 : ratings.reduce((a, b) => a + b) / ratings.length,
      preferences: _extractPreferences(history),
      lastInteraction: history.first.timestamp,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyBehaviorPattern, jsonEncode(pattern.toJson()));
  }

  Future<UserBehaviorPattern?> getBehaviorPattern() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_keyBehaviorPattern);
    if (json == null) return null;
    return UserBehaviorPattern.fromJson(jsonDecode(json));
  }

  Map<String, dynamic> _extractPreferences(
      List<InteractionHistory> history) {
    final preferences = <String, dynamic>{
      'prefersDetailedAnalysis': false,
      'prefersShortReadings': false,
      'engagesWithCompatibility': false,
      'engagesWithDreams': false,
      'readingTimeOfDay': 'morning', // morning, afternoon, evening, night
    };

    // Detaylı analiz tercihi
    final analysisCount =
        history.where((h) => h.interactionType == 'analysis').length;
    preferences['prefersDetailedAnalysis'] = analysisCount > history.length * 0.3;

    // Uyumluluk ilgisi
    final compatCount =
        history.where((h) => h.interactionType == 'compatibility').length;
    preferences['engagesWithCompatibility'] = compatCount > 5;

    // Rüya yorumu ilgisi
    final dreamCount =
        history.where((h) => h.interactionType == 'dream').length;
    preferences['engagesWithDreams'] = dreamCount > 3;

    // Okuma saati tercihi
    final hours = history.map((h) => h.timestamp.hour).toList();
    if (hours.isNotEmpty) {
      final avgHour = hours.reduce((a, b) => a + b) / hours.length;
      if (avgHour < 12) {
        preferences['readingTimeOfDay'] = 'morning';
      } else if (avgHour < 17) {
        preferences['readingTimeOfDay'] = 'afternoon';
      } else if (avgHour < 21) {
        preferences['readingTimeOfDay'] = 'evening';
      } else {
        preferences['readingTimeOfDay'] = 'night';
      }
    }

    return preferences;
  }

  // Zodi için kişiselleştirilmiş bağlam oluştur
  Future<String> generatePersonalizedContext() async {
    final profile = await getUserProfile();
    final pattern = await getBehaviorPattern();
    final recentHistory = await getInteractionHistory();

    final context = StringBuffer();
    context.writeln('KULLANICI PROFİLİ VE GEÇMİŞ:');

    if (profile != null) {
      context.writeln('- İsim: ${profile.name}');
      context.writeln('- Doğum: ${profile.birthDate.day}/${profile.birthDate.month}/${profile.birthDate.year}');
      if (profile.risingSign != null) {
        context.writeln('- Yükselen: ${profile.risingSign}');
      }
      if (profile.moonSign != null) {
        context.writeln('- Ay burcu: ${profile.moonSign}');
      }
    }

    if (pattern != null) {
      context.writeln('\nDAVRANIŞ KALIPLARI:');
      context.writeln('- Toplam etkileşim: ${pattern.totalInteractions}');
      context.writeln('- Ortalama memnuniyet: ${pattern.averageRating.toStringAsFixed(1)}/5.0');
      
      if (pattern.favoriteTopics.isNotEmpty) {
        context.writeln('- İlgi alanları: ${pattern.favoriteTopics.join(", ")}');
      }

      final prefs = pattern.preferences;
      if (prefs['prefersDetailedAnalysis'] == true) {
        context.writeln('- Detaylı analizleri tercih ediyor');
      }
      if (prefs['engagesWithCompatibility'] == true) {
        context.writeln('- Uyumluluk analizlerine ilgi gösteriyor');
      }
      if (prefs['engagesWithDreams'] == true) {
        context.writeln('- Rüya yorumlarına ilgi gösteriyor');
      }
    }

    // Son 5 etkileşimden öğrenilen şeyler
    if (recentHistory.isNotEmpty) {
      context.writeln('\nSON ETKİLEŞİMLER:');
      final recent = recentHistory.take(5);
      for (var interaction in recent) {
        if (interaction.userFeedback != null) {
          context.writeln('- ${interaction.interactionType}: "${interaction.userFeedback}" (${interaction.userRating}/5)');
        }
      }
    }

    context.writeln('\nZODİ YAKLAŞIMI:');
    context.writeln('Bu bilgilere göre yorumlarını şekillendir. Kullanıcının geçmiş deneyimlerine göre:');
    context.writeln('- Tutarlı ol (önceki yorumlarla çelişme)');
    context.writeln('- Övgüyü hak ettiğinde över, eleştiriyi hak ettiğinde eleştirir');
    context.writeln('- Samimi ve direkt ol, gereksiz yere övme');
    context.writeln('- Kullanıcının ilgi alanlarına odaklan');

    return context.toString();
  }

  // Kullanıcı geri bildirimi kaydet
  Future<void> addFeedback(
      String interactionType, double rating, String? feedback) async {
    final history = await getInteractionHistory();
    
    // Son aynı türdeki etkileşimi bul ve güncelle
    final index = history.indexWhere((h) => h.interactionType == interactionType);
    if (index != -1) {
      final updated = InteractionHistory(
        timestamp: history[index].timestamp,
        interactionType: history[index].interactionType,
        content: history[index].content,
        context: history[index].context,
        userRating: rating,
        userFeedback: feedback,
      );
      history[index] = updated;
      await _saveHistory(history);
      await _updateBehaviorPattern(history);
    }
  }

  // Tüm geçmişi temizle
  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyInteractionHistory);
    await prefs.remove(_keyBehaviorPattern);
  }
}
