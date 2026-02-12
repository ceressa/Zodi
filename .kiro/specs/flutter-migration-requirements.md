---
title: Flutter Migration - Zodi App
status: draft
created: 2026-02-06
---

# Flutter Migration Requirements

## Overview
Mevcut React web ve Kotlin Android uygulamasını Flutter ile tek bir cross-platform uygulamaya dönüştürme.

## Goals
- iOS ve Android için tek codebase
- Mevcut tüm özelliklerin korunması
- Google Gemini AI entegrasyonunun devam etmesi
- Modern, performanslı UI/UX
- Dark/Light tema desteği

## User Stories

### US-1: Uygulama Başlangıcı
**As a** kullanıcı  
**I want to** uygulamayı açtığımda splash screen görmek  
**So that** uygulama yüklenirken profesyonel bir deneyim yaşayabilirim

**Acceptance Criteria:**
- Splash screen 3 saniye gösterilir
- Zodi logosu ve animasyon içerir
- Otomatik olarak auth ekranına geçer

### US-2: Kullanıcı Girişi
**As a** yeni kullanıcı  
**I want to** adım ve email ile giriş yapabilmek  
**So that** kişiselleştirilmiş deneyim yaşayabilirim

**Acceptance Criteria:**
- Ad ve email input alanları
- Form validasyonu (email formatı)
- LocalStorage'a kayıt
- Başarılı girişte burç seçim ekranına yönlendirme

### US-3: Burç Seçimi
**As a** kullanıcı  
**I want to** 12 burçtan birini seçebilmek  
**So that** kişisel falımı görebilirim

**Acceptance Criteria:**
- 12 burç grid layout ile gösterilir
- Her burç için icon ve tarih aralığı
- Seçim sonrası LocalStorage'a kaydedilir
- Ana ekrana yönlendirme

### US-4: Günlük Fal
**As a** kullanıcı  
**I want to** günlük falımı görmek  
**So that** günüm hakkında fikir sahibi olabilirim

**Acceptance Criteria:**
- Gemini AI'dan günlük fal çekilir
- Motto ve yorum gösterilir
- Aşk, para, sağlık, kariyer metrikleri (0-100)
- Şanslı renk ve sayı
- Pull-to-refresh desteği
- Loading state

### US-5: Detaylı Analiz
**As a** kullanıcı  
**I want to** farklı kategorilerde detaylı analiz görmek  
**So that** hayatımın farklı alanları hakkında bilgi sahibi olabilirim

**Acceptance Criteria:**
- Kategori seçimi (Aşk, Kariyer, Sağlık, Para)
- Premium kullanıcılar için tüm kategoriler açık
- Free kullanıcılar için sınırlı erişim
- AI-generated detaylı içerik

### US-6: Uyum Analizi
**As a** kullanıcı  
**I want to** başka bir burçla uyumumuzu görmek  
**So that** ilişkilerim hakkında fikir sahibi olabilirim

**Acceptance Criteria:**
- İkinci burç seçimi
- Genel uyum skoru (0-100)
- Aşk, iletişim, güven alt skorları
- Detaylı yorum
- Premium özellik kontrolü

### US-7: Ayarlar ve Profil
**As a** kullanıcı  
**I want to** ayarlarımı yönetebilmek  
**So that** uygulamayı tercihlerime göre kullanabilirim

**Acceptance Criteria:**
- Tema değiştirme (Dark/Light)
- Burç değiştirme
- Premium upgrade butonu
- Kullanıcı bilgileri gösterimi

### US-8: Premium Upgrade
**As a** free kullanıcı  
**I want to** premium'a geçebilmek  
**So that** tüm özelliklere erişebilirim

**Acceptance Criteria:**
- Premium özelliklerin listesi
- Satın alma butonu (mock implementation)
- Başarılı upgrade sonrası tüm özelliklere erişim
- LocalStorage'da premium durumu

## Technical Requirements

### Architecture
- **State Management**: Provider veya Riverpod
- **Navigation**: go_router veya Navigator 2.0
- **Storage**: shared_preferences (LocalStorage yerine)
- **HTTP**: google_generative_ai package
- **Icons**: Custom zodiac icons + lucide_icons_flutter

### Project Structure
```
lib/
├── main.dart
├── models/
│   ├── zodiac_sign.dart
│   ├── daily_horoscope.dart
│   ├── compatibility_result.dart
│   └── detailed_analysis.dart
├── services/
│   ├── gemini_service.dart
│   └── storage_service.dart
├── providers/
│   ├── auth_provider.dart
│   ├── theme_provider.dart
│   └── horoscope_provider.dart
├── screens/
│   ├── splash_screen.dart
│   ├── auth_screen.dart
│   ├── selection_screen.dart
│   ├── daily_screen.dart
│   ├── analysis_screen.dart
│   ├── match_screen.dart
│   ├── settings_screen.dart
│   └── premium_screen.dart
├── widgets/
│   ├── zodiac_card.dart
│   ├── metric_card.dart
│   ├── progress_bar.dart
│   └── bottom_nav.dart
└── constants/
    ├── colors.dart
    ├── zodiac_data.dart
    └── strings.dart
```

### Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.0  # veya riverpod
  shared_preferences: ^2.2.0
  google_generative_ai: ^0.2.0
  lucide_icons_flutter: ^1.0.0
  go_router: ^13.0.0
```

### Design System
- Mevcut renk paletini koru (BgColor, CardColor, AccentPurple, AccentBlue)
- Material 3 design principles
- Custom zodiac icons (SVG veya IconData)
- Smooth animations ve transitions
- Responsive layout (mobile-first)

### API Integration
- Gemini AI entegrasyonu aynı kalacak
- Environment variables için flutter_dotenv
- Structured JSON responses
- Error handling ve retry logic

## Non-Functional Requirements

### Performance
- Splash screen 3 saniye
- API response max 5 saniye
- Smooth 60fps animations
- Efficient state management

### Localization
- Türkçe dil desteği (hardcoded strings için)
- Gelecekte i18n desteği için hazır yapı

### Platform Support
- iOS 12+
- Android 6.0+ (API 23)

## Out of Scope (Phase 1)
- Web desteği
- Push notifications
- Gerçek ödeme entegrasyonu
- Sosyal medya paylaşımı
- Offline mode

## Success Criteria
- [ ] Tüm user stories implement edildi
- [ ] iOS ve Android'de çalışıyor
- [ ] Gemini AI entegrasyonu çalışıyor
- [ ] Dark/Light tema çalışıyor
- [ ] Premium flow çalışıyor
- [ ] Performans hedefleri karşılandı

## Next Steps
1. Flutter projesi oluştur
2. Dependencies ekle
3. Project structure kur
4. Models ve constants tanımla
5. Services implement et
6. Screens oluştur
7. State management ekle
8. Test ve polish
