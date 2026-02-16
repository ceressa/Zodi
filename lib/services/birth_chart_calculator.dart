import 'dart:math';

/// Doğum haritası hesaplama servisi
/// Doğum tarihine göre gezegen burçlarını hesaplar.
/// Güneş burcu kesin doğrudur. Diğer gezegenler yaklaşık
/// ephemeris tabanlı periyodik hesaplamayla belirlenir.
class BirthChartCalculator {

  /// Güneş burcu — kesin doğru (tarih aralıkları)
  static String getSunSign(DateTime date) {
    final m = date.month;
    final d = date.day;

    if ((m == 3 && d >= 21) || (m == 4 && d <= 19)) return 'Koç';
    if ((m == 4 && d >= 20) || (m == 5 && d <= 20)) return 'Boğa';
    if ((m == 5 && d >= 21) || (m == 6 && d <= 20)) return 'İkizler';
    if ((m == 6 && d >= 21) || (m == 7 && d <= 22)) return 'Yengeç';
    if ((m == 7 && d >= 23) || (m == 8 && d <= 22)) return 'Aslan';
    if ((m == 8 && d >= 23) || (m == 9 && d <= 22)) return 'Başak';
    if ((m == 9 && d >= 23) || (m == 10 && d <= 22)) return 'Terazi';
    if ((m == 10 && d >= 23) || (m == 11 && d <= 21)) return 'Akrep';
    if ((m == 11 && d >= 22) || (m == 12 && d <= 21)) return 'Yay';
    if ((m == 12 && d >= 22) || (m == 1 && d <= 19)) return 'Oğlak';
    if ((m == 1 && d >= 20) || (m == 2 && d <= 18)) return 'Kova';
    return 'Balık'; // Feb 19 - Mar 20
  }

  /// Ay burcu — yaklaşık (Ay ~27.3 günde bir tur atar)
  /// Julian Day Number kullanarak Ay'ın ekliptik boylamını hesaplar
  static String getMoonSign(DateTime date, {int hour = 12}) {
    // J2000.0 epoch: 1 Jan 2000, 12:00 TT
    final jd = _julianDay(date, hour);
    final daysSinceJ2000 = jd - 2451545.0;

    // Ay'ın ortalama boylam hesabı (basitleştirilmiş)
    // L0 = 218.3165 + 13.176396 * d (derece)
    final meanLong = (218.3165 + 13.176396 * daysSinceJ2000) % 360;
    // Düzeltme: Ay'ın anomalisi
    final meanAnomaly = (134.9634 + 13.0649929 * daysSinceJ2000) % 360;
    final meanAnomalyRad = meanAnomaly * pi / 180;

    // Birinci derece düzeltme (~6.3° genlik)
    final correction = 6.29 * sin(meanAnomalyRad);

    final eclipticLong = (meanLong + correction) % 360;

    return _signFromDegree(eclipticLong < 0 ? eclipticLong + 360 : eclipticLong);
  }

  /// Merkür — Güneş'e yakın, ±28° içinde
  /// Sinodal periyot: ~115.88 gün
  static String getMercurySign(DateTime date) {
    final jd = _julianDay(date, 12);
    final d = jd - 2451545.0;
    // Merkür ortalama boylam
    final L = (252.2509 + 4.0932377 * d) % 360;
    final M = (174.7948 + 4.0923344 * d) % 360;
    final mRad = M * pi / 180;
    final ecliptic = (L + 23.44 * sin(mRad) + 2.9 * sin(2 * mRad)) % 360;
    return _signFromDegree(ecliptic < 0 ? ecliptic + 360 : ecliptic);
  }

  /// Venüs — Güneş'e yakın, ±47° içinde
  /// Sinodal periyot: ~583.9 gün
  static String getVenusSign(DateTime date) {
    final jd = _julianDay(date, 12);
    final d = jd - 2451545.0;
    final L = (181.9798 + 1.6021302 * d) % 360;
    final M = (50.4161 + 1.6021687 * d) % 360;
    final mRad = M * pi / 180;
    final ecliptic = (L + 0.7758 * sin(mRad)) % 360;
    return _signFromDegree(ecliptic < 0 ? ecliptic + 360 : ecliptic);
  }

