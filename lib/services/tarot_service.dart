import 'dart:math';
import 'package:intl/intl.dart';
import '../models/tarot_card.dart';
import '../constants/tarot_data.dart';
import 'gemini_service.dart';
import 'firebase_service.dart';

class TarotService {
  final GeminiService _geminiService;
  final FirebaseService _firebaseService;

  TarotService({
    required GeminiService geminiService,
    required FirebaseService firebaseService,
  })  : _geminiService = geminiService,
        _firebaseService = firebaseService;

  /// Günlük tek kart çekimi (tüm kullanıcılar için)
  Future<TarotReading> getDailyCard(String userId, String zodiacSign) async {
    // Önce bugünün okumalarını kontrol et
    final existingReading = await _getTodayReading(userId, 'daily');
    if (existingReading != null) {
      return existingReading;
    }

    // Yeni kart seç
    final card = _selectDailyCard(userId);
    
    // Yorum oluştur
    final interpretation = await generateInterpretation([card], zodiacSign);

    final reading = TarotReading(
      date: DateTime.now(),
      cards: [card],
      interpretation: interpretation,
      zodiacSign: zodiacSign,
      type: 'daily',
    );

    // Kaydet
    await saveReading(userId, reading);

    return reading;
  }

  /// Üç kart yayılımı (Premium kullanıcılar için)
  Future<TarotReading> getThreeCardSpread(
      String userId, String zodiacSign) async {
    // Önce bugünün okumalarını kontrol et
    final existingReading = await _getTodayReading(userId, 'three_card');
    if (existingReading != null) {
      return existingReading;
    }

    // Üç kart seç (geçmiş, şimdi, gelecek)
    final cards = _selectThreeCards(userId);

    // Yorum oluştur
    final interpretation = await generateInterpretation(cards, zodiacSign);

    final reading = TarotReading(
      date: DateTime.now(),
      cards: cards,
      interpretation: interpretation,
      zodiacSign: zodiacSign,
      type: 'three_card',
    );

    // Kaydet
    await saveReading(userId, reading);

    return reading;
  }

  /// Kart yorumu oluştur (Gemini ile)
  Future<String> generateInterpretation(
      List<TarotCard> cards, String zodiacSign) async {
    final cardDescriptions = cards.map((card) {
      final position = cards.length == 3
          ? ['Geçmiş', 'Şimdi', 'Gelecek'][cards.indexOf(card)]
          : 'Bugün';
      return '''
$position: ${card.name} ${card.reversed ? '(Ters)' : ''}
Anlamı: ${card.basicMeaning}
''';
    }).join('\n');

    final prompt = '''
Sen Zodi'sin, samimi ve eğlenceli bir astroloji asistanısın. Kullanıcıya "sen" diye hitap ediyorsun.

${zodiacSign} burcu olan kullanıcı için tarot yorumu yap:

$cardDescriptions

Yorum kuralları:
- Kullanıcıya direkt "sen" diye hitap et (örn: "Bugün senin için...", "Dikkatli olmalısın...")
- ASLA kendinden bahsetme, Zodi'den bahsetme
- Samimi ve dostça bir dil kullan, arkadaşına konuşur gibi
- ${cards.length == 1 ? '150-200' : '250-300'} kelime arası yaz
- Kartların anlamlarını burç özellikleriyle birleştir
- Pratik, uygulanabilir öneriler ver
- Pozitif ama gerçekçi ol, abartma
- Ters kartları mutlaka dikkate al ve yorumla
- Bazen biraz alaycı, bazen sıcak ol - ama her zaman samimi

Sadece yorumu yaz, başlık, giriş veya "Merhaba" gibi ifadeler ekleme. Direkt yoruma başla.
''';

    try {
      // Gemini'den direkt text response al
      final response = await _geminiService.generateTarotInterpretation(prompt);
      return response;
    } catch (e) {
      print('Tarot yorumu hatası: $e');
      return 'Tarot yorumu oluşturulurken bir hata oluştu. Lütfen daha sonra tekrar deneyin.';
    }
  }

  /// Okumayı Firebase'e kaydet
  Future<void> saveReading(String userId, TarotReading reading) async {
    try {
      final readingId = DateFormat('yyyyMMdd').format(reading.date);
      await _firebaseService.saveTarotReading(
        userId,
        readingId,
        reading.toJson(),
      );
    } catch (e) {
      print('Tarot okuma kaydedilemedi: $e');
    }
  }

  /// Bugünün okumasını getir (varsa)
  Future<TarotReading?> _getTodayReading(String userId, String type) async {
    try {
      final today = DateFormat('yyyyMMdd').format(DateTime.now());
      final readings = await _firebaseService.getTarotReadings(userId);
      
      for (var reading in readings) {
        final readingDate = DateFormat('yyyyMMdd').format(reading.date);
        if (readingDate == today && reading.type == type) {
          return reading;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Günlük kart seçimi (deterministik)
  TarotCard _selectDailyCard(String userId) {
    final today = DateFormat('yyyyMMdd').format(DateTime.now());
    final seed = '${userId}_$today'.hashCode;
    final rng = Random(seed);

    final cardIndex = rng.nextInt(TarotData.allCards.length);
    final reversed = rng.nextBool();

    return TarotData.getCard(cardIndex, reversed);
  }

  /// Üç kart seçimi (deterministik)
  List<TarotCard> _selectThreeCards(String userId) {
    final today = DateFormat('yyyyMMdd').format(DateTime.now());
    final seed = '${userId}_${today}_three'.hashCode;
    final rng = Random(seed);

    final selectedIndices = <int>[];
    while (selectedIndices.length < 3) {
      final index = rng.nextInt(TarotData.allCards.length);
      if (!selectedIndices.contains(index)) {
        selectedIndices.add(index);
      }
    }

    return selectedIndices.map((index) {
      final reversed = rng.nextBool();
      return TarotData.getCard(index, reversed);
    }).toList();
  }

  /// Kullanıcının tüm tarot geçmişini getir
  Future<List<TarotReading>> getReadingHistory(String userId) async {
    try {
      final readings = await _firebaseService.getTarotReadings(userId);
      return readings.map((data) => TarotReading.fromJson(data as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Tarot geçmişi alınamadı: $e');
      return [];
    }
  }
}
