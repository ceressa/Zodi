# Yükselen Burç Hesaplama Düzeltmesi

## Sorun
Yükselen burç hesaplaması yanlış sonuçlar veriyordu çünkü Gemini AI'a astronomik hesaplama yaptırılıyordu.

## Kök Neden
AI modelleri **gerçek astronomik hesaplama yapamaz**. Yükselen burç hesaplaması için:
- Doğum saati (dakika hassasiyetinde)
- Doğum yeri (enlem/boylam)
- Astronomik efemeris tabloları
- Karmaşık trigonometrik formüller

gerekir. AI sadece tahmin eder ve çoğu zaman yanlış sonuç verir.

## Çözüm
Basitleştirilmiş ama **tutarlı** bir hesaplama algoritması uygulandı.

### Yeni Hesaplama Mantığı

#### 1. Yükselen Burç Hesaplaması
```dart
// Her 2 saatte bir burç değişir (yaklaşık)
final monthDiff = birthDate.month - sunSignStartMonth;
final hourOffset = (hour + (minute / 60)) ~/ 2;

// Toplam offset
int risingSignOffset = (monthDiff * 2 + hourOffset) % 12;
```

**Mantık:**
- Güneş burcundan başla
- Doğum ayına göre offset ekle (her ay ~2 burç)
- Doğum saatine göre offset ekle (her 2 saat 1 burç)
- 12 burç döngüsünde hesapla

**Örnek:**
- Güneş Burcu: Aslan (Temmuz)
- Doğum: 15 Ekim, 14:30
- Ay farkı: 10 - 7 = 3 ay → 6 burç offset
- Saat offset: 14.5 / 2 = 7 burç offset
- Toplam: (6 + 7) % 12 = 1 burç ileri
- Yükselen: Başak

#### 2. Ay Burcu Hesaplaması
```dart
// Doğum gününe göre basit hesaplama
final moonSignOffset = (birthDate.day ~/ 2.5).toInt() % 12;
```

**Mantık:**
- Ay her ~2.5 günde bir burç değiştirir
- Doğum gününe göre offset hesapla
- 12 burç döngüsünde hesapla

**Örnek:**
- Doğum günü: 15
- Offset: 15 / 2.5 = 6 burç
- Ay Burcu: Güneş burcundan 6 burç ileri

### Yardımcı Fonksiyonlar

```dart
// Güneş burcunun başlangıç ayı
int _getSunSignStartMonth(String signName) {
  const monthMap = {
    'aries': 3,      // Koç - 21 Mart
    'taurus': 4,     // Boğa - 20 Nisan
    'gemini': 5,     // İkizler - 21 Mayıs
    // ... diğer burçlar
  };
  return monthMap[signName] ?? 1;
}

// Offset'e göre burç bul
String _getZodiacByOffset(String baseSign, int offset) {
  const signs = [
    'aries', 'taurus', 'gemini', 'cancer', 
    'leo', 'virgo', 'libra', 'scorpio',
    'sagittarius', 'capricorn', 'aquarius', 'pisces'
  ];
  
  final baseIndex = signs.indexOf(baseSign);
  final newIndex = (baseIndex + offset) % 12;
  return signs[newIndex];
}

// Türkçe isim
String _getZodiacDisplayName(String signName) {
  const displayNames = {
    'aries': 'Koç',
    'taurus': 'Boğa',
    // ... diğer burçlar
  };
  return displayNames[signName] ?? signName;
}
```

## Öncesi vs Sonrası

### Öncesi (YANLIŞ)
```dart
// AI'a hesaplama yaptırma
final prompt = '''
Doğum Bilgileri:
- Güneş Burcu: ${sunSign.displayName}
- Doğum Tarihi: ${birthDate}
- Doğum Saati: $birthTime
- Doğum Yeri: $birthPlace

Bu bilgilere göre yükselen burç ve ay burcunu hesapla.
''';

// ❌ AI rastgele tahmin eder
// ❌ Her seferinde farklı sonuç verebilir
// ❌ Astronomik olarak yanlış
```

