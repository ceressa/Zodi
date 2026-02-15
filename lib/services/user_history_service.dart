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
      // Temel bilgiler
      context.writeln('- İsim: ${profile.name}');
      context.writeln('- Doğum: ${profile.birthDate.day}/${profile.birthDate.month}/${profile.birthDate.year}');
      final age = DateTime.now().year - profile.birthDate.year;
      context.writeln('- Yaş: $age');
      
      // Astrolojik profil
      if (profile.risingSign != null) {
        context.writeln('- Yükselen: ${profile.risingSign}');
      }
      if (profile.moonSign != null) {
        context.writeln('- Ay burcu: ${profile.moonSign}');
      }

      // İlişki bilgileri
      if (profile.relationshipStatus != null) {
        const statusLabels = {
          'single': 'Bekar',
          'dating': 'Flört ediyor',
          'relationship': 'Sevgilisi var',
          'engaged': 'Nişanlı',
          'married': 'Evli',
          'complicated': 'Karmaşık bir ilişkide',
          'separated': 'Ayrılmış',
          'prefer_not_say': 'Belirtmek istemedi',
        };
        context.writeln('- İlişki durumu: ${statusLabels[profile.relationshipStatus] ?? profile.relationshipStatus}');
      }
      if (profile.partnerName != null && profile.partnerName!.isNotEmpty) {
        context.writeln('- Sevdiği kişinin adı: ${profile.partnerName}');
      }
      if (profile.partnerZodiacSign != null && profile.partnerZodiacSign!.isNotEmpty) {
        context.writeln('- Partnerinin burcu: ${profile.partnerZodiacSign}');
      }
      
      // Kariyer bilgileri
      if (profile.employmentStatus != null) {
        const employmentLabels = {
          'student': 'Öğrenci',
          'employed': 'Çalışan',
          'self_employed': 'Kendi işinde çalışıyor',
          'freelancer': 'Freelancer',
          'unemployed': 'İş arıyor',
          'homemaker': 'Ev hanımı/babası',
          'retired': 'Emekli',
        };
        context.writeln('- Çalışma durumu: ${employmentLabels[profile.employmentStatus] ?? profile.employmentStatus}');
      }
      if (profile.occupation != null && profile.occupation!.isNotEmpty) {
        context.writeln('- Meslek: ${profile.occupation}');
      }
      if (profile.workField != null) {
        const fieldLabels = {
          'tech': 'Teknoloji',
          'health': 'Sağlık',
          'education': 'Eğitim',
          'finance': 'Finans',
          'arts': 'Sanat & Medya',
          'retail': 'Perakende',
          'service': 'Hizmet sektörü',
          'manufacturing': 'Üretim',
          'government': 'Kamu',
          'other': 'Diğer',
        };
        context.writeln('- Sektör: ${fieldLabels[profile.workField] ?? profile.workField}');
      }
      if (profile.careerGoal != null && profile.careerGoal!.isNotEmpty) {
        context.writeln('- Kariyer hedefi: ${profile.careerGoal}');
      }
      
      // Yaşam bilgileri
      if (profile.currentCity != null && profile.currentCity!.isNotEmpty) {
        context.writeln('- Yaşadığı şehir: ${profile.currentCity}');
      }
      if (profile.lifePhase != null) {
        const phaseLabels = {
          'exploring': 'Keşif aşamasında',
          'building': 'İnşa ediyor (kariyer/ilişki kurma döneminde)',
          'established': 'Yerleşik hayat',
          'transitioning': 'Geçiş döneminde',
          'uncertain': 'Belirsizlik içinde',
        };
        context.writeln('- Hayat dönemi: ${phaseLabels[profile.lifePhase] ?? profile.lifePhase}');
      }
      if (profile.spiritualInterest != null) {
        const spiritualLabels = {
          'believer': 'Astrolojiye inanan',
          'curious': 'Meraklı',
          'skeptic': 'Şüpheci',
          'just_fun': 'Sadece eğlence için kullanıyor',
        };
        context.writeln('- Astrolojiye bakışı: ${spiritualLabels[profile.spiritualInterest] ?? profile.spiritualInterest}');
      }
      
      // İlgi alanları ve hedefler
      if (profile.interests.isNotEmpty) {
        context.writeln('- İlgi alanları: ${profile.interests.join(", ")}');
      }
      if (profile.currentChallenges.isNotEmpty) {
        context.writeln('- Şu anki zorlukları: ${profile.currentChallenges.join(", ")}');
      }
      if (profile.lifeGoals.isNotEmpty) {
        context.writeln('- Hayat hedefleri: ${profile.lifeGoals.join(", ")}');
      }
    }

    if (pattern != null) {
      context.writeln('\nDAVRANIŞ KALIPLARI:');
      context.writeln('- Toplam etkileşim: ${pattern.totalInteractions}');
      context.writeln('- Ortalama memnuniyet: ${pattern.averageRating.toStringAsFixed(1)}/5.0');
      
      if (pattern.favoriteTopics.isNotEmpty) {
        context.writeln('- Sık baktığı konular: ${pattern.favoriteTopics.join(", ")}');
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

    context.writeln('\nZODİ YAKLAŞIMI - KİŞİSELLEŞTİRME KURALLARI:');
    context.writeln('Bu bilgilere göre yorumlarını MUTLAKA kişiselleştir:');
    context.writeln('');
    context.writeln('1. İSİM KULLANIMI:');
    context.writeln('   - Kullanıcıya ismiyle hitap et (örn: "Bugün senin için özel bir gün ${profile?.name ?? "dostum"}")');
    context.writeln('   - Sevgilisi/partneri varsa, aşk yorumlarında partnerinin adını kullan');
    context.writeln('');
    context.writeln('2. KARİYER & PARA YORUMLARI:');
    if (profile?.occupation != null || profile?.employmentStatus != null) {
      context.writeln('   - Mesleğine (${profile?.occupation ?? profile?.employmentStatus}) özgü tavsiyeler ver');
      context.writeln('   - Sektörüne (${profile?.workField ?? "genel"}) uygun öneriler sun');
    }
    if (profile?.careerGoal != null && profile!.careerGoal!.isNotEmpty) {
      context.writeln('   - Kariyer hedefini (${profile.careerGoal}) göz önünde bulundur');
    }
    context.writeln('');
    context.writeln('3. ZORLUKLAR & HEDEFLER:');
    if (profile != null && profile.currentChallenges.isNotEmpty) {
      context.writeln('   - Şu anki zorluklarına (${profile.currentChallenges.join(", ")}) değin, destek ver');
    }
    if (profile != null && profile.lifeGoals.isNotEmpty) {
      context.writeln('   - Hayat hedeflerine (${profile.lifeGoals.join(", ")}) yönelik motivasyon ver');
    }
    context.writeln('');
    context.writeln('4. HAYAT DÖNEMİ:');
    if (profile?.lifePhase != null) {
      context.writeln('   - Hayat dönemine (${profile?.lifePhase}) uygun bir dil kullan');
    }
    context.writeln('');
    context.writeln('5. ASTROLOJİYE BAKIŞ:');
    if (profile?.spiritualInterest == 'skeptic') {
      context.writeln('   - Şüpheci olduğu için daha pragmatik ve az mistik bir dil kullan');
    } else if (profile?.spiritualInterest == 'believer') {
      context.writeln('   - İnandığı için daha derin astrolojik detaylar verebilirsin');
    } else if (profile?.spiritualInterest == 'just_fun') {
      context.writeln('   - Eğlence için kullandığından hafif ve eğlenceli tut');
    }
    context.writeln('');
    context.writeln('6. GENEL KURALLAR:');
    context.writeln('   - Tutarlı ol, önceki yorumlarla çelişme');
    context.writeln('   - Samimi ve direkt ol, gereksiz yere övme');
    context.writeln('   - İlgi alanlarına (${profile?.interests.join(", ") ?? "genel"}) göre yorumu ağırlıkla o konulara odakla');
    context.writeln('   - Şehrindeki (${profile?.currentCity ?? "bulunduğu yer"}) hava, etkinlik vb. şeylere atıfta bulunabilirsin');
    context.writeln('   - Kısa ve öz tut, 2-3 paragrafı geçme');

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