  /// Mars — sinodal periyot: ~779.9 gün
  static String getMarsSign(DateTime date) {
    final jd = _julianDay(date, 12);
    final d = jd - 2451545.0;
    final L = (355.4330 + 0.5240208 * d) % 360;
    final M = (19.3730 + 0.5240711 * d) % 360;
    final mRad = M * pi / 180;
    final ecliptic = (L + 10.691 * sin(mRad) + 0.623 * sin(2 * mRad)) % 360;
    return _signFromDegree(ecliptic < 0 ? ecliptic + 360 : ecliptic);
  }

  /// Jüpiter — yörünge periyodu: ~11.86 yıl, bir burçta ~1 yıl
  static String getJupiterSign(DateTime date) {
    final jd = _julianDay(date, 12);
    final d = jd - 2451545.0;
    final L = (34.3515 + 0.0830853 * d) % 360;
    final M = (20.0202 + 0.0830853 * d) % 360;
    final mRad = M * pi / 180;
    final ecliptic = (L + 5.555 * sin(mRad) + 0.168 * sin(2 * mRad)) % 360;
    return _signFromDegree(ecliptic < 0 ? ecliptic + 360 : ecliptic);
  }

  /// Satürn — yörünge periyodu: ~29.46 yıl
  static String getSaturnSign(DateTime date) {
    final jd = _julianDay(date, 12);
    final d = jd - 2451545.0;
    final L = (50.0774 + 0.0334442 * d) % 360;
    final M = (317.0207 + 0.0334614 * d) % 360;
    final mRad = M * pi / 180;
    final ecliptic = (L + 6.406 * sin(mRad) + 0.318 * sin(2 * mRad)) % 360;
    return _signFromDegree(ecliptic < 0 ? ecliptic + 360 : ecliptic);
  }

  /// Yükselen burç — doğum saatine ve yaklaşık ekliptik hesabına bağlı
  /// Basitleştirilmiş: doğum saati + güneş burcu offset
  static String getRisingSign(DateTime date, int hour, int minute) {
    final sunSign = getSunSign(date);
    final sunIdx = _signs.indexOf(sunSign);
    // Her 2 saatte bir burç yükselir (24h / 12 = 2h per sign)
    final timeOffset = ((hour + minute / 60.0) / 2.0).floor();
    final risingIdx = (sunIdx + timeOffset) % 12;
    return _signs[risingIdx];
  }

  /// Tüm gezegen konumlarını hesapla
  static BirthChartResult calculate(DateTime date, int hour, int minute) {
    return BirthChartResult(
      sunSign: getSunSign(date),
      moonSign: getMoonSign(date, hour: hour),
      mercurySign: getMercurySign(date),
      venusSign: getVenusSign(date),
      marsSign: getMarsSign(date),
      jupiterSign: getJupiterSign(date),
      saturnSign: getSaturnSign(date),
      risingSign: getRisingSign(date, hour, minute),
      birthDate: date,
      birthHour: hour,
      birthMinute: minute,
    );
  }

  // === Helpers ===

  static const _signs = [
    'Koç', 'Boğa', 'İkizler', 'Yengeç', 'Aslan', 'Başak',
    'Terazi', 'Akrep', 'Yay', 'Oğlak', 'Kova', 'Balık',
  ];

  static const _signSymbols = {
    'Koç': '♈', 'Boğa': '♉', 'İkizler': '♊', 'Yengeç': '♋',
    'Aslan': '♌', 'Başak': '♍', 'Terazi': '♎', 'Akrep': '♏',
    'Yay': '♐', 'Oğlak': '♑', 'Kova': '♒', 'Balık': '♓',
  };

  static String symbolFor(String sign) => _signSymbols[sign] ?? '?';

