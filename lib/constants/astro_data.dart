import '../models/astro_event.dart';

/// 2025-2027 arası bilinen astrolojik olaylar
class AstroData {
  static final List<AstroEvent> events = [
    // ==================== 2025 ====================

    // Merkür Retroları 2025
    AstroEvent(
      date: DateTime(2025, 3, 15),
      endDate: DateTime(2025, 4, 7),
      title: 'Merkür Retrosu',
      description: 'Koç burcunda Merkür retrosu. İletişim ve seyahat konularında dikkatli ol.',
      type: AstroEventType.mercuryRetrograde,
      affectedSign: 'Koç',
      emoji: '☿️',
    ),
    AstroEvent(
      date: DateTime(2025, 7, 18),
      endDate: DateTime(2025, 8, 11),
      title: 'Merkür Retrosu',
      description: 'Aslan burcunda Merkür retrosu. Yaratıcı projeler gecikebilir.',
      type: AstroEventType.mercuryRetrograde,
      affectedSign: 'Aslan',
      emoji: '☿️',
    ),
    AstroEvent(
      date: DateTime(2025, 11, 9),
      endDate: DateTime(2025, 11, 29),
      title: 'Merkür Retrosu',
      description: 'Yay burcunda Merkür retrosu. Eğitim ve seyahat planları değişebilir.',
      type: AstroEventType.mercuryRetrograde,
      affectedSign: 'Yay',
      emoji: '☿️',
    ),

    // Venüs Retrosu 2025
    AstroEvent(
      date: DateTime(2025, 3, 2),
      endDate: DateTime(2025, 4, 13),
      title: 'Venüs Retrosu',
      description: 'Koç burcunda Venüs retrosu. Eski aşklar geri dönebilir, ilişkilerde gözden geçirme zamanı.',
      type: AstroEventType.venusRetrograde,
      affectedSign: 'Koç',
      emoji: '♀️',
    ),

    // Mars Retrosu 2025 (2024'ten devam)
    AstroEvent(
      date: DateTime(2025, 1, 6),
      endDate: DateTime(2025, 2, 24),
      title: 'Mars Retrosu',
      description: 'İkizler-Yengeç burcunda Mars retrosu. Enerji düşük, büyük kararlar ertelensin.',
      type: AstroEventType.marsRetrograde,
      affectedSign: 'İkizler',
      emoji: '♂️',
    ),

    // Tutulmalar 2025
    AstroEvent(
      date: DateTime(2025, 3, 14),
      title: 'Ay Tutulması',
      description: 'Başak burcunda tam Ay tutulması. Sağlık ve rutinlerle ilgili dönüm noktası.',
      type: AstroEventType.lunarEclipse,
      affectedSign: 'Başak',
      emoji: '🌑',
    ),
    AstroEvent(
      date: DateTime(2025, 3, 29),
      title: 'Güneş Tutulması',
      description: 'Koç burcunda kısmi Güneş tutulması. Yeni başlangıçlar için güçlü enerji.',
      type: AstroEventType.solarEclipse,
      affectedSign: 'Koç',
      emoji: '🌘',
    ),
    AstroEvent(
      date: DateTime(2025, 9, 7),
      title: 'Ay Tutulması',
      description: 'Balık burcunda tam Ay tutulması. Duygusal arınma ve ruhsal uyanış.',
      type: AstroEventType.lunarEclipse,
      affectedSign: 'Balık',
      emoji: '🌑',
    ),
    AstroEvent(
      date: DateTime(2025, 9, 21),
      title: 'Güneş Tutulması',
      description: 'Başak burcunda kısmi Güneş tutulması. İş ve sağlık odaklı yeni dönem.',
      type: AstroEventType.solarEclipse,
      affectedSign: 'Başak',
      emoji: '🌘',
    ),

    // Dolunaylar 2025
    AstroEvent(date: DateTime(2025, 1, 13), title: 'Dolunay', description: 'Yengeç burcunda Dolunay. Duygusal yoğunluk, aile konuları öne çıkar.', type: AstroEventType.fullMoon, affectedSign: 'Yengeç', emoji: '🌕'),
    AstroEvent(date: DateTime(2025, 2, 12), title: 'Dolunay', description: 'Aslan burcunda Dolunay. Yaratıcılık ve aşk ön planda.', type: AstroEventType.fullMoon, affectedSign: 'Aslan', emoji: '🌕'),
    AstroEvent(date: DateTime(2025, 4, 13), title: 'Dolunay', description: 'Terazi burcunda Dolunay. İlişkilerde denge arayışı.', type: AstroEventType.fullMoon, affectedSign: 'Terazi', emoji: '🌕'),
    AstroEvent(date: DateTime(2025, 5, 12), title: 'Dolunay', description: 'Akrep burcunda Dolunay. Derin duygusal dönüşüm.', type: AstroEventType.fullMoon, affectedSign: 'Akrep', emoji: '🌕'),
    AstroEvent(date: DateTime(2025, 6, 11), title: 'Dolunay', description: 'Yay burcunda Dolunay. Macera ve özgürlük teması.', type: AstroEventType.fullMoon, affectedSign: 'Yay', emoji: '🌕'),
    AstroEvent(date: DateTime(2025, 7, 10), title: 'Dolunay', description: 'Oğlak burcunda Dolunay. Kariyer hedefleri netleşir.', type: AstroEventType.fullMoon, affectedSign: 'Oğlak', emoji: '🌕'),
    AstroEvent(date: DateTime(2025, 8, 9), title: 'Dolunay', description: 'Kova burcunda Dolunay. Sosyal çevre ve dostluk öne çıkar.', type: AstroEventType.fullMoon, affectedSign: 'Kova', emoji: '🌕'),
    AstroEvent(date: DateTime(2025, 10, 7), title: 'Dolunay', description: 'Koç burcunda Dolunay. Bireysellik ve cesaret teması.', type: AstroEventType.fullMoon, affectedSign: 'Koç', emoji: '🌕'),
    AstroEvent(date: DateTime(2025, 11, 5), title: 'Dolunay', description: 'Boğa burcunda Dolunay. Maddi konular ve güvenlik.', type: AstroEventType.fullMoon, affectedSign: 'Boğa', emoji: '🌕'),
    AstroEvent(date: DateTime(2025, 12, 4), title: 'Dolunay', description: 'İkizler burcunda Dolunay. İletişim ve öğrenme ön planda.', type: AstroEventType.fullMoon, affectedSign: 'İkizler', emoji: '🌕'),

    // Yeniaylar 2025
    AstroEvent(date: DateTime(2025, 1, 29), title: 'Yeniay', description: 'Kova burcunda Yeniay. Yeni sosyal bağlantılar için ideal.', type: AstroEventType.newMoon, affectedSign: 'Kova', emoji: '🌑'),
    AstroEvent(date: DateTime(2025, 2, 28), title: 'Yeniay', description: 'Balık burcunda Yeniay. Ruhsal derinleşme zamanı.', type: AstroEventType.newMoon, affectedSign: 'Balık', emoji: '🌑'),
    AstroEvent(date: DateTime(2025, 4, 27), title: 'Yeniay', description: 'Boğa burcunda Yeniay. Maddi hedefler için yeni başlangıç.', type: AstroEventType.newMoon, affectedSign: 'Boğa', emoji: '🌑'),
    AstroEvent(date: DateTime(2025, 5, 27), title: 'Yeniay', description: 'İkizler burcunda Yeniay. İletişim projeleri başlat.', type: AstroEventType.newMoon, affectedSign: 'İkizler', emoji: '🌑'),
    AstroEvent(date: DateTime(2025, 6, 25), title: 'Yeniay', description: 'Yengeç burcunda Yeniay. Ev ve aile odaklı yeni dönem.', type: AstroEventType.newMoon, affectedSign: 'Yengeç', emoji: '🌑'),
    AstroEvent(date: DateTime(2025, 7, 24), title: 'Yeniay', description: 'Aslan burcunda Yeniay. Yaratıcılık ve cesaret!', type: AstroEventType.newMoon, affectedSign: 'Aslan', emoji: '🌑'),
    AstroEvent(date: DateTime(2025, 8, 23), title: 'Yeniay', description: 'Başak burcunda Yeniay. Düzen ve sağlık rutinleri başlat.', type: AstroEventType.newMoon, affectedSign: 'Başak', emoji: '🌑'),
    AstroEvent(date: DateTime(2025, 10, 21), title: 'Yeniay', description: 'Terazi burcunda Yeniay. İlişkilerde yeni sayfa aç.', type: AstroEventType.newMoon, affectedSign: 'Terazi', emoji: '🌑'),
    AstroEvent(date: DateTime(2025, 11, 20), title: 'Yeniay', description: 'Akrep burcunda Yeniay. Derin dönüşüm başlangıcı.', type: AstroEventType.newMoon, affectedSign: 'Akrep', emoji: '🌑'),
    AstroEvent(date: DateTime(2025, 12, 20), title: 'Yeniay', description: 'Yay burcunda Yeniay. Macera ve keşif zamanı!', type: AstroEventType.newMoon, affectedSign: 'Yay', emoji: '🌑'),

    // Burç Mevsim Geçişleri 2025
    AstroEvent(date: DateTime(2025, 1, 20), title: 'Kova Mevsimi', description: 'Güneş Kova burcuna giriyor. Yenilikçi ve sosyal bir dönem başlıyor.', type: AstroEventType.zodiacSeasonChange, affectedSign: 'Kova', emoji: '♒'),
    AstroEvent(date: DateTime(2025, 2, 19), title: 'Balık Mevsimi', description: 'Güneş Balık burcuna giriyor. Duygusal ve ruhani bir dönem.', type: AstroEventType.zodiacSeasonChange, affectedSign: 'Balık', emoji: '♓'),
    AstroEvent(date: DateTime(2025, 3, 20), title: 'Koç Mevsimi', description: 'İlkbahar ekinoksu! Güneş Koç burcuna giriyor. Yeni başlangıçlar zamanı.', type: AstroEventType.zodiacSeasonChange, affectedSign: 'Koç', emoji: '♈'),
    AstroEvent(date: DateTime(2025, 4, 20), title: 'Boğa Mevsimi', description: 'Güneş Boğa burcuna giriyor. Sabır ve kararlılık dönemi.', type: AstroEventType.zodiacSeasonChange, affectedSign: 'Boğa', emoji: '♉'),
    AstroEvent(date: DateTime(2025, 5, 21), title: 'İkizler Mevsimi', description: 'Güneş İkizler burcuna giriyor. İletişim ve merak dönemi.', type: AstroEventType.zodiacSeasonChange, affectedSign: 'İkizler', emoji: '♊'),
    AstroEvent(date: DateTime(2025, 6, 21), title: 'Yengeç Mevsimi', description: 'Yaz gündönümü! Güneş Yengeç burcuna giriyor. Aile ve yuva odaklı dönem.', type: AstroEventType.zodiacSeasonChange, affectedSign: 'Yengeç', emoji: '♋'),
    AstroEvent(date: DateTime(2025, 7, 22), title: 'Aslan Mevsimi', description: 'Güneş Aslan burcuna giriyor. Parıldama ve kendini ifade zamanı!', type: AstroEventType.zodiacSeasonChange, affectedSign: 'Aslan', emoji: '♌'),
    AstroEvent(date: DateTime(2025, 8, 23), title: 'Başak Mevsimi', description: 'Güneş Başak burcuna giriyor. Düzen ve detaylara odaklanma dönemi.', type: AstroEventType.zodiacSeasonChange, affectedSign: 'Başak', emoji: '♍'),
    AstroEvent(date: DateTime(2025, 9, 22), title: 'Terazi Mevsimi', description: 'Sonbahar ekinoksu! Güneş Terazi burcuna giriyor. Denge ve ilişkiler ön planda.', type: AstroEventType.zodiacSeasonChange, affectedSign: 'Terazi', emoji: '♎'),
    AstroEvent(date: DateTime(2025, 10, 23), title: 'Akrep Mevsimi', description: 'Güneş Akrep burcuna giriyor. Derinlik ve dönüşüm zamanı.', type: AstroEventType.zodiacSeasonChange, affectedSign: 'Akrep', emoji: '♏'),
    AstroEvent(date: DateTime(2025, 11, 22), title: 'Yay Mevsimi', description: 'Güneş Yay burcuna giriyor. Macera ve genişleme dönemi!', type: AstroEventType.zodiacSeasonChange, affectedSign: 'Yay', emoji: '♐'),
    AstroEvent(date: DateTime(2025, 12, 21), title: 'Oğlak Mevsimi', description: 'Kış gündönümü! Güneş Oğlak burcuna giriyor. Hedef ve disiplin dönemi.', type: AstroEventType.zodiacSeasonChange, affectedSign: 'Oğlak', emoji: '♑'),

    // ==================== 2026 ====================

    // Merkür Retroları 2026
    AstroEvent(
      date: DateTime(2026, 2, 26),
      endDate: DateTime(2026, 3, 20),
      title: 'Merkür Retrosu',
      description: 'Balık burcunda Merkür retrosu. Sezgiler güçlü ama kararlar belirsiz.',
      type: AstroEventType.mercuryRetrograde,
      affectedSign: 'Balık',
      emoji: '☿️',
    ),
    AstroEvent(
      date: DateTime(2026, 6, 29),
      endDate: DateTime(2026, 7, 23),
      title: 'Merkür Retrosu',
      description: 'Yengeç burcunda Merkür retrosu. Aile iletişiminde dikkatli ol.',
      type: AstroEventType.mercuryRetrograde,
      affectedSign: 'Yengeç',
      emoji: '☿️',
    ),
    AstroEvent(
      date: DateTime(2026, 10, 24),
      endDate: DateTime(2026, 11, 13),
      title: 'Merkür Retrosu',
      description: 'Akrep burcunda Merkür retrosu. Derin sırlar ve gizli bilgiler yüzeye çıkabilir.',
      type: AstroEventType.mercuryRetrograde,
      affectedSign: 'Akrep',
      emoji: '☿️',
    ),

    // Venüs Retrosu 2026
    AstroEvent(
      date: DateTime(2026, 12, 16),
      endDate: DateTime(2027, 1, 27),
      title: 'Venüs Retrosu',
      description: 'Oğlak burcunda Venüs retrosu. İlişkilerde ve mali konularda geçmişe dönüş. Eski bağlar yeniden değerlendirilir.',
      type: AstroEventType.venusRetrograde,
      affectedSign: 'Oğlak',
      emoji: '♀️',
    ),

    // Mars Retrosu 2026
    AstroEvent(
      date: DateTime(2026, 10, 30),
      endDate: DateTime(2027, 1, 12),
      title: 'Mars Retrosu',
      description: 'Aslan burcunda Mars retrosu. Enerji ve motivasyon düşebilir, büyük projeleri ertelemek akıllıca olabilir.',
      type: AstroEventType.marsRetrograde,
      affectedSign: 'Aslan',
      emoji: '♂️',
    ),

    // Jüpiter Retrosu 2026
    AstroEvent(
      date: DateTime(2026, 7, 14),
      endDate: DateTime(2026, 11, 10),
      title: 'Jüpiter Retrosu',
      description: 'Yengeç burcunda Jüpiter retrosu. İçsel büyüme ve duygusal iyileşme dönemi. Şans dışarıdan değil içeriden gelir.',
      type: AstroEventType.jupiterRetrograde,
      affectedSign: 'Yengeç',
      emoji: '♃',
    ),

    // Satürn Retrosu 2026
    AstroEvent(
      date: DateTime(2026, 6, 1),
      endDate: DateTime(2026, 10, 18),
      title: 'Satürn Retrosu',
      description: 'Koç burcunda Satürn retrosu. Sorumluluklar ve sınırlar yeniden sorgulanır. Sabırla yapısal değişimler için ideal.',
      type: AstroEventType.saturnRetrograde,
      affectedSign: 'Koç',
      emoji: '♄',
    ),

    // Tutulmalar 2026
    AstroEvent(
      date: DateTime(2026, 2, 17),
      title: 'Güneş Tutulması',
      description: 'Kova burcunda halka şeklinde Güneş tutulması. Toplumsal değişim rüzgarları.',
      type: AstroEventType.solarEclipse,
      affectedSign: 'Kova',
      emoji: '🌘',
    ),
    AstroEvent(
      date: DateTime(2026, 3, 3),
      title: 'Ay Tutulması',
      description: 'Başak burcunda tam Ay tutulması. Sağlık ve rutinlerde büyük değişim.',
      type: AstroEventType.lunarEclipse,
      affectedSign: 'Başak',
      emoji: '🌑',
    ),
    AstroEvent(
      date: DateTime(2026, 8, 12),
      title: 'Güneş Tutulması',
      description: 'Aslan burcunda tam Güneş tutulması. Güçlü bir yeni başlangıç enerjisi.',
      type: AstroEventType.solarEclipse,
      affectedSign: 'Aslan',
      emoji: '🌘',
    ),
    AstroEvent(
      date: DateTime(2026, 8, 28),
      title: 'Ay Tutulması',
      description: 'Balık burcunda kısmi Ay tutulması. Duygusal arınma.',
      type: AstroEventType.lunarEclipse,
      affectedSign: 'Balık',
      emoji: '🌑',
    ),

    // Dolunaylar 2026
    AstroEvent(date: DateTime(2026, 1, 3), title: 'Dolunay', description: 'Yengeç burcunda Dolunay. Duygusal yoğunluk, aile bağları güçlenir.', type: AstroEventType.fullMoon, affectedSign: 'Yengeç', emoji: '🌕'),
    AstroEvent(date: DateTime(2026, 2, 1), title: 'Dolunay', description: 'Aslan burcunda Dolunay. Yaratıcılık ve kendini ifade ön planda.', type: AstroEventType.fullMoon, affectedSign: 'Aslan', emoji: '🌕'),
    AstroEvent(date: DateTime(2026, 3, 3), title: 'Dolunay', description: 'Başak burcunda Dolunay (Ay Tutulması). Sağlık ve düzen konularında dönüm noktası.', type: AstroEventType.fullMoon, affectedSign: 'Başak', emoji: '🌕'),
    AstroEvent(date: DateTime(2026, 4, 2), title: 'Dolunay', description: 'Terazi burcunda Dolunay. İlişkilerde denge ve uyum arayışı.', type: AstroEventType.fullMoon, affectedSign: 'Terazi', emoji: '🌕'),
    AstroEvent(date: DateTime(2026, 5, 1), title: 'Dolunay', description: 'Akrep burcunda Dolunay. Derin duygusal dönüşüm ve arınma.', type: AstroEventType.fullMoon, affectedSign: 'Akrep', emoji: '🌕'),
    AstroEvent(date: DateTime(2026, 5, 31), title: 'Dolunay', description: 'Yay burcunda Dolunay. Macera ruhu ve genişleme isteği yükselir.', type: AstroEventType.fullMoon, affectedSign: 'Yay', emoji: '🌕'),
    AstroEvent(date: DateTime(2026, 6, 29), title: 'Dolunay', description: 'Oğlak burcunda Dolunay. Kariyer hedefleri netleşir, sorumluluklar belirginleşir.', type: AstroEventType.fullMoon, affectedSign: 'Oğlak', emoji: '🌕'),
    AstroEvent(date: DateTime(2026, 7, 29), title: 'Dolunay', description: 'Kova burcunda Dolunay. Sosyal çevre ve toplumsal bilinç öne çıkar.', type: AstroEventType.fullMoon, affectedSign: 'Kova', emoji: '🌕'),
    AstroEvent(date: DateTime(2026, 8, 28), title: 'Dolunay', description: 'Balık burcunda Dolunay (Ay Tutulması). Ruhsal uyanış ve sezgisel derinleşme.', type: AstroEventType.fullMoon, affectedSign: 'Balık', emoji: '🌕'),
    AstroEvent(date: DateTime(2026, 9, 26), title: 'Dolunay', description: 'Koç burcunda Dolunay. Bireysel cesaret ve yeni atılımlar.', type: AstroEventType.fullMoon, affectedSign: 'Koç', emoji: '🌕'),
    AstroEvent(date: DateTime(2026, 10, 26), title: 'Dolunay', description: 'Boğa burcunda Dolunay. Maddi güvenlik ve değerler sorgulanır.', type: AstroEventType.fullMoon, affectedSign: 'Boğa', emoji: '🌕'),
    AstroEvent(date: DateTime(2026, 11, 24), title: 'Dolunay', description: 'İkizler burcunda Dolunay. İletişim ve öğrenme zirve yapar.', type: AstroEventType.fullMoon, affectedSign: 'İkizler', emoji: '🌕'),
    AstroEvent(date: DateTime(2026, 12, 24), title: 'Dolunay', description: 'Yengeç burcunda Dolunay. Yılın kapanışında aile sıcaklığı ve duygusal derinlik.', type: AstroEventType.fullMoon, affectedSign: 'Yengeç', emoji: '🌕'),

    // Yeniaylar 2026
    AstroEvent(date: DateTime(2026, 1, 18), title: 'Yeniay', description: 'Oğlak burcunda Yeniay. Kariyer ve uzun vadeli hedefler için yeni başlangıç.', type: AstroEventType.newMoon, affectedSign: 'Oğlak', emoji: '🌑'),
    AstroEvent(date: DateTime(2026, 2, 17), title: 'Yeniay', description: 'Kova burcunda Yeniay (Güneş Tutulması). Toplumsal bilinçte güçlü yeni başlangıçlar.', type: AstroEventType.newMoon, affectedSign: 'Kova', emoji: '🌑'),
    AstroEvent(date: DateTime(2026, 3, 19), title: 'Yeniay', description: 'Balık burcunda Yeniay. Ruhsal derinleşme ve sezgisel yenilenme zamanı.', type: AstroEventType.newMoon, affectedSign: 'Balık', emoji: '🌑'),
    AstroEvent(date: DateTime(2026, 4, 17), title: 'Yeniay', description: 'Koç burcunda Yeniay. Cesaret ve girişimcilik enerjisi yüksek.', type: AstroEventType.newMoon, affectedSign: 'Koç', emoji: '🌑'),
    AstroEvent(date: DateTime(2026, 5, 16), title: 'Yeniay', description: 'Boğa burcunda Yeniay. Maddi hedefler ve konfor arayışı için yeni sayfa.', type: AstroEventType.newMoon, affectedSign: 'Boğa', emoji: '🌑'),
    AstroEvent(date: DateTime(2026, 6, 15), title: 'Yeniay', description: 'İkizler burcunda Yeniay. İletişim projeleri ve yeni fikirler filizlenir.', type: AstroEventType.newMoon, affectedSign: 'İkizler', emoji: '🌑'),
    AstroEvent(date: DateTime(2026, 7, 14), title: 'Yeniay', description: 'Yengeç burcunda Yeniay. Ev, aile ve duygusal güvenlik odaklı yeni dönem.', type: AstroEventType.newMoon, affectedSign: 'Yengeç', emoji: '🌑'),
    AstroEvent(date: DateTime(2026, 8, 12), title: 'Yeniay', description: 'Aslan burcunda Yeniay (Güneş Tutulması). Güçlü yaratıcı enerji ve cesaret dolu başlangıçlar.', type: AstroEventType.newMoon, affectedSign: 'Aslan', emoji: '🌑'),
    AstroEvent(date: DateTime(2026, 9, 11), title: 'Yeniay', description: 'Başak burcunda Yeniay. Düzen, sağlık ve verimlilik için yeni alışkanlıklar başlat.', type: AstroEventType.newMoon, affectedSign: 'Başak', emoji: '🌑'),
    AstroEvent(date: DateTime(2026, 10, 10), title: 'Yeniay', description: 'Terazi burcunda Yeniay. İlişkilerde yeni bir sayfa açma zamanı.', type: AstroEventType.newMoon, affectedSign: 'Terazi', emoji: '🌑'),
    AstroEvent(date: DateTime(2026, 11, 9), title: 'Yeniay', description: 'Akrep burcunda Yeniay. Derin dönüşüm ve yeniden doğuş enerjisi.', type: AstroEventType.newMoon, affectedSign: 'Akrep', emoji: '🌑'),
    AstroEvent(date: DateTime(2026, 12, 9), title: 'Yeniay', description: 'Yay burcunda Yeniay. Macera ve keşif ruhu canlanır, ufuklar genişler.', type: AstroEventType.newMoon, affectedSign: 'Yay', emoji: '🌑'),

    // Burç Mevsim Geçişleri 2026
    AstroEvent(date: DateTime(2026, 1, 20), title: 'Kova Mevsimi', description: 'Güneş Kova burcuna giriyor. Yenilikçi fikirler ve sosyal bağlantılar ön planda.', type: AstroEventType.zodiacSeasonChange, affectedSign: 'Kova', emoji: '♒'),
    AstroEvent(date: DateTime(2026, 2, 19), title: 'Balık Mevsimi', description: 'Güneş Balık burcuna giriyor. Hayal gücü ve ruhani derinlik zamanı.', type: AstroEventType.zodiacSeasonChange, affectedSign: 'Balık', emoji: '♓'),
    AstroEvent(date: DateTime(2026, 3, 20), title: 'Koç Mevsimi', description: 'İlkbahar ekinoksu! Güneş Koç burcuna giriyor. Yeni başlangıçlar ve enerji patlaması.', type: AstroEventType.zodiacSeasonChange, affectedSign: 'Koç', emoji: '♈'),
    AstroEvent(date: DateTime(2026, 4, 20), title: 'Boğa Mevsimi', description: 'Güneş Boğa burcuna giriyor. Sabır, kararlılık ve maddi konular ön planda.', type: AstroEventType.zodiacSeasonChange, affectedSign: 'Boğa', emoji: '♉'),
    AstroEvent(date: DateTime(2026, 5, 21), title: 'İkizler Mevsimi', description: 'Güneş İkizler burcuna giriyor. İletişim, merak ve sosyal hareketlilik dönemi.', type: AstroEventType.zodiacSeasonChange, affectedSign: 'İkizler', emoji: '♊'),
    AstroEvent(date: DateTime(2026, 6, 21), title: 'Yengeç Mevsimi', description: 'Yaz gündönümü! Güneş Yengeç burcuna giriyor. Aile, yuva ve duygusal bağlar güçlenir.', type: AstroEventType.zodiacSeasonChange, affectedSign: 'Yengeç', emoji: '♋'),
    AstroEvent(date: DateTime(2026, 7, 22), title: 'Aslan Mevsimi', description: 'Güneş Aslan burcuna giriyor. Parıldama, liderlik ve kendini ifade zamanı!', type: AstroEventType.zodiacSeasonChange, affectedSign: 'Aslan', emoji: '♌'),
    AstroEvent(date: DateTime(2026, 8, 23), title: 'Başak Mevsimi', description: 'Güneş Başak burcuna giriyor. Düzen, detay ve verimlilik odaklı dönem.', type: AstroEventType.zodiacSeasonChange, affectedSign: 'Başak', emoji: '♍'),
    AstroEvent(date: DateTime(2026, 9, 22), title: 'Terazi Mevsimi', description: 'Sonbahar ekinoksu! Güneş Terazi burcuna giriyor. Denge, estetik ve ilişkiler ön planda.', type: AstroEventType.zodiacSeasonChange, affectedSign: 'Terazi', emoji: '♎'),
    AstroEvent(date: DateTime(2026, 10, 23), title: 'Akrep Mevsimi', description: 'Güneş Akrep burcuna giriyor. Derinlik, dönüşüm ve gizemli enerjiler.', type: AstroEventType.zodiacSeasonChange, affectedSign: 'Akrep', emoji: '♏'),
    AstroEvent(date: DateTime(2026, 11, 22), title: 'Yay Mevsimi', description: 'Güneş Yay burcuna giriyor. Macera, keşif ve genişleme enerjisi yükselir!', type: AstroEventType.zodiacSeasonChange, affectedSign: 'Yay', emoji: '♐'),
    AstroEvent(date: DateTime(2026, 12, 21), title: 'Oğlak Mevsimi', description: 'Kış gündönümü! Güneş Oğlak burcuna giriyor. Hedef belirleme ve disiplin dönemi.', type: AstroEventType.zodiacSeasonChange, affectedSign: 'Oğlak', emoji: '♑'),
  ];

  /// Tüm astrolojik olayları getir
  static List<AstroEvent> getAllEvents() => events;

  /// Belirli bir ay için olayları getir
  static List<AstroEvent> getEventsForMonth(int year, int month) {
    return events.where((e) {
      // Tek günlük olaylar
      if (e.endDate == null) {
        return e.date.year == year && e.date.month == month;
      }
      // Dönemsel olaylar (retro gibi)
      final monthStart = DateTime(year, month, 1);
      final monthEnd = DateTime(year, month + 1, 0);
      return !(e.endDate!.isBefore(monthStart) || e.date.isAfter(monthEnd));
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  /// Belirli bir gün için olayları getir
  static List<AstroEvent> getEventsForDay(DateTime date) {
    return events.where((e) => e.isActiveOn(date)).toList();
  }
}
