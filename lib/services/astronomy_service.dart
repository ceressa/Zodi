import 'package:flutter/foundation.dart';
import 'package:sweph/sweph.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/zodiac_sign.dart';
import '../models/beauty_day.dart';

/// Service for accurate astronomical calculations using Swiss Ephemeris
class AstronomyService {
  static bool _initialized = false;
  static bool _timezoneInitialized = false;

  /// Initialize Swiss Ephemeris
  static Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      if (!_timezoneInitialized) {
        tz.initializeTimeZones();
        _timezoneInitialized = true;
      }

      // Initialize Sweph with bundled ephemeris files
      await Sweph.init(
        epheAssets: [
          "packages/sweph/assets/ephe/sefstars.txt",
          "packages/sweph/assets/ephe/seas_18.se1",
          "packages/sweph/assets/ephe/semo_18.se1",
          "packages/sweph/assets/ephe/sepl_18.se1",
        ],
      );
      _initialized = true;
      if (kDebugMode) debugPrint('Swiss Ephemeris initialized');
    } catch (e) {
      if (kDebugMode) debugPrint('Error initializing Swiss Ephemeris: $e');
      rethrow;
    }
  }

  /// Calculate rising sign (ascendant) based on birth data
  static Future<Map<String, dynamic>> calculateRisingSign({
    required DateTime birthDate,
    required String birthTime, // HH:mm format
    required String birthPlace,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    try {
      // Parse birth time
      final timeParts = birthTime.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      // Convert local birth time (Turkey) to UTC for Swiss Ephemeris
      final istanbulLocation = tz.getLocation('Europe/Istanbul');
      final birthDateTimeLocal = tz.TZDateTime(
        istanbulLocation,
        birthDate.year,
        birthDate.month,
        birthDate.day,
        hour,
        minute,
      );
      final birthDateTimeUtc = birthDateTimeLocal.toUtc();

      // Get coordinates for birth place (simplified - in production use geocoding API)
      final coords = _getCoordinates(birthPlace);
      
      // Calculate Julian day
      final julianDay = Sweph.swe_julday(
        birthDateTimeUtc.year,
        birthDateTimeUtc.month,
        birthDateTimeUtc.day,
        birthDateTimeUtc.hour +
            birthDateTimeUtc.minute / 60.0 +
            birthDateTimeUtc.second / 3600.0,
        CalendarType.SE_GREG_CAL,
      );

      // Calculate houses (Placidus system)
      final houses = Sweph.swe_houses(
        julianDay,
        coords['latitude']!,
        coords['longitude']!,
        Hsys.P, // Placidus house system
      );

      // Ascendant is the cusp of the 1st house
      final ascendantDegree = houses.cusps[1];
      
      // Calculate Sun position
      final sunCalc = Sweph.swe_calc_ut(
        julianDay,
        HeavenlyBody.SE_SUN,
        SwephFlag.SEFLG_SWIEPH,
      );
      final sunDegree = sunCalc.longitude;

      // Calculate Moon position
      final moonCalc = Sweph.swe_calc_ut(
        julianDay,
        HeavenlyBody.SE_MOON,
        SwephFlag.SEFLG_SWIEPH,
      );
      final moonDegree = moonCalc.longitude;

      // Convert degrees to zodiac signs
      final risingSign = _degreeToZodiacSign(ascendantDegree);
      final sunSign = _degreeToZodiacSign(sunDegree);
      final moonSign = _degreeToZodiacSign(moonDegree);

      if (kDebugMode) {
        debugPrint('Calculated: Sun=$sunSign, Rising=$risingSign, Moon=$moonSign');
        debugPrint('Local birth time: $birthDateTimeLocal');
        debugPrint('UTC birth time: $birthDateTimeUtc');
        debugPrint('Degrees: Sun=${sunDegree.toStringAsFixed(2)}, Asc=${ascendantDegree.toStringAsFixed(2)}, Moon=${moonDegree.toStringAsFixed(2)}');
      }

      return {
        'sunSign': sunSign,
        'risingSign': risingSign,
        'moonSign': moonSign,
        'sunDegree': sunDegree,
        'ascendantDegree': ascendantDegree,
        'moonDegree': moonDegree,
      };
    } catch (e) {
      if (kDebugMode) debugPrint('Error calculating rising sign: $e');
      rethrow;
    }
  }

  /// Calculate full birth chart with all planet positions and house placements
  static Future<Map<String, dynamic>> calculateBirthChart({
    required DateTime birthDate,
    required String birthTime, // HH:mm format
    required String birthPlace,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    try {
      // Parse birth time
      final timeParts = birthTime.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      // Convert local birth time (Turkey) to UTC for Swiss Ephemeris
      final istanbulLocation = tz.getLocation('Europe/Istanbul');
      final birthDateTimeLocal = tz.TZDateTime(
        istanbulLocation,
        birthDate.year,
        birthDate.month,
        birthDate.day,
        hour,
        minute,
      );
      final birthDateTimeUtc = birthDateTimeLocal.toUtc();

      // Get coordinates for birth place
      final coords = _getCoordinates(birthPlace);

      // Calculate Julian day
      final julianDay = Sweph.swe_julday(
        birthDateTimeUtc.year,
        birthDateTimeUtc.month,
        birthDateTimeUtc.day,
        birthDateTimeUtc.hour +
            birthDateTimeUtc.minute / 60.0 +
            birthDateTimeUtc.second / 3600.0,
        CalendarType.SE_GREG_CAL,
      );

      // Calculate houses (Placidus system)
      final houses = Sweph.swe_houses(
        julianDay,
        coords['latitude']!,
        coords['longitude']!,
        Hsys.P, // Placidus house system
      );

      // House cusps: houses.cusps[1] = 1st house cusp (ascendant), ..., houses.cusps[12] = 12th house cusp
      final List<double> houseCusps = List.generate(12, (i) => houses.cusps[i + 1]);

      // Ascendant
      final ascendantDegree = houses.cusps[1];
      final ascSign = _degreeToZodiacSignTurkish(ascendantDegree);
      final ascSymbol = _degreeToZodiacSymbol(ascendantDegree);
      final ascDegreeInSign = ascendantDegree % 30;

      // Planet definitions: HeavenlyBody constant, Turkish name
      final planetDefs = [
        {'body': HeavenlyBody.SE_SUN, 'name': 'Güneş'},
        {'body': HeavenlyBody.SE_MOON, 'name': 'Ay'},
        {'body': HeavenlyBody.SE_MERCURY, 'name': 'Merkür'},
        {'body': HeavenlyBody.SE_VENUS, 'name': 'Venüs'},
        {'body': HeavenlyBody.SE_MARS, 'name': 'Mars'},
        {'body': HeavenlyBody.SE_JUPITER, 'name': 'Jüpiter'},
        {'body': HeavenlyBody.SE_SATURN, 'name': 'Satürn'},
        {'body': HeavenlyBody.SE_URANUS, 'name': 'Uranüs'},
        {'body': HeavenlyBody.SE_NEPTUNE, 'name': 'Neptün'},
        {'body': HeavenlyBody.SE_PLUTO, 'name': 'Plüton'},
      ];

      // Calculate each planet's position
      final List<Map<String, dynamic>> planets = [];
      for (final planetDef in planetDefs) {
        final body = planetDef['body'] as HeavenlyBody;
        final name = planetDef['name'] as String;

        final calc = Sweph.swe_calc_ut(
          julianDay,
          body,
          SwephFlag.SEFLG_SWIEPH,
        );
        final longitude = calc.longitude;
        final sign = _degreeToZodiacSignTurkish(longitude);
        final symbol = _degreeToZodiacSymbol(longitude);
        final degreeInSign = double.parse((longitude % 30).toStringAsFixed(1));
        final house = _determineHouse(longitude, houseCusps);

        planets.add({
          'name': name,
          'sign': sign,
          'signSymbol': symbol,
          'degree': degreeInSign,
          'house': house,
          'longitude': double.parse(longitude.toStringAsFixed(4)),
        });
      }

      if (kDebugMode) {
        debugPrint('Birth chart calculated for $birthPlace on $birthDate at $birthTime');
        for (final p in planets) {
          debugPrint('  ${p['name']}: ${p['sign']} ${p['signSymbol']} ${p['degree']} (Ev ${p['house']})');
        }
      }

      return {
        'planets': planets,
        'houses': houseCusps,
        'ascendant': {
          'sign': ascSign,
          'signSymbol': ascSymbol,
          'degree': double.parse(ascDegreeInSign.toStringAsFixed(1)),
        },
      };
    } catch (e) {
      if (kDebugMode) debugPrint('Error calculating birth chart: $e');
      rethrow;
    }
  }

  /// Determine which house (1-12) a planet falls in based on house cusps
  static int _determineHouse(double planetLongitude, List<double> houseCusps) {
    final planet = planetLongitude % 360;
    for (int i = 0; i < 12; i++) {
      final cuspStart = houseCusps[i] % 360;
      final cuspEnd = houseCusps[(i + 1) % 12] % 360;

      if (cuspStart < cuspEnd) {
        // Normal case: cusp doesn't cross 0°
        if (planet >= cuspStart && planet < cuspEnd) {
          return i + 1;
        }
      } else {
        // Cusp crosses 0° Aries (e.g., 350° to 20°)
        if (planet >= cuspStart || planet < cuspEnd) {
          return i + 1;
        }
      }
    }
    // Fallback: should not happen, but return house 1
    return 1;
  }

  /// Convert ecliptic longitude to zodiac symbol
  static String _degreeToZodiacSymbol(double degree) {
    final normalizedDegree = degree % 360;
    final signIndex = (normalizedDegree / 30).floor();
    const symbols = ['♈', '♉', '♊', '♋', '♌', '♍', '♎', '♏', '♐', '♑', '♒', '♓'];
    return symbols[signIndex % 12];
  }

  /// Verilen tarih için ay fazını hesapla (Swiss Ephemeris ile)
  static Future<MoonPhase> getMoonPhase(DateTime date) async {
    if (!_initialized) {
      await initialize();
    }

    try {
      final utcDate = date.toUtc();
      final julianDay = Sweph.swe_julday(
        utcDate.year,
        utcDate.month,
        utcDate.day,
        utcDate.hour + utcDate.minute / 60.0,
        CalendarType.SE_GREG_CAL,
      );

      // Güneş ve Ay pozisyonlarını hesapla
      final sunCalc = Sweph.swe_calc_ut(
        julianDay,
        HeavenlyBody.SE_SUN,
        SwephFlag.SEFLG_SWIEPH,
      );
      final moonCalc = Sweph.swe_calc_ut(
        julianDay,
        HeavenlyBody.SE_MOON,
        SwephFlag.SEFLG_SWIEPH,
      );

      // Ay-Güneş açı farkı (elongation)
      double elongation = (moonCalc.longitude - sunCalc.longitude) % 360;
      if (elongation < 0) elongation += 360;

      // Açı farkına göre ay fazını belirle
      if (elongation < 22.5 || elongation >= 337.5) {
        return MoonPhase.newMoon;
      } else if (elongation < 67.5) {
        return MoonPhase.waxingCrescent;
      } else if (elongation < 112.5) {
        return MoonPhase.firstQuarter;
      } else if (elongation < 157.5) {
        return MoonPhase.waxingGibbous;
      } else if (elongation < 202.5) {
        return MoonPhase.fullMoon;
      } else if (elongation < 247.5) {
        return MoonPhase.waningGibbous;
      } else if (elongation < 292.5) {
        return MoonPhase.lastQuarter;
      } else {
        return MoonPhase.waningCrescent;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error calculating moon phase: $e');
      // Fallback: basit hesaplama
      return _simpleMoonPhase(date);
    }
  }

  /// Verilen tarihte Ay'ın hangi burçta olduğunu hesapla
  static Future<String> getMoonSign(DateTime date) async {
    if (!_initialized) {
      await initialize();
    }

    try {
      final utcDate = date.toUtc();
      final julianDay = Sweph.swe_julday(
        utcDate.year,
        utcDate.month,
        utcDate.day,
        utcDate.hour + utcDate.minute / 60.0,
        CalendarType.SE_GREG_CAL,
      );

      final moonCalc = Sweph.swe_calc_ut(
        julianDay,
        HeavenlyBody.SE_MOON,
        SwephFlag.SEFLG_SWIEPH,
      );

      return _degreeToZodiacSignTurkish(moonCalc.longitude);
    } catch (e) {
      if (kDebugMode) debugPrint('Error calculating moon sign: $e');
      return 'Koç'; // Fallback
    }
  }

  /// Basit ay fazı hesaplama (fallback)
  static MoonPhase _simpleMoonPhase(DateTime date) {
    // Bilinen yeniay referansı: 6 Ocak 2000
    const knownNewMoon = 2451550.1; // Julian day
    final jd = Sweph.swe_julday(
      date.year, date.month, date.day,
      date.hour + date.minute / 60.0,
      CalendarType.SE_GREG_CAL,
    );
    final daysSinceNew = jd - knownNewMoon;
    final lunarCycle = 29.53058770576;
    final phase = (daysSinceNew % lunarCycle) / lunarCycle;

    if (phase < 0.0625) return MoonPhase.newMoon;
    if (phase < 0.1875) return MoonPhase.waxingCrescent;
    if (phase < 0.3125) return MoonPhase.firstQuarter;
    if (phase < 0.4375) return MoonPhase.waxingGibbous;
    if (phase < 0.5625) return MoonPhase.fullMoon;
    if (phase < 0.6875) return MoonPhase.waningGibbous;
    if (phase < 0.8125) return MoonPhase.lastQuarter;
    if (phase < 0.9375) return MoonPhase.waningCrescent;
    return MoonPhase.newMoon;
  }

  /// Derece → Türkçe burç adı
  static String _degreeToZodiacSignTurkish(double degree) {
    final normalizedDegree = degree % 360;
    final signIndex = (normalizedDegree / 30).floor();
    const signs = [
      'Koç', 'Boğa', 'İkizler', 'Yengeç',
      'Aslan', 'Başak', 'Terazi', 'Akrep',
      'Yay', 'Oğlak', 'Kova', 'Balık',
    ];
    return signs[signIndex % 12];
  }

  /// Convert ecliptic longitude (0-360°) to zodiac sign
  static String _degreeToZodiacSign(double degree) {
    // Normalize to 0-360
    final normalizedDegree = degree % 360;
    
    // Each sign is 30 degrees
    final signIndex = (normalizedDegree / 30).floor();
    
    const signs = [
      'aries',      // 0-30°
      'taurus',     // 30-60°
      'gemini',     // 60-90°
      'cancer',     // 90-120°
      'leo',        // 120-150°
      'virgo',      // 150-180°
      'libra',      // 180-210°
      'scorpio',    // 210-240°
      'sagittarius', // 240-270°
      'capricorn',  // 270-300°
      'aquarius',   // 300-330°
      'pisces',     // 330-360°
    ];
    
    return signs[signIndex % 12];
  }

  /// Get approximate coordinates for Turkish cities
  /// In production, use a proper geocoding API
  static Map<String, double> _getCoordinates(String place) {
    final placeLower = place.toLowerCase().trim();
    
    // Turkish cities coordinates (latitude, longitude)
    final cities = {
      'adana': {'latitude': 37.0000, 'longitude': 35.3213},
      'adıyaman': {'latitude': 37.7648, 'longitude': 38.2786},
      'afyonkarahisar': {'latitude': 38.7507, 'longitude': 30.5567},
      'afyon': {'latitude': 38.7507, 'longitude': 30.5567},
      'ağrı': {'latitude': 39.7191, 'longitude': 43.0503},
      'agri': {'latitude': 39.7191, 'longitude': 43.0503},
      'aksaray': {'latitude': 38.3687, 'longitude': 34.0370},
      'amasya': {'latitude': 40.6499, 'longitude': 35.8353},
      'ankara': {'latitude': 39.9334, 'longitude': 32.8597},
      'antalya': {'latitude': 36.8969, 'longitude': 30.7133},
      'ardahan': {'latitude': 41.1105, 'longitude': 42.7022},
      'artvin': {'latitude': 41.1828, 'longitude': 41.8183},
      'aydın': {'latitude': 37.8560, 'longitude': 27.8416},
      'aydin': {'latitude': 37.8560, 'longitude': 27.8416},
      'balıkesir': {'latitude': 39.6484, 'longitude': 27.8826},
      'balikesir': {'latitude': 39.6484, 'longitude': 27.8826},
      'bartın': {'latitude': 41.5811, 'longitude': 32.4610},
      'bartin': {'latitude': 41.5811, 'longitude': 32.4610},
      'batman': {'latitude': 37.8812, 'longitude': 41.1351},
      'bayburt': {'latitude': 40.2552, 'longitude': 40.2249},
      'bilecik': {'latitude': 40.0567, 'longitude': 30.0665},
      'bingöl': {'latitude': 38.8854, 'longitude': 40.4984},
      'bingol': {'latitude': 38.8854, 'longitude': 40.4984},
      'bitlis': {'latitude': 38.4001, 'longitude': 42.1089},
      'bolu': {'latitude': 40.5760, 'longitude': 31.5788},
      'burdur': {'latitude': 37.4613, 'longitude': 30.0665},
      'bursa': {'latitude': 40.1826, 'longitude': 29.0665},
      'çanakkale': {'latitude': 40.1553, 'longitude': 26.4142},
      'canakkale': {'latitude': 40.1553, 'longitude': 26.4142},
      'çankırı': {'latitude': 40.6013, 'longitude': 33.6134},
      'cankiri': {'latitude': 40.6013, 'longitude': 33.6134},
      'çorum': {'latitude': 40.5506, 'longitude': 34.9556},
      'corum': {'latitude': 40.5506, 'longitude': 34.9556},
      'denizli': {'latitude': 37.7765, 'longitude': 29.0864},
      'diyarbakır': {'latitude': 37.9144, 'longitude': 40.2306},
      'diyarbakir': {'latitude': 37.9144, 'longitude': 40.2306},
      'düzce': {'latitude': 40.8438, 'longitude': 31.1565},
      'duzce': {'latitude': 40.8438, 'longitude': 31.1565},
      'edirne': {'latitude': 41.6771, 'longitude': 26.5557},
      'elazığ': {'latitude': 38.6810, 'longitude': 39.2264},
      'elazig': {'latitude': 38.6810, 'longitude': 39.2264},
      'erzincan': {'latitude': 39.7500, 'longitude': 39.5000},
      'erzurum': {'latitude': 39.9043, 'longitude': 41.2678},
      'eskişehir': {'latitude': 39.7767, 'longitude': 30.5206},
      'eskisehir': {'latitude': 39.7767, 'longitude': 30.5206},
      'gaziantep': {'latitude': 37.0662, 'longitude': 37.3833},
      'giresun': {'latitude': 40.9128, 'longitude': 38.3895},
      'gümüşhane': {'latitude': 40.4386, 'longitude': 39.5086},
      'gumushane': {'latitude': 40.4386, 'longitude': 39.5086},
      'hakkari': {'latitude': 37.5744, 'longitude': 43.7408},
      'hatay': {'latitude': 36.4018, 'longitude': 36.3498},
      'ığdır': {'latitude': 39.8880, 'longitude': 44.0048},
      'igdir': {'latitude': 39.8880, 'longitude': 44.0048},
      'isparta': {'latitude': 37.7648, 'longitude': 30.5566},
      'istanbul': {'latitude': 41.0082, 'longitude': 28.9784},
      'İstanbul': {'latitude': 41.0082, 'longitude': 28.9784},
      'izmir': {'latitude': 38.4237, 'longitude': 27.1428},
      'İzmir': {'latitude': 38.4237, 'longitude': 27.1428},
      'kahramanmaraş': {'latitude': 37.5858, 'longitude': 36.9371},
      'kahramanmaras': {'latitude': 37.5858, 'longitude': 36.9371},
      'karabük': {'latitude': 41.2061, 'longitude': 32.6204},
      'karabuk': {'latitude': 41.2061, 'longitude': 32.6204},
      'karaman': {'latitude': 37.1759, 'longitude': 33.2287},
      'kars': {'latitude': 40.6167, 'longitude': 43.1000},
      'kastamonu': {'latitude': 41.3887, 'longitude': 33.7827},
      'kayseri': {'latitude': 38.7312, 'longitude': 35.4787},
      'kırıkkale': {'latitude': 39.8468, 'longitude': 33.5153},
      'kirikkale': {'latitude': 39.8468, 'longitude': 33.5153},
      'kırklareli': {'latitude': 41.7333, 'longitude': 27.2167},
      'kirklareli': {'latitude': 41.7333, 'longitude': 27.2167},
      'kırşehir': {'latitude': 39.1425, 'longitude': 34.1709},
      'kirsehir': {'latitude': 39.1425, 'longitude': 34.1709},
      'kilis': {'latitude': 36.7184, 'longitude': 37.1212},
      'kocaeli': {'latitude': 40.8533, 'longitude': 29.8815},
      'konya': {'latitude': 37.8746, 'longitude': 32.4932},
      'kütahya': {'latitude': 39.4242, 'longitude': 29.9833},
      'kutahya': {'latitude': 39.4242, 'longitude': 29.9833},
      'malatya': {'latitude': 38.3552, 'longitude': 38.3095},
      'manisa': {'latitude': 38.6191, 'longitude': 27.4289},
      'mardin': {'latitude': 37.3212, 'longitude': 40.7245},
      'mersin': {'latitude': 36.8121, 'longitude': 34.6415},
      'muğla': {'latitude': 37.2153, 'longitude': 28.3636},
      'mugla': {'latitude': 37.2153, 'longitude': 28.3636},
      'muş': {'latitude': 38.9462, 'longitude': 41.7539},
      'mus': {'latitude': 38.9462, 'longitude': 41.7539},
      'nevşehir': {'latitude': 38.6939, 'longitude': 34.6857},
      'nevsehir': {'latitude': 38.6939, 'longitude': 34.6857},
      'niğde': {'latitude': 37.9667, 'longitude': 34.6833},
      'nigde': {'latitude': 37.9667, 'longitude': 34.6833},
      'ordu': {'latitude': 40.9839, 'longitude': 37.8764},
      'osmaniye': {'latitude': 37.2130, 'longitude': 36.1763},
      'rize': {'latitude': 41.0201, 'longitude': 40.5234},
      'sakarya': {'latitude': 40.6940, 'longitude': 30.4358},
      'samsun': {'latitude': 41.2867, 'longitude': 36.3300},
      'siirt': {'latitude': 37.9333, 'longitude': 41.9500},
      'sinop': {'latitude': 42.0231, 'longitude': 35.1531},
      'sivas': {'latitude': 39.7477, 'longitude': 37.0179},
      'şanlıurfa': {'latitude': 37.1591, 'longitude': 38.7969},
      'sanliurfa': {'latitude': 37.1591, 'longitude': 38.7969},
      'urfa': {'latitude': 37.1591, 'longitude': 38.7969},
      'şırnak': {'latitude': 37.4187, 'longitude': 42.4918},
      'sirnak': {'latitude': 37.4187, 'longitude': 42.4918},
      'tekirdağ': {'latitude': 40.9833, 'longitude': 27.5167},
      'tekirdag': {'latitude': 40.9833, 'longitude': 27.5167},
      'tokat': {'latitude': 40.3167, 'longitude': 36.5500},
      'trabzon': {'latitude': 41.0015, 'longitude': 39.7178},
      'tunceli': {'latitude': 39.3074, 'longitude': 39.4388},
      'uşak': {'latitude': 38.6823, 'longitude': 29.4082},
      'usak': {'latitude': 38.6823, 'longitude': 29.4082},
      'van': {'latitude': 38.4891, 'longitude': 43.4089},
      'yalova': {'latitude': 40.6500, 'longitude': 29.2667},
      'yozgat': {'latitude': 39.8181, 'longitude': 34.8147},
      'zonguldak': {'latitude': 41.4564, 'longitude': 31.7987},
    };

    // Try exact match first
    if (cities.containsKey(placeLower)) {
      return cities[placeLower]!;
    }

    // Try to find the city name within the input
    for (final entry in cities.entries) {
      if (placeLower.contains(entry.key)) {
        if (kDebugMode) debugPrint('Found city: ${entry.key} in "$place"');
        return entry.value;
      }
    }

    // Default to Ankara if city not found
    if (kDebugMode) debugPrint('City not found: $place, using Ankara coordinates');
    return cities['ankara']!;
  }
}