  static String _signFromDegree(double degree) {
    final idx = (degree / 30).floor() % 12;
    return _signs[idx];
  }

  static double _julianDay(DateTime date, int hour) {
    int y = date.year;
    int m = date.month;
    final d = date.day + hour / 24.0;

    if (m <= 2) {
      y -= 1;
      m += 12;
    }

    final a = (y / 100).floor();
    final b = 2 - a + (a / 4).floor();

    return (365.25 * (y + 4716)).floor() +
        (30.6001 * (m + 1)).floor() +
        d +
        b -
        1524.5;
  }
}

/// Doğum haritası sonuç modeli
class BirthChartResult {
  final String sunSign;
  final String moonSign;
  final String mercurySign;
  final String venusSign;
  final String marsSign;
  final String jupiterSign;
  final String saturnSign;
  final String risingSign;
  final DateTime birthDate;
  final int birthHour;
  final int birthMinute;

  BirthChartResult({
    required this.sunSign,
    required this.moonSign,
    required this.mercurySign,
    required this.venusSign,
    required this.marsSign,
    required this.jupiterSign,
    required this.saturnSign,
    required this.risingSign,
    required this.birthDate,
    required this.birthHour,
    required this.birthMinute,
  });

  /// Gezegen listesi — UI'da kullanmak için
  List<PlanetPosition> get planets => [
    PlanetPosition(name: 'Güneş', sign: sunSign, description: _sunDesc()),
    PlanetPosition(name: 'Ay', sign: moonSign, description: _moonDesc()),
    PlanetPosition(name: 'Yükselen', sign: risingSign, description: _risingDesc()),
    PlanetPosition(name: 'Merkür', sign: mercurySign, description: _mercuryDesc()),
    PlanetPosition(name: 'Venüs', sign: venusSign, description: _venusDesc()),
    PlanetPosition(name: 'Mars', sign: marsSign, description: _marsDesc()),
    PlanetPosition(name: 'Jüpiter', sign: jupiterSign, description: _jupiterDesc()),
    PlanetPosition(name: 'Satürn', sign: saturnSign, description: _saturnDesc()),
  ];

  String get summary => _buildSummary();

  // === Yorum üreticileri ===
  String _sunDesc() => _signPersonality[sunSign] ?? '';
  String _moonDesc() => _moonPersonality[moonSign] ?? '';
  String _risingDesc() => _risingPersonality[risingSign] ?? '';
  String _mercuryDesc() => 'İletişim ve düşünce tarzın ${_signElement(mercurySign)} enerjisi taşıyor.';
  String _venusDesc() => 'Aşk ve estetik anlayışın ${_signElement(venusSign)} elementinden besleniyor.';
  String _marsDesc() => 'Motivasyon ve enerjin ${_signElement(marsSign)} gücüyle şekilleniyor.';
  String _jupiterDesc() => 'Şansın ve genişlemen ${_signElement(jupiterSign)} alanında parlıyor.';
  String _saturnDesc() => 'Disiplin ve sorumluluk ${_signElement(saturnSign)} konularında sınandırıyor.';

  String _buildSummary() {
    return 'Güneşin $sunSign burcunda — ${_sunDesc()} '
        'Ay\'ın $moonSign burcunda olması duygusal dünyanda ${_signElement(moonSign).toLowerCase()} '
        'enerjisini ön plana çıkarıyor. '
        'Yükselen burcun $risingSign ise çevrenin seni nasıl gördüğünü belirliyor: ${_risingDesc()}';
  }

  static String _signElement(String sign) {
    const elements = {
      'Koç': 'Ateş', 'Aslan': 'Ateş', 'Yay': 'Ateş',
      'Boğa': 'Toprak', 'Başak': 'Toprak', 'Oğlak': 'Toprak',
      'İkizler': 'Hava', 'Terazi': 'Hava', 'Kova': 'Hava',
      'Yengeç': 'Su', 'Akrep': 'Su', 'Balık': 'Su',
    };
    return elements[sign] ?? 'Kozmik';
  }

