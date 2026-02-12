# Firestore User Profile - Zengin Kullanıcı Profili

## Genel Bakış

Zodi uygulamasında kullanıcıların tüm astrolojik yolculuğunu, tercihlerini, davranışlarını ve etkileşim geçmişini detaylıca kaydediyoruz. Bu sayede:

- **Kişiselleştirilmiş içerik** sunabiliyoruz
- **Kullanıcı davranışlarını** analiz edebiliyoruz
- **Segmentasyon** yapabiliyoruz (yeni kullanıcı, sadık kullanıcı, premium vb.)
- **Kullanım istatistikleri** toplayabiliyoruz
- **Geri bildirim** ile içeriği iyileştirebiliyoruz

## Firestore Yapısı

```
users/
  {userId}/
    - Temel Bilgiler (name, email, photoUrl, createdAt, lastActiveAt)
    - Doğum Bilgileri (birthDate, birthTime, birthPlace, coordinates)
    - Astrolojik Profil (zodiacSign, risingSign, moonSign, venusSign, marsSign, etc.)
    - Kişiselleştirme (interests, favoriteTopics, preferredLanguage, preferredTone)
    - Premium & Abonelik (isPremium, premiumStartDate, subscriptionType)
    - Kullanım İstatistikleri (totalHoroscopeReads, consecutiveDays, featureUsageCount)
    - Favori & Geçmiş (savedHoroscopes, savedDreams, recentSearches)
    - Sosyal & İlişkiler (relationshipStatus, partnerZodiacSign, friendZodiacSigns)
    - Davranış Analizi (readingPatterns, mostReadCategories, averageSessionDuration)
    - Geri Bildirim (averageRating, categoryRatings, totalFeedbacks)
    - Tercihler (darkMode, notificationsEnabled, autoRefresh)
    - Özel Alanlar (customFields, tags)
    
  interactions/
    {interactionId}/
      - timestamp
      - interactionType
      - content
      - metadata
```

## Otomatik Güncellenen Alanlar

### 1. Her Özellik Kullanımında
```dart
// Otomatik olarak güncellenir:
- featureUsageCount[featureName]++
- totalHoroscopeReads++ (daily horoscope için)
- totalCompatibilityChecks++ (compatibility için)
- totalDreamInterpretations++ (dream için)
- lastActiveAt = now()
```

### 2. Her Oturum Sonunda
```dart
// Oturum bilgileri:
- totalSessions++
- averageSessionDuration = yeni ortalama
```

### 3. Her Okuma Sonrası
```dart
// Okuma desenleri:
- readingPatterns[category] = {count, totalDuration}
- mostReadCategories = en çok okunan 5 kategori
- preferredReadingTime = en çok kullanılan zaman dilimi
```

### 4. Her Gün Kontrolü
```dart
// Ardışık gün takibi:
- consecutiveDays++ (eğer dün de okumuşsa)
- consecutiveDays = 1 (eğer ara vermişse)
```

### 5. Kullanıcı Etiketleri (Otomatik)
```dart
// Otomatik etiketleme:
- 'premium' (isPremium = true)
- 'loyal' (consecutiveDays >= 7)
- 'super_loyal' (consecutiveDays >= 30)
- 'power_user' (totalSessions >= 50)
- 'new_user' (daysSinceCreation <= 7)
- 'veteran' (daysSinceCreation > 90)
- 'avid_reader' (totalReads > 100)
- 'compatibility_enthusiast' (totalCompatibility > 20)
- 'dream_explorer' (totalDreams > 10)
```

## Firebase Service Metodları

### Kullanım İstatistikleri
```dart
// Özellik kullanımını artır
await _firebaseService.incrementFeatureUsage('daily_horoscope');

// Ardışık gün sayısını güncelle
await _firebaseService.updateConsecutiveDays();

// Oturum bilgilerini güncelle
await _firebaseService.updateSessionInfo(durationMinutes);
```

### Favori & Kayıtlar
```dart
// Favori uyumluluğu ekle/çıkar
await _firebaseService.toggleFavoriteCompatibility('aries_leo');

// Burç yorumunu kaydet
await _firebaseService.toggleSavedHoroscope(horoscopeId);

// Rüya yorumunu kaydet
await _firebaseService.saveDreamInterpretation(dreamId);

// Son aramaya ekle
await _firebaseService.addRecentSearch('Rüya: Uçmak');
```

### Davranış Analizi
```dart
// Okuma desenlerini güncelle
await _firebaseService.updateReadingPatterns('daily', durationSeconds);

// Tercih edilen okuma saatini güncelle (otomatik)
await _firebaseService.updatePreferredReadingTime();

// Son görüntülenen burcu güncelle
await _firebaseService.updateLastViewedZodiacSign('aries');
```

### Geri Bildirim
```dart
// Geri bildirim puanı kaydet
await _firebaseService.submitRating('daily', 4.5, 'Çok beğendim!');
```

### Profil Güncelleme
```dart
// İlgi alanlarını güncelle
await _firebaseService.updateInterests(['love', 'career', 'money']);

// İlişki durumunu güncelle
await _firebaseService.updateRelationshipInfo(
  relationshipStatus: 'relationship',
  partnerZodiacSign: 'leo',
);

// Astrolojik profili güncelle
await _firebaseService.updateAstrologicalProfile(
  risingSign: 'virgo',
  moonSign: 'pisces',
);
```

