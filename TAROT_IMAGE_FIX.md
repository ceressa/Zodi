# Tarot Kartı Görsel Sorunu Çözümü

## Sorun
Tarot kartlarının görselleri ekranda görünmüyordu.

## Kök Neden
`tarot_data.dart` dosyasında `imageUrl` oluşturulurken **liste index'i** kullanılıyordu, **kart numarası** yerine.

### Hatalı Kod
```dart
static TarotCard getCard(int index, bool reversed) {
  final cardData = allCards[index];
  return TarotCard(
    name: cardData['name'] as String,
    number: cardData['number'] as int,
    suit: cardData['suit'] as TarotSuit,
    reversed: reversed,
    imageUrl: 'assets/tarot/${index}.webp',  // ❌ YANLIŞ: index kullanıyor
    basicMeaning: cardData['meaning'] as String,
  );
}
```

### Sorun Nedir?
- `index`: Liste içindeki pozisyon (0, 1, 2, 3...)
- `number`: Kartın gerçek numarası (0-21 Major Arcana için)
- Eğer kartlar listede karışık sıradaysa, yanlış resim yüklenir

**Örnek:**
- Liste index 5'te "Aziz" kartı var (number: 5)
- Ama liste index 10'da "Kader Çarkı" var (number: 10)
- `imageUrl: 'assets/tarot/${index}.webp'` → `assets/tarot/10.webp` yükler
- Ama dosya adı kart numarasına göre: `assets/tarot/10.webp` (Kader Çarkı)
- Sonuç: Doğru kart, doğru resim ✓

**Ama eğer liste sırası değişirse:**
- Liste index 10'da "Adalet" kartı var (number: 11)
- `imageUrl: 'assets/tarot/${index}.webp'` → `assets/tarot/10.webp` yükler
- Ama Adalet'in resmi `11.webp` olmalı
- Sonuç: Yanlış resim ✗

## Çözüm
Kart numarasını (`number`) kullan, liste index'ini değil.

### Düzeltilmiş Kod
```dart
static TarotCard getCard(int index, bool reversed) {
  final cardData = allCards[index];
  final cardNumber = cardData['number'] as int;  // ✓ Kart numarasını al
  return TarotCard(
    name: cardData['name'] as String,
    number: cardNumber,
    suit: cardData['suit'] as TarotSuit,
    reversed: reversed,
    imageUrl: 'assets/tarot/$cardNumber.webp',  // ✓ DOĞRU: number kullanıyor
    basicMeaning: cardData['meaning'] as String,
  );
}
```

## Dosya Yapısı Kontrolü

### Assets Klasörü
```
assets/tarot/
├── 0.webp   (The Fool - Deli)
├── 1.webp   (The Magician - Büyücü)
├── 2.webp   (The High Priestess - Azize)
├── ...
├── 20.webp  (Judgement - Mahşer)
└── 21.webp  (The World - Dünya)
```

### pubspec.yaml
```yaml
flutter:
  uses-material-design: true
  assets:
    - .env
    - assets/
    - assets/tarot/  # ✓ Tarot klasörü tanımlı
```

## Diğer Olası Nedenler

Eğer hala görsel çıkmıyorsa:

### 1. Hot Reload Yeterli Değil
Assets değişikliklerinde tam restart gerekir:
```bash
# Uygulamayı durdur
# Tekrar çalıştır
flutter run
```

### 2. Build Cache Sorunu
```bash
flutter clean
flutter pub get
flutter build apk --debug
```

### 3. Dosya Adı Uyumsuzluğu
- Dosya adları: `0.webp`, `1.webp`, ..., `21.webp`
- Kod: `'assets/tarot/$cardNumber.webp'`
- Eşleşme: ✓

### 4. pubspec.yaml Hatası
```yaml
# YANLIŞ
assets:
  - assets/tarot/*.webp  # ❌ Wildcard çalışmaz

# DOĞRU
assets:
  - assets/tarot/  # ✓ Klasör tanımı
```

### 5. Image Widget Hatası
`tarot_card_widget.dart` içinde:
```dart
Image.asset(
  widget.card.imageUrl,  // 'assets/tarot/5.webp'
  fit: BoxFit.contain,
  errorBuilder: (context, error, stackTrace) {
    // Hata durumunda fallback göster
    return Container(...);
  },
)
```

## Test Adımları

1. **Dosyaları Kontrol Et**
   ```bash
   ls assets/tarot/
   # 0.webp, 1.webp, ..., 21.webp olmalı
   ```

2. **pubspec.yaml Kontrol Et**
   ```yaml
   assets:
     - assets/tarot/
   ```

3. **Kodu Kontrol Et**
   ```dart
   imageUrl: 'assets/tarot/$cardNumber.webp'
   ```

4. **Build ve Test**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

5. **Debug Çıktısını İzle**
   ```
   # Eğer resim yüklenemezse console'da göreceksin:
   Unable to load asset: assets/tarot/5.webp
   ```

## Değiştirilen Dosya
- `lib/constants/tarot_data.dart` - `getCard()` metodu

## Sonuç
✅ Kart numarası (`number`) kullanılarak doğru resim yükleniyor
✅ Liste sırası değişse bile resimler doğru eşleşiyor
✅ Major Arcana kartları (0-21) için resimler hazır

---

**Tarih**: 9 Şubat 2026
**Durum**: Düzeltildi
**Etkilenen Dosya**: `lib/constants/tarot_data.dart`