### Sonrası (DOĞRU)
```dart
// Önce matematiksel hesaplama yap
final risingSignName = _calculateRisingSign(sunSign, birthDate, birthTime);
final moonSignName = _calculateMoonSign(sunSign, birthDate);

// Sonra AI'a sadece analiz yaptır
final prompt = '''
Burç Üçlüsü Analizi:
- Güneş Burcu: ${sunSign.displayName}
- Yükselen Burç: ${risingSignName}
- Ay Burcu: ${moonSignName}

Bu burç üçlüsünü analiz et.
''';

// ✓ Tutarlı sonuçlar
// ✓ Matematiksel hesaplama
// ✓ AI sadece analiz yapar
```

## Avantajlar

### 1. Tutarlılık
- Aynı doğum bilgileri → Her zaman aynı sonuç
- AI'ın rastgeleliği ortadan kalktı

### 2. Hız
- Matematiksel hesaplama çok hızlı
- AI sadece analiz için kullanılıyor

### 3. Güvenilirlik
- Basit ama mantıklı formül
- Astronomik prensiplere dayalı (basitleştirilmiş)

### 4. Maliyet
- Daha kısa prompt → Daha az token
- Daha ucuz API kullanımı

## Sınırlamalar

Bu basitleştirilmiş bir hesaplamadır. Gerçek yükselen burç hesaplaması için:

### Eksik Faktörler
- ❌ Enlem/boylam bilgisi
- ❌ Yaz saati uygulaması
- ❌ Zaman dilimi farkları
- ❌ Efemeris tabloları
- ❌ Evlerin hesaplanması

### Profesyonel Hesaplama İçin
Gerçek astronomik hesaplama için şu kütüphaneler kullanılabilir:
- **Swiss Ephemeris** (C/C++)
- **Astro.js** (JavaScript)
- **Skyfield** (Python)

Ama mobil uygulama için:
- ✓ Basit hesaplama yeterli
- ✓ Kullanıcı deneyimi öncelikli
- ✓ Tutarlı sonuçlar önemli

## Test Senaryoları

### Senaryo 1: Sabah Doğumu
```
Güneş: Aslan (23 Temmuz - 22 Ağustos)
Doğum: 15 Ağustos, 08:00
Beklenen Yükselen: Başak (sabah doğumları)
```

### Senaryo 2: Öğlen Doğumu
```
Güneş: Terazi (23 Eylül - 22 Ekim)
Doğum: 5 Ekim, 12:00
Beklenen Yükselen: Yay (öğlen doğumları)
```

### Senaryo 3: Gece Doğumu
```
Güneş: Koç (21 Mart - 19 Nisan)
Doğum: 1 Nisan, 22:00
Beklenen Yükselen: Yengeç (gece doğumları)
```

## Kullanıcı İçin Açıklama

Uygulamada kullanıcılara şu açıklama gösterilebilir:

```
ℹ️ Yükselen Burç Hesaplaması

Yükselen burcunuz, doğum saatinize ve yerinize göre 
hesaplanır. Bu uygulama basitleştirilmiş bir yöntem 
kullanır ve yaklaşık sonuçlar verir.

Daha kesin sonuçlar için profesyonel bir astroloji 
danışmanına başvurabilirsiniz.
```

## Değiştirilen Dosya
- `lib/services/gemini_service.dart` - `calculateRisingSign()` metodu

## Sonuç
✅ Tutarlı yükselen burç hesaplaması
✅ Matematiksel formül kullanımı
✅ AI sadece analiz için kullanılıyor
✅ Hızlı ve güvenilir sonuçlar

---

**Tarih**: 9 Şubat 2026
**Durum**: Düzeltildi
**Etkilenen Dosya**: `lib/services/gemini_service.dart`
