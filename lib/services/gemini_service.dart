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

  GeminiService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
    );
  }

  Future<String> _getPersonalizedPrompt() async {
    final context = await _historyService.generatePersonalizedContext();
    return '$_baseSystemPrompt\n\n$context';
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
  "commentary": "Detaylı yorum (2-3 paragraf, Zodi tarzında dürüst)",
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
      
      final jsonMatch = RegExp(r'```json\s*([\s\S]*?)\s*```').firstMatch(text);
      final jsonStr = jsonMatch?.group(1) ?? text;
      
      final json = jsonDecode(jsonStr);
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
    } catch (e) {
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

    final response = await _model.generateContent([Content.text(prompt)]);
    final text = response.text ?? '{}';
    
    final jsonMatch = RegExp(r'```json\s*([\s\S]*?)\s*```').firstMatch(text);
    final jsonStr = jsonMatch?.group(1) ?? text;
    
    final json = jsonDecode(jsonStr);
    final analysis = DetailedAnalysis.fromJson(json);
    
    // Etkileşimi kaydet
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

    final response = await _model.generateContent([Content.text(prompt)]);
    final text = response.text ?? '{}';
    
    final jsonMatch = RegExp(r'```json\s*([\s\S]*?)\s*```').firstMatch(text);
    final jsonStr = jsonMatch?.group(1) ?? text;
    
    final json = jsonDecode(jsonStr);
    return CompatibilityResult.fromJson(json);
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

    final response = await _model.generateContent([Content.text(prompt)]);
    final text = response.text ?? '{}';
    
    final jsonMatch = RegExp(r'```json\s*([\s\S]*?)\s*```').firstMatch(text);
    final jsonStr = jsonMatch?.group(1) ?? text;
    
    return jsonDecode(jsonStr);
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

    final response = await _model.generateContent([Content.text(prompt)]);
    final text = response.text ?? '{}';
    
    final jsonMatch = RegExp(r'```json\s*([\s\S]*?)\s*```').firstMatch(text);
    final jsonStr = jsonMatch?.group(1) ?? text;
    
    return jsonDecode(jsonStr);
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
      
      final jsonMatch = RegExp(r'```json\s*([\s\S]*?)\s*```').firstMatch(text);
      final jsonStr = jsonMatch?.group(1) ?? text;
      
      final result = Map<String, dynamic>.from(jsonDecode(jsonStr) as Map);

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
      debugPrint('❌ Error in calculateRisingSign: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> interpretDream(String dreamText) async {
    final systemPrompt = await _getPersonalizedPrompt();
    
    final prompt = '''
$systemPrompt

Rüya: "$dreamText"

Bu rüyayı Zodi tarzında yorumla. Psikolojik ve sembolik anlamlarını açıkla.

Yanıtı şu JSON formatında ver:
{
  "dreamText": "$dreamText",
  "interpretation": "Rüyanın genel yorumu (2-3 paragraf, Zodi tarzında)",
  "symbolism": "Sembollerin anlamı",
  "emotionalMeaning": "Duygusal ve psikolojik anlam",
  "advice": "Zodi'den tavsiye",
  "keywords": ["Rüyadaki önemli 3-5 sembol"],
  "mood": "positive, negative, neutral veya mixed"
}
''';

    final response = await _model.generateContent([Content.text(prompt)]);
    final text = response.text ?? '{}';
    
    final jsonMatch = RegExp(r'```json\s*([\s\S]*?)\s*```').firstMatch(text);
    final jsonStr = jsonMatch?.group(1) ?? text;
    
    return jsonDecode(jsonStr);
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
        final jsonStr = jsonMatch.group(1) ?? text;
        final json = jsonDecode(jsonStr);
        return json['preview'] ?? json['text'] ?? text;
      }
      
      // Düz metin olarak döndür
      return text.trim();
    } catch (e) {
      debugPrint('❌ Error fetching tomorrow preview: $e');
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
      
      final jsonMatch = RegExp(r'```json\s*([\s\S]*?)\s*```').firstMatch(text);
      final jsonStr = jsonMatch?.group(1) ?? text;
      
      final json = jsonDecode(jsonStr);
      return DailyHoroscope.fromJson(json);
    } catch (e) {
      debugPrint('❌ Error fetching tomorrow horoscope: $e');
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
      debugPrint('❌ Tarot interpretation error: $e');
      rethrow;
    }
  }
}
