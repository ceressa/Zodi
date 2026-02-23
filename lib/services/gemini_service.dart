import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
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
import 'api_usage_service.dart';

class GeminiService {
  late final GenerativeModel _model;
  final UserHistoryService _historyService = UserHistoryService();
  final ApiUsageService _apiUsage = ApiUsageService();
  
  static const String _baseSystemPrompt = '''
Sen Zodi'sin - Astroloji dünyasının en samimi, en eğlenceli ve en dürüst rehberi.

KİŞİLİK:
- 25-30 yaş arası genç yetişkin enerjisi, en yakın arkadaş gibi
- Samimi, direkt, bazen alaycı ama her zaman sevecen
- Gerçekleri söyler ama kırıcı değil — eleştirirken bile gülümsetir
- Hem modern hem mistik — TikTok jargonu ile antik bilgeliği harmanlar
- Kuru, zeki mizah — pop kültür referansları, gündem esprileri yapar

KONUŞMA TARZI:
- Kullanıcıya ASLA burcuyla değil, İSMİYLE hitap et (profilde ismi var, onu kullan!)
- "Sen bir Koç olduğun için..." gibi robot cümleler KURMA. Bunun yerine doğal konuş:
  ✗ YANLIŞ: "Koç burcu olarak bugün enerjin yüksek olacak."
  ✓ DOĞRU: "Bugün enerji patlaması yaşayacaksın, o yüzden spor planlarını erteleme bence!"
- Burç bilgisini doğal olarak cümlelerin içine ser, kalıplaşmış giriş yapma
- "Günaydın canım", "Bak sana bir şey söyleyeyim", "Dinle beni" gibi doğal girişler kullan
- Kısa cümleler tercih et, paragraflar duvar gibi olmasın
- Emoji kullan ama abartma (cümle başına max 1)

KURALLAR:
- ASLA 'siz' deme, her zaman 'sen' de
- Kullanıcının kişisel bilgilerini (meslek, şehir, ilişki durumu, ilgi alanları) MUTLAKA yoruma dahil et
- Astroloji dışı sorulara da eğlenceli yanıt ver (maç tahmini, yemek önerisi vs.) — gönlünü al, eğlendir
- Gereksiz yere övme — dürüst ol ama sevecen ol
- Tutarlı ol — önceki yorumlarınla çelişme
''';

  /// Dinamik tarih bilgisi ile zenginleştirilmiş system prompt
  String _getDateAwareSystemPrompt() {
    final now = DateTime.now();
    final dateStr = DateFormat('dd MMMM yyyy', 'tr_TR').format(now);
    final year = now.year;
    return '''$_baseSystemPrompt

TARİH BİLGİSİ (KRİTİK):
- Bugünün tarihi: $dateStr
- Şu an $year yılındayız
- ASLA 2024 veya 2025 yılından bahsetme, geçmiş yıllara atıfta bulunma
- Tüm yorumlarını $year yılı bağlamında yap
- Hafta, ay ve mevsim referanslarını BUGÜNÜN tarihine göre ver
''';
  }