### Tercihler
```dart
// Bildirim tercihlerini güncelle
await _firebaseService.updateNotificationSettings(
  enabled: true,
  time: '09:00',
);

// Tema tercihini güncelle
await _firebaseService.updateThemePreference(darkMode: true);
```

## Ekranlarda Kullanım Örnekleri

### Daily Screen
```dart
Future<void> _loadHoroscope() async {
  // ... horoscope yükleme
  
  if (_firebaseService.isAuthenticated) {
    // 1. Özellik kullanımını artır
    _firebaseService.incrementFeatureUsage('daily_horoscope');
    
    // 2. Ardışık gün sayısını güncelle
    _firebaseService.updateConsecutiveDays();
    
    // 3. Son görüntülenen burcu kaydet
    _firebaseService.updateLastViewedZodiacSign(zodiacSign);
    
    // 4. Okuma desenlerini güncelle
    _firebaseService.updateReadingPatterns('daily', readDuration);
    
    // 5. Tercih edilen okuma saatini güncelle
    _firebaseService.updatePreferredReadingTime();
    
    // 6. Favori konuları güncelle
    _firebaseService.updateFavoriteTopics('daily_horoscope');
    
    // 7. Kullanıcı etiketlerini güncelle
    _firebaseService.updateUserTags();
  }
}
```

### Match Screen
```dart
Future<void> _loadCompatibility() async {
  // ... compatibility yükleme
  
  if (_firebaseService.isAuthenticated) {
    // 1. Özellik kullanımını artır
    _firebaseService.incrementFeatureUsage('compatibility');
    
    // 2. Favori uyumluluğu kaydet
    final key = '${sign1}_${sign2}';
    _firebaseService.toggleFavoriteCompatibility(key);
    
    // 3. Partner burç bilgisini güncelle
    _firebaseService.updateRelationshipInfo(
      partnerZodiacSign: partnerSign,
    );
    
    // 4. Okuma desenlerini güncelle
    _firebaseService.updateReadingPatterns('compatibility', 30);
  }
}
```

### Dream Screen
```dart
Future<void> _interpretDream() async {
  // ... dream interpretation
  
  if (_firebaseService.isAuthenticated) {
    // 1. Özellik kullanımını artır
    _firebaseService.incrementFeatureUsage('dream_interpretation');
    
    // 2. Rüya yorumunu kaydet
    final dreamId = DateTime.now().millisecondsSinceEpoch.toString();
    _firebaseService.saveDreamInterpretation(dreamId);
    
    // 3. Son aramaya ekle
    _firebaseService.addRecentSearch('Rüya: ${dreamText.substring(0, 50)}...');
  }
}
```

### Feedback Widget
```dart
Future<void> _submitFeedback() async {
  // ... feedback gönderme
  
  if (_firebaseService.isAuthenticated) {
    // Geri bildirim puanını kaydet
    await _firebaseService.submitRating(
      interactionType,
      rating,
      feedbackText,
    );
  }
}
```

## Kullanıcı Segmentasyonu

### Etiketlere Göre Filtreleme
```dart
// Firestore query örneği:
final loyalUsers = await firestore
    .collection('users')
    .where('tags', arrayContains: 'loyal')
    .get();

final premiumUsers = await firestore
    .collection('users')
    .where('isPremium', isEqualTo: true)
    .get();

final newUsers = await firestore
    .collection('users')
    .where('tags', arrayContains: 'new_user')
    .get();
```

### Davranış Bazlı Segmentasyon
```dart
// Aktif kullanıcılar (son 7 gün içinde aktif)
final activeUsers = await firestore
    .collection('users')
    .where('lastActiveAt', isGreaterThan: DateTime.now().subtract(Duration(days: 7)))
    .get();

// Yüksek engagement (50+ oturum)
final powerUsers = await firestore
    .collection('users')
    .where('totalSessions', isGreaterThan: 50)
    .get();
```

## Analytics & Insights

### Kullanım Metrikleri
- Toplam kullanıcı sayısı
- Aktif kullanıcı sayısı (DAU, WAU, MAU)
- Ortalama oturum süresi
- Özellik kullanım oranları
- Ardışık gün ortalaması
- Premium dönüşüm oranı

### Davranış Analizi
- En popüler özellikler
- En çok okunan kategoriler
- Tercih edilen okuma saatleri
- Ortalama geri bildirim puanı
- Kategori bazlı memnuniyet

### Segmentasyon Metrikleri
- Yeni kullanıcı oranı
- Sadık kullanıcı oranı
- Premium kullanıcı oranı
- Churn rate (kayıp oranı)
- Retention rate (elde tutma oranı)

## Best Practices

1. **Performans**: Tüm Firebase işlemleri asenkron ve non-blocking
2. **Hata Yönetimi**: Try-catch blokları ile hata yakalama
3. **Privacy**: Kullanıcı izni ile veri toplama (shareDataForPersonalization)
4. **Optimizasyon**: Batch updates kullanarak Firestore yazma sayısını azaltma
5. **Caching**: Local storage ile Firebase verilerini cache'leme
6. **Analytics**: Firebase Analytics ile kullanıcı davranışlarını takip etme

## Gelecek Geliştirmeler

- [ ] Machine Learning ile kişiselleştirilmiş içerik önerileri
- [ ] Kullanıcı segmentlerine özel push notifications
- [ ] A/B testing için kullanıcı grupları
- [ ] Referral program için referral tracking
- [ ] Social features için friend connections
- [ ] Gamification için achievement system
