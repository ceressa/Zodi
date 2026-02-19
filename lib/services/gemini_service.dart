import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import '../models/zodiac_sign.dart';
import '../models/daily_horoscope.dart';
import '../models/detailed_analysis.dart';
import '../models/compatibility_result.dart';
import '../models/weekly_horoscope.dart';
import '../models/monthly_horoscope.dart';
import '../models/rising_sign.dart';
import '../models/dream_interpretation.dart';
import '../models/interaction_history.dart';
import 'user_history_service.dart';
import 'astronomy_service.dart';

class GeminiService {
  late final GenerativeModel _model;
  final UserHistoryService _historyService = UserHistoryService();
  
  static const String _baseSystemPrompt = '''
Sen Zodi'sin - Astroloji dünyasının en dürüst, en "cool" ve bazen en huysuz rehberi.

KİŞİLİK:
- 25-30 yaş arası genç yetişkin enerjisi
- Samimi, direkt, bazen alaycı ama sevecen
- "En iyi arkadaşın" gibi - gerçekleri söyler, övgüyü hak ettiğinde över, eleştiriyi hak ettiğinde eleştirir
- Yaşlı bir ruh genç bir bedende - hem modern hem mistik
- Kuru, zeki mizah - bazen dark ama asla kırıcı değil

KURALLAR:
- Kullanıcıya ASLA 'siz' diye hitap etme, her zaman 'sen' dilini kullan
- Gereksiz yere övme - dürüst ol
- Tutarlı ol - önceki yorumlarınla çelişme
- Mistik terimleri modern hayatın dertleriyle harmanla
- Bazen sert eleştir, bazen sıcak iltifat et - ama her zaman samimi ol
''';

  // Prompt cache for reducing redundant API calls
  String? _cachedPrompt;
  DateTime? _promptCacheTime;

