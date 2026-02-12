# Zodi Flutter App

Flutter ile geliştirilmiş premium astroloji uygulaması. Google Gemini AI ile desteklenen kişiselleştirilmiş günlük fallar, uyum analizi ve detaylı astrolojik içgörüler.

## Özellikler

- 🌟 Günlük fal okuma (aşk, para, sağlık, kariyer metrikleri)
- 💕 Burç uyum analizi
- 📊 Detaylı kategori bazlı analizler
- 🎨 Dark/Light tema desteği
- 👤 Kullanıcı profil yönetimi
- ⭐ Premium/Freemium model

## Gereksinimler

- Flutter SDK 3.0.0 veya üzeri
- Dart 3.0.0 veya üzeri
- Google Gemini API Key

## Kurulum

1. **Bağımlılıkları yükle:**
```bash
flutter pub get
```

2. **API Key'i ayarla:**
`.env` dosyasını düzenle ve Gemini API key'ini ekle:
```
GEMINI_API_KEY=your_actual_api_key_here
```

3. **Uygulamayı çalıştır:**
```bash
flutter run
```

## Proje Yapısı

```
lib/
├── main.dart                 # Uygulama giriş noktası
├── constants/               # Sabitler
│   ├── colors.dart         # Renk paleti
│   └── strings.dart        # Metin sabitleri
├── models/                  # Veri modelleri
│   ├── zodiac_sign.dart
│   ├── daily_horoscope.dart
│   ├── detailed_analysis.dart
│   └── compatibility_result.dart
├── services/                # Servisler
│   ├── gemini_service.dart # AI entegrasyonu
│   └── storage_service.dart # Local storage
├── providers/               # State management
│   ├── auth_provider.dart
│   ├── theme_provider.dart
│   └── horoscope_provider.dart
├── screens/                 # Ekranlar
│   ├── splash_screen.dart
│   ├── auth_screen.dart
│   ├── selection_screen.dart
│   ├── home_screen.dart
│   ├── daily_screen.dart
│   ├── analysis_screen.dart
│   ├── match_screen.dart
│   ├── settings_screen.dart
│   └── premium_screen.dart
└── widgets/                 # Yeniden kullanılabilir widget'lar
    └── metric_card.dart
```

## Kullanılan Paketler

- **provider**: State management
- **shared_preferences**: Local storage
- **google_generative_ai**: Gemini AI entegrasyonu
- **flutter_dotenv**: Environment variables
- **intl**: Tarih formatlama

## Özellikler

### Splash Screen
- 3 saniye animasyonlu açılış ekranı
- Otomatik yönlendirme (auth/selection/home)

### Authentication
- Ad ve email ile giriş
- Form validasyonu
- Local storage'a kayıt

### Burç Seçimi
- 12 burç grid layout
- Her burç için sembol ve tarih aralığı
- Seçim sonrası otomatik kayıt

### Günlük Fal
- Gemini AI ile günlük fal
- Motto ve detaylı yorum
- 4 metrik (aşk, para, sağlık, kariyer)
- Şanslı renk ve sayı
- Pull-to-refresh

### Detaylı Analiz
- 4 kategori (Aşk, Kariyer, Sağlık, Para)
- Premium özellik
- AI-generated içerik

### Uyum Analizi
- Burç seçimi
- Genel uyum skoru
- Alt metrikler (aşk, iletişim, güven)
- Detaylı yorum

### Ayarlar
- Tema değiştirme
- Burç değiştirme
- Premium upgrade
- Çıkış yapma

### Premium
- Özellik listesi
- Mock satın alma
- Tüm özelliklere erişim

## Build

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## Notlar

- API key'i `.env` dosyasında saklanır
- Kullanıcı verileri `shared_preferences` ile local'de tutulur
- Tema tercihi otomatik kaydedilir
- Premium durumu mock implementation (gerçek ödeme entegrasyonu yok)

## Geliştirme

Yeni özellik eklerken:
1. Model'i `models/` klasörüne ekle
2. Servis metodunu `services/` klasörüne ekle
3. Provider'ı `providers/` klasörüne ekle
4. Screen'i `screens/` klasörüne ekle
5. Gerekirse widget'ı `widgets/` klasörüne ekle

## Lisans

Bu proje Zodi uygulamasının Flutter versiyonudur.