  static const _signPersonality = {
    'Koç': 'Cesur, enerjik ve girişimci bir ruhun var.',
    'Boğa': 'Kararlı, güvenilir ve konfor arayan birisin.',
    'İkizler': 'Meraklı, iletişimci ve çok yönlüsün.',
    'Yengeç': 'Duygusal derinliğin ve empati yeteneğin güçlü.',
    'Aslan': 'Karizmatik, yaratıcı ve liderlik ruhun baskın.',
    'Başak': 'Analitik, detaycı ve pratik çözümler üretirsin.',
    'Terazi': 'Dengeli, diplomatik ve estetik değerlerin güçlü.',
    'Akrep': 'Tutkulu, sezgisel ve derin duyguların var.',
    'Yay': 'Özgürlükçü, iyimser ve felsefi bakışın geniş.',
    'Oğlak': 'Disiplinli, hırslı ve sorumluluk sahibisin.',
    'Kova': 'Yenilikçi, bağımsız ve insancıl düşüncen var.',
    'Balık': 'Hayalperest, empatik ve sanatsal ruhun güçlü.',
  };

  static const _moonPersonality = {
    'Koç': 'Duygusal tepkilerin hızlı ve yoğun. Ani kararlar alabilirsin.',
    'Boğa': 'Duygusal güvenlik ve konfor ararsın. Sabırlı bir iç dünyan var.',
    'İkizler': 'Duyguların çabuk değişir. Zihinsel uyarılmaya ihtiyaç duyarsın.',
    'Yengeç': 'Çok derin hissedersin. Aile ve yuva bağların güçlü.',
    'Aslan': 'Duygusal olarak cömert ve sıcakkanlısın. Takdir görmek istersin.',
    'Başak': 'Duygularını analiz etme eğilimindesin. Düzen seni rahatlatır.',
    'Terazi': 'Uyum ve denge ararsın. İlişkilerde huzur senin için öncelik.',
    'Akrep': 'Duyguların derin ve yoğun. Güven meselelerinde hassassın.',
    'Yay': 'Duygusal özgürlüğe ihtiyaç duyarsın. İyimser bir iç dünyan var.',
    'Oğlak': 'Duygularını kontrol altında tutarsın. Sorumluluk duygun güçlü.',
    'Kova': 'Duygusal mesafen olabilir. Bağımsızlık seni rahatlatır.',
    'Balık': 'Çok empatiksin. Sanatsal ve spiritüel yönün belirgin.',
  };

  static const _risingPersonality = {
    'Koç': 'Enerjik ve kararlı bir ilk izlenim bırakırsın.',
    'Boğa': 'Sakin, güvenilir ve sağlam bir dış görünüşün var.',
    'İkizler': 'Konuşkan, meraklı ve çevik bir izlenim verirsin.',
    'Yengeç': 'Sıcak, koruyucu ve duygusal bir aura yayarsın.',
    'Aslan': 'Karizmatik ve dikkat çekici bir varlığın var.',
    'Başak': 'Düzenli, temiz ve zeki bir izlenim bırakırsın.',
    'Terazi': 'Zarif, diplomatik ve çekici görünürsün.',
    'Akrep': 'Gizemli, yoğun ve etkileyici bir auran var.',
    'Yay': 'Neşeli, açık ve maceracı bir ilk izlenim verirsin.',
    'Oğlak': 'Ciddi, olgun ve güvenilir bir dış görünüşün var.',
    'Kova': 'Farklı, orijinal ve ilgi çekici görünürsün.',
    'Balık': 'Yumuşak, hayalperest ve empatik bir auran var.',
  };
}

class PlanetPosition {
  final String name;
  final String sign;
  final String description;

  PlanetPosition({
    required this.name,
    required this.sign,
    required this.description,
  });

  String get symbol => BirthChartCalculator.symbolFor(sign);
  String get display => '$symbol $sign';
}