  GeminiService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
    );
  }

  /// Gemini API çağrısı yap ve kullanımı logla
  Future<GenerateContentResponse> _generate(String prompt, String feature) async {
    final response = await _model.generateContent([Content.text(prompt)]);
    // Token kullanımını logla
    final usage = response.usageMetadata;
    final inputTokens = usage?.promptTokenCount ?? ApiUsageService.estimateTokens(prompt);
    final outputTokens = usage?.candidatesTokenCount ?? ApiUsageService.estimateTokens(response.text ?? '');
    final totalTokens = usage?.totalTokenCount ?? (inputTokens + outputTokens);
    await _apiUsage.logApiCall(
      feature: feature,
      inputTokens: inputTokens,
      outputTokens: outputTokens,
      totalTokens: totalTokens,
    );
    return response;
  }

  Future<String> _getPersonalizedPrompt() async {
    final context = await _historyService.generatePersonalizedContext();
    return '${_getDateAwareSystemPrompt()}\n\n$context';
  }

  /// Kullanıcının adını al — prompt'lara doğrudan enjekte etmek için
  Future<String> _getUserName() async {
    final profile = await _historyService.getUserProfile();
    return profile?.name ?? 'arkadaş';
  }

  Future<DailyHoroscope> fetchDailyHoroscope(ZodiacSign sign) async {
    final dateStr = DateFormat('dd MMMM yyyy', 'tr_TR').format(DateTime.now());
    final systemPrompt = await _getPersonalizedPrompt();
    final userName = await _getUserName();

    final prompt = '''
$systemPrompt

Kullanıcının adı: $userName
Kullanıcının burcu: ${sign.displayName}
Bugünün tarihi: $dateStr

ÖNEMLİ YÖNERGE: Yorumuna "$userName" diye hitap ederek başla. "Sen bir ${sign.displayName} olduğun için..." gibi yapay cümleler KURMA.
Örnek giriş: "$userName, bugün harika bir gün seni bekliyor!" veya "Bak $userName, sana bir şey söyleyeyim..." gibi.
Kullanıcının mesleğine, şehrine, ilişki durumuna, ilgi alanlarına değin.
Yorumun sıcak, samimi ve kişisel olsun — sanki en yakın arkadaşıyla sohbet ediyor gibi.

Yanıtı şu JSON formatında ver:
{
  "motto": "Günün mottosu (kısa, vurucu, kişiye özel)",
  "commentary": "Detaylı yorum (2-3 paragraf, samimi arkadaş tarzında, 150-250 kelime, kullanıcının ismi ve kişisel bilgileriyle kişiselleştirilmiş)",
  "love": 0-100 arası sayı,
  "money": 0-100 arası sayı,
  "health": 0-100 arası sayı,
  "career": 0-100 arası sayı,
  "luckyColor": "Renk adı",
  "luckyNumber": 1-99 arası sayı
}
''';

    try {
      final response = await _generate(prompt, 'daily_horoscope');
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
    final userName = await _getUserName();

    final prompt = '''
$systemPrompt

Kullanıcının adı: $userName
Kullanıcının burcu: ${sign.displayName}, Konu: $category.
Kullanıcıya "$userName" diye hitap et. Burcuyla değil, kişisel bilgileriyle bağlantı kur. Samimi ve doğal bir dil kullan.

Yanıtı şu JSON formatında ver:
{
  "title": "Analiz başlığı",
  "content": "Detaylı analiz (3-4 paragraf, Zodi tarzında)",
  "percentage": 0-100 arası genel durum skoru
}
''';

    try {
      final response = await _generate(prompt, 'detailed_analysis');
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
    } catch (e) {
      debugPrint('❌ Detailed analysis error: $e');
      rethrow;
    }
  }

  Future<CompatibilityResult> fetchCompatibility(
    ZodiacSign sign1,
    ZodiacSign sign2,
  ) async {
    final systemPrompt = await _getPersonalizedPrompt();
    final userName = await _getUserName();

    final prompt = '''
$systemPrompt

Kullanıcının adı: $userName
Kullanıcının burcu ${sign1.displayName}, karşı tarafın burcu ${sign2.displayName}.
Kullanıcıya "$userName" diye hitap et. Sevgilisi/partneri varsa adını kullan. Robot gibi "Bu iki burç şöyledir" deme, doğal ve samimi anlat.

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
      final response = await _generate(prompt, 'compatibility');
      final text = response.text ?? '{}';

      final jsonMatch = RegExp(r'```json\s*([\s\S]*?)\s*```').firstMatch(text);
      final jsonStr = jsonMatch?.group(1) ?? text;

      final json = jsonDecode(jsonStr);
      return CompatibilityResult.fromJson(json);
    } catch (e) {
      debugPrint('❌ Compatibility error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> fetchWeeklyHoroscope(ZodiacSign sign) async {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    final weekRange = '${DateFormat('d MMM', 'tr_TR').format(weekStart)} - ${DateFormat('d MMM', 'tr_TR').format(weekEnd)}';
    final systemPrompt = await _getPersonalizedPrompt();
    final userName = await _getUserName();

    final prompt = '''
$systemPrompt

Kullanıcının adı: $userName
Kullanıcının burcu: ${sign.displayName}, Hafta: $weekRange.
"$userName, bu hafta senin haftanla başlıyoruz!" gibi samimi bir giriş yap. Kişisel bilgilerini yoruma dahil et.

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
      final response = await _generate(prompt, 'weekly_horoscope');
      final text = response.text ?? '{}';

      final jsonMatch = RegExp(r'```json\s*([\s\S]*?)\s*```').firstMatch(text);
      final jsonStr = jsonMatch?.group(1) ?? text;

      return jsonDecode(jsonStr);
    } catch (e) {
      debugPrint('❌ Weekly horoscope error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> fetchMonthlyHoroscope(ZodiacSign sign) async {
    final month = DateFormat('MMMM yyyy', 'tr_TR').format(DateTime.now());
    final systemPrompt = await _getPersonalizedPrompt();
    final userName = await _getUserName();

    final prompt = '''
$systemPrompt

Kullanıcının adı: $userName
Kullanıcının burcu: ${sign.displayName}, Ay: $month.
Kullanıcıya "$userName" diye hitap et. Samimi ve doğal konuş. Kişisel bilgilerini (meslek, şehir, ilişki durumu) aya özel yoruma entegre et.

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
      final response = await _generate(prompt, 'monthly_horoscope');
      final text = response.text ?? '{}';

      final jsonMatch = RegExp(r'```json\s*([\s\S]*?)\s*```').firstMatch(text);
      final jsonStr = jsonMatch?.group(1) ?? text;

      return jsonDecode(jsonStr);
    } catch (e) {
      debugPrint('❌ Monthly horoscope error: $e');
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

      final response = await _generate(prompt, 'rising_sign');
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
      final response = await _generate(prompt, 'birth_chart');
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
      debugPrint('❌ Birth chart interpretation error: $e');
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

    try {
      final response = await _generate(prompt, 'dream');
      final text = response.text ?? '{}';

      final jsonMatch = RegExp(r'```json\s*([\s\S]*?)\s*```').firstMatch(text);
      final jsonStr = jsonMatch?.group(1) ?? text;

      return jsonDecode(jsonStr);
    } catch (e) {
      debugPrint('❌ Dream interpretation error: $e');
      rethrow;
    }
  }

  Future<String> fetchTomorrowPreview(ZodiacSign sign) async {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final dateStr = DateFormat('dd MMMM yyyy', 'tr_TR').format(tomorrow);
    final systemPrompt = await _getPersonalizedPrompt();
    final userName = await _getUserName();

    final prompt = '''
$systemPrompt

Kullanıcının adı: $userName
Kullanıcının burcu: ${sign.displayName}, Yarının tarihi: $dateStr.

Kullanıcıya "$userName" diye hitap et. Yarın için 2-3 cümlelik kısa, merak uyandıran, samimi bir önizleme yap. Doğal konuş.

Yanıtı düz metin olarak ver, JSON formatında değil. Sadece önizleme metnini yaz.
''';

    try {
      final response = await _generate(prompt, 'tomorrow_preview');
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

  /// 7 gunluk emoji tahmini
  Future<List<Map<String, dynamic>>> fetchWeeklyEmojiForecast(ZodiacSign sign) async {
    final now = DateTime.now();
    final days = List.generate(7, (i) {
      final date = now.add(Duration(days: i));
      return DateFormat('EEEE d MMMM', 'tr_TR').format(date);
    });
    final systemPrompt = await _getPersonalizedPrompt();

    final prompt = '''
$systemPrompt

Burc: ${sign.displayName}
Tarihler: ${days.join(', ')}

Her gun icin bir emoji, ruh hali puani (0-100) ve tek kelimelik Turkce anahtar kelime ver.

Yaniti su JSON formatinda ver:
```json
{
  "forecasts": [
    {"emoji": "\u{1F525}", "moodScore": 85, "keyword": "Enerjik"},
    {"emoji": "\u{2728}", "moodScore": 72, "keyword": "Parlak"},
    {"emoji": "\u{1F324}", "moodScore": 55, "keyword": "Sakin"},
    {"emoji": "\u{1F4AB}", "moodScore": 78, "keyword": "Ilham"},
    {"emoji": "\u{1F327}", "moodScore": 30, "keyword": "Durgun"},
    {"emoji": "\u{1F525}", "moodScore": 90, "keyword": "Atesli"},
    {"emoji": "\u{2728}", "moodScore": 65, "keyword": "Huzurlu"}
  ]
}
```
''';

    try {
      final response = await _generate(prompt, 'weekly_emoji_forecast');
      final text = response.text ?? '{}';

      final jsonMatch = RegExp(r'```json\s*([\s\S]*?)\s*```').firstMatch(text);
      final jsonStr = jsonMatch?.group(1) ?? text;

      final json = jsonDecode(jsonStr);
      final forecasts = json['forecasts'] as List<dynamic>? ?? [];
      return forecasts.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('Weekly emoji forecast error: $e');
      rethrow;
    }
  }

  Future<DailyHoroscope> fetchTomorrowHoroscope(ZodiacSign sign) async {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final dateStr = DateFormat('dd MMMM yyyy', 'tr_TR').format(tomorrow);
    final systemPrompt = await _getPersonalizedPrompt();
    final userName = await _getUserName();

    final prompt = '''
$systemPrompt

Kullanıcının adı: $userName
Kullanıcının burcu: ${sign.displayName}, Yarının tarihi: $dateStr.
Kullanıcıya "$userName" diye hitap et. Doğal ve samimi konuş. Burcuyla değil kişisel bilgileriyle bağ kur.

ÖNEMLİ: Bu YARIN için bir yorum, bugün için değil.

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
      final response = await _generate(prompt, 'tomorrow_horoscope');
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
      final response = await _generate(prompt, 'tarot');
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
      final response = await _generate(prompt, 'astro_tip');
      return response.text?.trim() ?? 'Bugün yıldızlar senin için sessiz.';
    } catch (e) {
      debugPrint('❌ Astro tip error: $e');
      return 'Kozmik enerjiler bugün sakin. İçsel sesini dinle.';
    }
  }

  /// Eglenceli astroloji ozelliklerini uret (Fun Features)
  Future<Map<String, dynamic>> generateFunFeature({
    required String featureId,
    required String promptTemplate,
    required String birthDate,
    required String birthTime,
    required String birthPlace,
    required String zodiacSign,
    String? risingSign,
    String? moonSign,
  }) async {
    final systemPrompt = await _getPersonalizedPrompt();
    final userName = await _getUserName();

    final prompt = '''
$systemPrompt

Kullanıcının adı: $userName
DOGUM BILGILERI:
- Tarih: $birthDate | Saat: $birthTime | Yer: $birthPlace
- Gunes Burcu: $zodiacSign
${risingSign != null ? '- Yukselen Burc: $risingSign' : ''}
${moonSign != null ? '- Ay Burcu: $moonSign' : ''}

ÖNEMLİ: Kullanıcıya "$userName" diye hitap et. Doğal, samimi ve eğlenceli konuş. "Sen bir X burcusun" gibi klişe cümleler KURMA.

$promptTemplate

Yanitini MUTLAKA su JSON formatinda ver:
```json
{
  "mainResult": "Tek kelime veya kisa cümle olarak ana sonuc",
  "emoji": "Sonucu temsil eden tek bir emoji",
  "description": "2-3 paragraf Zodi tarzinda aciklama (150-250 kelime)",
  "details": ["Detay 1", "Detay 2", "Detay 3", "Detay 4"]
}
```
''';

    try {
      final response = await _generate(prompt, 'fun_feature');
      final text = response.text ?? '{}';

      final jsonMatch = RegExp(r'```json\s*([\s\S]*?)\s*```').firstMatch(text);
      final jsonStr = jsonMatch?.group(1) ?? text;

      final json = jsonDecode(jsonStr) as Map<String, dynamic>;

      // Etkilesimi kaydet
      await _historyService.addInteraction(
        InteractionHistory(
          timestamp: DateTime.now(),
          interactionType: 'fun_feature',
          content: json['mainResult'] ?? '',
          context: {
            'featureId': featureId,
            'zodiac': zodiacSign,
          },
        ),
      );

      return json;
    } catch (e) {
      debugPrint('Fun feature generation error: $e');
      rethrow;
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
      final response = await _generate(prompt, 'beauty_tip');
      return response.text?.trim() ?? 'Bugün kendine biraz vakit ayır!';
    } catch (e) {
      debugPrint('❌ Beauty tip error: $e');
      return 'Ay enerjisi bugün güzelliğini destekliyor. Kendine iyi bak!';
    }
  }

  // ============ RUH EŞİ ÇİZİMİ (IMAGEN 3) ============

  /// Ruh eşi çizimi oluştur — iki aşamalı: Gemini text → Imagen 3 görsel
  /// [gender]: Ruh eşinin cinsiyeti ('erkek' veya 'kadın') — kullanıcı ekrandan seçiyor
  Future<Uint8List> generateSoulmateSketch({
    required String zodiacSign,
    required String birthDate,
    required String gender,
    String? risingSign,
    String? moonSign,
  }) async {
    final soulmateGenderEn = gender == 'erkek' ? 'male' : 'female';

    // Adım 1: Gemini ile fiziksel tanım oluştur
    final descriptionPrompt = '''
GÖREV: Aşağıdaki doğum bilgilerine göre bu kişinin ruh eşinin FİZİKSEL GÖRÜNÜMÜNÜ tanımla.

Ruh eşinin cinsiyeti: $gender

Doğum Bilgileri:
- Güneş Burcu: $zodiacSign
- Doğum Tarihi: $birthDate
${risingSign != null ? '- Yükselen Burç: $risingSign' : ''}
${moonSign != null ? '- Ay Burcu: $moonSign' : ''}

KURALLAR:
1. Ruh eşi $gender olmalı
2. Türk/Akdeniz fenotipine uygun: koyu veya kestane saç, ela/kahve/yeşil göz, buğday ten, doğal Anadolu tipleri
3. Sıradan, günlük bir insan tarif et — manken veya ünlü gibi DEĞİL
4. Makyajsız, doğal hali ile tanımla
5. Saç rengi/stili, göz rengi, ten rengi, yüz şekli gibi somut detaylar ver
6. Yanıtı tamamen İNGİLİZCE yaz
7. Maksimum 50 kelime, sadece fiziksel tanım, başka hiçbir şey yazma

Yanıt:
''';

    try {
      final descResponse = await _generate(descriptionPrompt, 'soulmate_sketch_desc');
      final description = descResponse.text?.trim() ?? '';

      if (description.isEmpty) {
        throw Exception('Fiziksel tanım oluşturulamadı');
      }

      // Adım 2: Doğal, günlük, gerçekçi fotoğraf — farklı mekanlardan rastgele seç
      final locations = [
        'sitting at a simple Turkish café table with a tea glass, flat indoor daylight',
        'walking on a narrow street in an old Turkish neighborhood, cloudy day',
        'standing at a bus stop checking their phone, ordinary overcast light',
        'sitting on a park bench, flat natural daylight, no dramatic lighting',
        'at a simple kitchen counter making coffee, normal room lighting',
        'browsing shelves at a small grocery store, fluorescent store lighting',
        'sitting on apartment stairs scrolling phone, ordinary hallway light',
        'at an outdoor market carrying a bag, midday flat sunlight',
        'leaning on a wall texting someone, shade under a building overhang',
        'waiting in line at a bakery, normal indoor light from window',
        'walking on a sidewalk with headphones, regular daytime light',
        'sitting at a work desk in front of a laptop, office lighting',
      ];
      final randomLocation = locations[DateTime.now().millisecond % locations.length];

      final imagePrompt = 'iPhone photo of a real ordinary $soulmateGenderEn person, '
          'Turkish/Mediterranean ethnicity, age 25-35: '
          '$description. '
          '$randomLocation. '
          'Caught in a random moment, NOT posing, NOT looking at camera, doing something mundane, '
          'genuine bored or neutral expression, natural slouchy body language, '
          'zero makeup, messy or unstyled hair, wrinkled everyday clothes, '
          'average looking real person NOT attractive NOT a model, '
          'slightly unflattering angle like a friend took this photo without warning, '
          'no color grading, no filters, no dramatic lighting, no bokeh, '
          'visible skin texture with pores and blemishes, '
          'slightly grainy low quality like a real phone camera photo, '
          'NOT a painting, NOT digital art, NOT illustration, NOT studio shot, NOT glamorous, NOT cinematic. '
          'Raw unedited phone snapshot look. No text, no watermark.';

      final imageBytes = await _generateImageWithImagen(imagePrompt);

      // Kullanımı logla
      await _apiUsage.logApiCall(
        feature: 'soulmate_sketch_image',
        inputTokens: 0,
        outputTokens: 0,
        totalTokens: 0,
      );

      return imageBytes;
    } catch (e) {
      debugPrint('❌ Soulmate sketch error: $e');
      rethrow;
    }
  }

  /// Imagen 4 REST API ile görsel üret
  Future<Uint8List> _generateImageWithImagen(String prompt) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY bulunamadı');
    }

    // Önce Imagen 4 dene, başarısız olursa Gemini native image generation kullan
    try {
      return await _tryImagen4(prompt, apiKey);
    } catch (e) {
      debugPrint('⚠️ Imagen 4 başarısız, Gemini native deneniyor: $e');
      return await _tryGeminiNativeImage(prompt, apiKey);
    }
  }

  /// Imagen 4 REST API
  Future<Uint8List> _tryImagen4(String prompt, String apiKey) async {
    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/'
      'imagen-4.0-generate-001:predict',
    );

    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 60);

    try {
      final request = await client.postUrl(uri);
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('x-goog-api-key', apiKey);
      request.write(jsonEncode({
        'instances': [
          {'prompt': prompt}
        ],
        'parameters': {
          'sampleCount': 1,
          'aspectRatio': '3:4',
        },
      }));

      final response = await request.close().timeout(
        const Duration(seconds: 90),
        onTimeout: () => throw Exception('Görsel oluşturma zaman aşımına uğradı'),
      );

      final responseBody = await response.transform(utf8.decoder).join();
      final json = jsonDecode(responseBody) as Map<String, dynamic>;

      if (response.statusCode != 200) {
        final errorMsg = (json['error'] as Map<String, dynamic>?)?['message']
            ?? 'Bilinmeyen hata (${response.statusCode})';
        throw Exception('Imagen API hatası: $errorMsg');
      }

      final predictions = json['predictions'] as List<dynamic>?;
      if (predictions == null || predictions.isEmpty) {
        throw Exception('Görsel üretilemedi — API boş yanıt döndü');
      }

      final base64Image = predictions[0]['bytesBase64Encoded'] as String?;
      if (base64Image == null || base64Image.isEmpty) {
        throw Exception('Görsel verisi alınamadı');
      }

      return base64Decode(base64Image);
    } finally {
      client.close();
    }
  }

  /// Gemini native image generation (fallback)
  Future<Uint8List> _tryGeminiNativeImage(String prompt, String apiKey) async {
    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/'
      'gemini-2.5-flash-preview-05-20:generateContent',
    );

    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 90);

    try {
      final request = await client.postUrl(uri);
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('x-goog-api-key', apiKey);
      request.write(jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': 'Generate an image: $prompt'}
            ]
          }
        ],
        'generationConfig': {
          'responseModalities': ['TEXT', 'IMAGE'],
        },
      }));

      final response = await request.close().timeout(
        const Duration(seconds: 90),
        onTimeout: () => throw Exception('Görsel oluşturma zaman aşımına uğradı'),
      );

      final responseBody = await response.transform(utf8.decoder).join();
      final json = jsonDecode(responseBody) as Map<String, dynamic>;

      if (response.statusCode != 200) {
        final errorMsg = (json['error'] as Map<String, dynamic>?)?['message']
            ?? 'Bilinmeyen hata (${response.statusCode})';
        throw Exception('Gemini Image hatası: $errorMsg');
      }

      // Gemini native response: candidates[0].content.parts[] — look for inlineData
      final candidates = json['candidates'] as List<dynamic>?;
      if (candidates == null || candidates.isEmpty) {
        throw Exception('Gemini görsel üretemedi — boş yanıt');
      }

      final parts = (candidates[0]['content'] as Map<String, dynamic>?)?['parts']
          as List<dynamic>?;
      if (parts == null) throw Exception('Yanıtta parts bulunamadı');

      for (final part in parts) {
        final inlineData = part['inlineData'] as Map<String, dynamic>?;
        if (inlineData != null) {
          final base64Data = inlineData['data'] as String?;
          if (base64Data != null && base64Data.isNotEmpty) {
            return base64Decode(base64Data);
          }
        }
      }

      throw Exception('Yanıtta görsel verisi bulunamadı');
    } finally {
      client.close();
    }
  }
}