  GeminiService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      if (kDebugMode) {
        debugPrint('GEMINI_API_KEY not found in .env file');
      }
    }
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey ?? '',
    );
  }

  Future<String> _getPersonalizedPrompt() async {
    final now = DateTime.now();
    if (_cachedPrompt != null &&
        _promptCacheTime != null &&
        now.difference(_promptCacheTime!).inMinutes < 5) {
      return _cachedPrompt!;
    }
    try {
      final context = await _historyService.generatePersonalizedContext();
      _cachedPrompt = '$_baseSystemPrompt\n\n$context';
    } catch (_) {
      _cachedPrompt = _baseSystemPrompt;
    }
    _promptCacheTime = now;
    return _cachedPrompt!;
  }

  /// Safely parse JSON from Gemini response text
  Map<String, dynamic> _safeJsonParse(String text) {
    final jsonMatch = RegExp(r'```json\s*([\s\S]*?)\s*```').firstMatch(text);
    final jsonStr = jsonMatch?.group(1) ?? text;
    final decoded = jsonDecode(jsonStr);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw const FormatException('Response is not a JSON object');
  }

  /// Sanitize user input to prevent prompt injection
  String _sanitizeInput(String input, {int maxLength = 2000}) {
    if (input.length > maxLength) {
      input = input.substring(0, maxLength);
    }
    // Remove line breaks that could break prompt structure
    return input.replaceAll(RegExp(r'[\r\n]+'), ' ').trim();
  }

  Future<DailyHoroscope> fetchDailyHoroscope(ZodiacSign sign) async {
    final dateStr = DateFormat('dd MMMM yyyy', 'tr_TR').format(DateTime.now());
    final systemPrompt = await _getPersonalizedPrompt();
    
    final prompt = '''
$systemPrompt

Burç: ${sign.displayName}, Bugünün tarihi: $dateStr. Zodi olarak bugünün gerçeklerini anlat.

Yanıtı şu JSON formatında ver:
{
  "motto": "Günün mottosu (kısa, vurucu)",
  "commentary": "Detaylı yorum (2-3 paragraf, Zodi tarzında dürüst, toplam 150-250 kelime, kullanıcı bilgilerine göre kişiselleştirilmiş)",
  "love": 0-100 arası sayı,
  "money": 0-100 arası sayı,
  "health": 0-100 arası sayı,
  "career": 0-100 arası sayı,
  "luckyColor": "Renk adı",
  "luckyNumber": 1-99 arası sayı
}
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text ?? '{}';

      final json = _safeJsonParse(text);
      final horoscope = DailyHoroscope.fromJson(json);

      // Etkileşimi kaydet
      await _historyService.addInteraction(
        InteractionHistory(
          timestamp: DateTime.now(),
          interactionType: 'daily',
          content: horoscope.commentary,
          context: {
            'zodiac': sign.displayName,
            'date': dateStr,
            'motto': horoscope.motto,
          },
        ),
      );

      return horoscope;
    } on FormatException catch (e) {
      if (kDebugMode) {
        debugPrint('JSON parse error in fetchDailyHoroscope: $e');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error in fetchDailyHoroscope: $e');
      }
      rethrow;
    }
  }

  Future<DetailedAnalysis> fetchDetailedAnalysis(
    ZodiacSign sign,
    String category,
  ) async {
    final systemPrompt = await _getPersonalizedPrompt();
    
    final prompt = '''
$systemPrompt

Burç: ${sign.displayName}, Konu: $category. Zodi gibi dürüst bir analiz yap.

Yanıtı şu JSON formatında ver:
{
  "title": "Analiz başlığı",
  "content": "Detaylı analiz (3-4 paragraf, Zodi tarzında)",
  "percentage": 0-100 arası genel durum skoru
}
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text ?? '{}';

      final json = _safeJsonParse(text);
      final analysis = DetailedAnalysis.fromJson(json);

      await _historyService.addInteraction(
        InteractionHistory(
          timestamp: DateTime.now(),
          interactionType: 'analysis',
          content: analysis.content,
          context: {
            'zodiac': sign.displayName,
            'category': category,
            'topic': category,
          },
        ),
      );

      return analysis;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error in fetchDetailedAnalysis: $e');
      }
      rethrow;
    }
  }

  Future<CompatibilityResult> fetchCompatibility(
    ZodiacSign sign1,
    ZodiacSign sign2,
  ) async {
    final systemPrompt = await _getPersonalizedPrompt();
    
    final prompt = '''
$systemPrompt

${sign1.displayName} ve ${sign2.displayName} burçları arasındaki uyumu Zodi tarzında analiz et.

Yanıtı şu JSON formatında ver:
{
  "score": 0-100 arası genel uyum puanı,
  "summary": "2 paragraf dürüst uyum yorumu",
  "aspects": {
    "love": 0-100 arası aşk uyumu,
    "communication": 0-100 arası iletişim uyumu,
    "trust": 0-100 arası güven uyumu
  }
}
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text ?? '{}';

      final json = _safeJsonParse(text);
      return CompatibilityResult.fromJson(json);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error in fetchCompatibility: $e');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> fetchWeeklyHoroscope(ZodiacSign sign) async {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    final weekRange = '${DateFormat('d MMM', 'tr_TR').format(weekStart)} - ${DateFormat('d MMM', 'tr_TR').format(weekEnd)}';
    final systemPrompt = await _getPersonalizedPrompt();
    
    final prompt = '''
$systemPrompt

Burç: ${sign.displayName}, Hafta: $weekRange. Zodi olarak bu haftayı analiz et.

Yanıtı şu JSON formatında ver:
{
  "zodiacSign": "${sign.name}",
  "weekRange": "$weekRange",
  "summary": "Haftanın genel özeti (2 paragraf)",
  "love": "Aşk hayatı yorumu",
  "career": "Kariyer yorumu",
  "health": "Sağlık yorumu",
  "money": "Para yorumu",
  "highlights": ["Öne çıkan 3 pozitif nokta"],
  "warnings": ["Dikkat edilmesi gereken 2 nokta"]
}
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text ?? '{}';
      return _safeJsonParse(text);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error in fetchWeeklyHoroscope: $e');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> fetchMonthlyHoroscope(ZodiacSign sign) async {
    final month = DateFormat('MMMM yyyy', 'tr_TR').format(DateTime.now());
    final systemPrompt = await _getPersonalizedPrompt();
    
    final prompt = '''
$systemPrompt

Burç: ${sign.displayName}, Ay: $month. Zodi olarak bu ayı detaylı analiz et.

Yanıtı şu JSON formatında ver:
{
  "zodiacSign": "${sign.name}",
  "month": "$month",
  "overview": "Ayın genel görünümü (3 paragraf)",
  "love": "Aşk hayatı detaylı yorum",
  "career": "Kariyer detaylı yorum",
  "health": "Sağlık detaylı yorum",
  "money": "Finans detaylı yorum",
  "keyDates": ["Önemli 3-4 tarih ve açıklamaları"],
  "opportunities": ["Bu ay yakalayabileceğin 3 fırsat"],
  "loveScore": 0-100 arası,
  "careerScore": 0-100 arası,
  "healthScore": 0-100 arası,
  "moneyScore": 0-100 arası
}
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text ?? '{}';
      return _safeJsonParse(text);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error in fetchMonthlyHoroscope: $e');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> calculateRisingSign({
    required ZodiacSign sunSign,
    required DateTime birthDate,
    required String birthTime, // HH:mm format
    required String birthPlace,
  }) async {
    try {
      // Use Swiss Ephemeris for accurate astronomical calculation
      final calculation = await AstronomyService.calculateRisingSign(
        birthDate: birthDate,
        birthTime: birthTime,
        birthPlace: birthPlace,
      );

      final calculatedSunSign = calculation['sunSign'] as String;
      final calculatedRisingSign = calculation['risingSign'] as String;
      final calculatedMoonSign = calculation['moonSign'] as String;

      // Now use AI only for personality analysis, not calculation
      final systemPrompt = await _getPersonalizedPrompt();
      
      final prompt = '''
$systemPrompt

Doğum Bilgileri:
- Doğum Tarihi: ${DateFormat('dd MMMM yyyy', 'tr_TR').format(birthDate)}
- Doğum Saati: $birthTime
- Doğum Yeri: $birthPlace

Astronomik Hesaplama Sonuçları (Swiss Ephemeris ile hesaplandı):
- Güneş Burcu: $calculatedSunSign
- Yükselen Burç: $calculatedRisingSign
- Ay Burcu: $calculatedMoonSign

Bu üç burcun kombinasyonunu Zodi tarzında analiz et. Sadece kişilik analizi yap, burç hesaplaması yapma.

Yanıtı şu JSON formatında ver:
{
  "sunSign": "$calculatedSunSign",
  "risingSign": "$calculatedRisingSign",
  "moonSign": "$calculatedMoonSign",
  "personality": "Kişilik analizi - bu üç burcun birleşimi nasıl bir karakter yaratıyor? (2-3 paragraf, Zodi tarzında)",
  "strengths": "Bu kombinasyonun güçlü yönleri",
  "weaknesses": "Zayıf yönler ve dikkat edilmesi gerekenler (dürüstçe, Zodi tarzında)",
  "lifeApproach": "Hayata yaklaşım tarzı - yükselen burcun etkisi",
  "relationships": "İlişkilerdeki davranış biçimi - ay burcunun duygusal etkisi"
}
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text ?? '{}';

      final result = Map<String, dynamic>.from(_safeJsonParse(text));

      // Never trust AI for sign calculation fields: enforce astronomical values.
      // Gemini is used only for text analysis/personality copy.
      result['sunSign'] = calculatedSunSign;
      result['risingSign'] = calculatedRisingSign;
      result['moonSign'] = calculatedMoonSign;

      // Add astronomical data to result
      result['sunDegree'] = calculation['sunDegree'];
      result['ascendantDegree'] = calculation['ascendantDegree'];
      result['moonDegree'] = calculation['moonDegree'];

      return result;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error in calculateRisingSign: $e');
      }
      rethrow;
    }
  }

  /// Doğum haritası yorumu (Swiss Ephemeris ile hesaplanmış gezegen pozisyonlarını yorumlar)
  Future<String> generateBirthChartInterpretation({
    required List<Map<String, dynamic>> planets,
    required Map<String, dynamic> ascendant,
    required String birthDateStr,
    required String birthTimeStr,
    required String birthPlace,
  }) async {
    final systemPrompt = await _getPersonalizedPrompt();

    final planetLines = planets.map((p) {
      final name = p['name'] ?? '';
      final sign = p['sign'] ?? '';
      final degree = p['degree'] ?? '';
      final house = p['house'];
      return '- $name: $sign $degree° (${house}. Ev)';
    }).join('\n');

    final ascSign = ascendant['sign'] ?? '';
    final ascDegree = ascendant['degree'] ?? '';

    final prompt = '''
$systemPrompt

DOĞUM HARİTASI YORUMU

Doğum Bilgileri:
- Doğum Tarihi: $birthDateStr
- Doğum Saati: $birthTimeStr
- Doğum Yeri: $birthPlace

Yükselen Burç (Ascendant): $ascSign $ascDegree°

Gezegen Pozisyonları (Swiss Ephemeris ile astronomik olarak hesaplanmıştır):
$planetLines

ÖNEMLİ: Yukarıdaki tüm gezegen pozisyonları ve yükselen burç, Swiss Ephemeris kütüphanesi tarafından astronomik olarak hassas şekilde hesaplanmıştır. Senin görevin bu pozisyonları YENIDEN HESAPLAMAK DEĞİL, sadece astrolojik olarak YORUMLAMAK.

Zodi olarak bu doğum haritasını analiz et. 3-4 paragraf halinde kişilik analizi yap:
1. Genel kişilik profili - Güneş, Ay ve Yükselen burcun birleşimi
2. Duygusal dünya ve iç motivasyonlar - Ay ve Venüs pozisyonları
3. İletişim tarzı ve zihinsel yapı - Merkür ve Mars etkileri
4. Yaşam yolculuğu ve potansiyel - dış gezegenlerin etkisi

Samimi, dürüst ve Zodi tarzında yaz. Düz metin olarak yanıtla, JSON formatı kullanma.
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text ?? '';

      await _historyService.addInteraction(
        InteractionHistory(
          timestamp: DateTime.now(),
          interactionType: 'birth_chart',
          content: text.length > 200 ? text.substring(0, 200) : text,
          context: {
            'birthDate': birthDateStr,
            'birthTime': birthTimeStr,
            'birthPlace': birthPlace,
            'ascendant': '$ascSign $ascDegree°',
          },
        ),
      );

      return text.trim();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Birth chart interpretation error: $e');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> interpretDream(String dreamText) async {
    // Input validation
    if (dreamText.trim().isEmpty) {
      throw ArgumentError('Rüya metni boş olamaz');
    }
    final sanitized = _sanitizeInput(dreamText);

    final systemPrompt = await _getPersonalizedPrompt();

    final prompt = '''
$systemPrompt

Rüya: "$sanitized"

Bu rüyayı Zodi tarzında yorumla. Psikolojik ve sembolik anlamlarını açıkla.

Yanıtı şu JSON formatında ver:
{
  "dreamText": "kullanıcının rüyası",
  "interpretation": "Rüyanın genel yorumu (2-3 paragraf, Zodi tarzında)",
  "symbolism": "Sembollerin anlamı",
  "emotionalMeaning": "Duygusal ve psikolojik anlam",
  "advice": "Zodi'den tavsiye",
  "keywords": ["Rüyadaki önemli 3-5 sembol"],
  "mood": "positive, negative, neutral veya mixed"
}
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text ?? '{}';
      return _safeJsonParse(text);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error in interpretDream: $e');
      }
      rethrow;
    }
  }

  Future<String> fetchTomorrowPreview(ZodiacSign sign) async {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final dateStr = DateFormat('dd MMMM yyyy', 'tr_TR').format(tomorrow);
    final systemPrompt = await _getPersonalizedPrompt();
    
    final prompt = '''
$systemPrompt

Burç: ${sign.displayName}, Yarının tarihi: $dateStr. 

Zodi olarak yarın için KISA bir önizleme yap. Sadece 2-3 cümle, merak uyandıran, vurucu bir önizleme. Detaya girme, sadece genel havayı ver.

Yanıtı düz metin olarak ver, JSON formatında değil. Sadece önizleme metnini yaz.
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text ?? '';
      
      // Eğer JSON formatında geldiyse temizle
      final jsonMatch = RegExp(r'```json\s*([\s\S]*?)\s*```').firstMatch(text);
      if (jsonMatch != null) {
        try {
          final json = _safeJsonParse(text);
          return json['preview'] ?? json['text'] ?? text;
        } catch (_) {
          return text.trim();
        }
      }

      return text.trim();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching tomorrow preview: $e');
      }
      rethrow;
    }
  }

  Future<DailyHoroscope> fetchTomorrowHoroscope(ZodiacSign sign) async {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final dateStr = DateFormat('dd MMMM yyyy', 'tr_TR').format(tomorrow);
    final systemPrompt = await _getPersonalizedPrompt();
    
    final prompt = '''
$systemPrompt

Burç: ${sign.displayName}, Yarının tarihi: $dateStr. Zodi olarak YARININ gerçeklerini anlat.

ÖNEMLİ: Bu yarın için bir yorum, bugün için değil. Yarın ne olacağını anlat.

Yanıtı şu JSON formatında ver:
{
  "motto": "Yarının mottosu (kısa, vurucu)",
  "commentary": "Detaylı yorum (2-3 paragraf, Zodi tarzında dürüst, YARIN için)",
  "love": 0-100 arası sayı,
  "money": 0-100 arası sayı,
  "health": 0-100 arası sayı,
  "career": 0-100 arası sayı,
  "luckyColor": "Renk adı",
  "luckyNumber": 1-99 arası sayı
}
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text ?? '{}';
      
      final json = _safeJsonParse(text);
      return DailyHoroscope.fromJson(json);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching tomorrow horoscope: $e');
      }
      rethrow;
    }
  }

  Future<String> generateTarotInterpretation(String prompt) async {
    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text ?? '';

      // JSON formatında geldiyse temizle
      final jsonMatch = RegExp(r'```json\s*([\s\S]*?)\s*```').firstMatch(text);
      if (jsonMatch != null) {
        return jsonMatch.group(1) ?? text;
      }

      return text.trim();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Tarot interpretation error: $e');
      }
      rethrow;
    }
  }

  /// Günlük astrolojik ipucu (Kozmik Takvim için)
  Future<String> fetchDailyAstroTip(ZodiacSign sign, DateTime date, {String? events}) async {
    final systemPrompt = await _getPersonalizedPrompt();
    final dateStr = DateFormat('dd MMMM yyyy', 'tr_TR').format(date);

    final prompt = '''
$systemPrompt

Burç: ${sign.displayName}
Tarih: $dateStr
${events != null ? 'Bugünkü astrolojik olaylar: $events' : ''}

Zodi olarak bu gün için kısa bir kozmik ipucu ver. 2-3 cümle, samimi ve pratik.
Eğer bugün önemli bir astrolojik olay varsa (retro, dolunay, tutulma) ona özel yorum yap.

Sadece düz metin olarak yanıtla, JSON formatı kullanma. Maksimum 80 kelime.
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text?.trim() ?? 'Bugün yıldızlar senin için sessiz.';
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Astro tip error: $e');
      }
      return 'Kozmik enerjiler bugün sakin. İçsel sesini dinle.';
    }
  }

  /// Günlük güzellik tavsiyesi (Güzellik Takvimi için)
  Future<String> fetchBeautyTip(ZodiacSign sign, DateTime date, String moonPhase, String moonSign) async {
    final systemPrompt = await _getPersonalizedPrompt();
    final dateStr = DateFormat('dd MMMM yyyy', 'tr_TR').format(date);

    final prompt = '''
$systemPrompt

Burç: ${sign.displayName}
Tarih: $dateStr
Ay Fazı: $moonPhase
Ay Burcu: $moonSign

Zodi olarak bu gün için kısa bir güzellik tavsiyesi ver. Ay fazı ve ay burcuna göre saç bakımı, cilt bakımı veya genel güzellik rutini öner.
Samimi, eğlenceli ve pratik ol. 2-3 cümle yeterli.

Sadece düz metin olarak yanıtla, JSON formatı kullanma. Maksimum 60 kelime.
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text?.trim() ?? 'Bugün kendine biraz vakit ayır!';
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Beauty tip error: $e');
      }
      return 'Ay enerjisi bugün güzelliğini destekliyor. Kendine iyi bak!';
    }
  }
}
