# 🔥 Firebase Setup Guide

## Genel Bakış

Zodi uygulaması Firebase kullanarak:
- Kullanıcı kimlik doğrulama (Authentication)
- Veri saklama (Firestore)
- Analitik (Analytics)
- Hata takibi (Crashlytics)
- Dosya depolama (Storage)

## 📋 Ön Gereksinimler

1. Firebase Console hesabı: https://console.firebase.google.com
2. FlutterFire CLI kurulu olmalı:
```bash
dart pub global activate flutterfire_cli
```

## 🚀 Kurulum Adımları

### 1. Firebase Projesi Oluştur

1. Firebase Console'a git: https://console.firebase.google.com
2. "Add project" butonuna tıkla
3. Proje adı: `zodi-app` (veya istediğin isim)
4. Google Analytics'i etkinleştir (önerilen)
5. Projeyi oluştur

### 2. FlutterFire CLI ile Yapılandır

Proje klasöründe şu komutu çalıştır:

```bash
flutterfire configure
```

Bu komut:
- Firebase projesini seçmeni ister
- Android, iOS ve Web için otomatik yapılandırma yapar
- `lib/firebase_options.dart` dosyasını oluşturur
- `google-services.json` (Android) ve `GoogleService-Info.plist` (iOS) dosyalarını indirir

### 3. Firebase Servislerini Etkinleştir

#### Authentication
1. Firebase Console → Authentication
2. "Get started" butonuna tıkla
3. Sign-in methods:
   - Email/Password → Enable
   - Anonymous → Enable (opsiyonel)

#### Firestore Database
1. Firebase Console → Firestore Database
2. "Create database" butonuna tıkla
3. Production mode seç
4. Location seç (europe-west1 önerilen)

#### Security Rules (Firestore)
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // Interactions subcollection
      match /interactions/{interactionId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
    
    // Feedback collection (write-only for users)
    match /feedback/{feedbackId} {
      allow create: if request.auth != null;
      allow read: if false; // Only admins can read
    }
  }
}
```

#### Analytics
1. Firebase Console → Analytics
2. Otomatik olarak etkinleştirilmiş olmalı
3. Events → Custom definitions → Create custom event (opsiyonel)

#### Crashlytics
1. Firebase Console → Crashlytics
2. "Enable Crashlytics" butonuna tıkla
3. SDK otomatik olarak entegre edilecek

#### Storage (Opsiyonel)
1. Firebase Console → Storage
2. "Get started" butonuna tıkla
3. Security rules:
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### 4. Android Yapılandırması

#### `android/app/build.gradle.kts`
```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // Firebase
    id("com.google.firebase.crashlytics") // Crashlytics
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:32.7.0"))
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-crashlytics")
}
```

#### `android/build.gradle.kts`
```kotlin
buildscript {
    dependencies {
        classpath("com.google.gms:google-services:4.4.0")
        classpath("com.google.firebase:firebase-crashlytics-gradle:2.9.9")
    }
}
```

### 5. iOS Yapılandırması

#### `ios/Podfile`
```ruby
platform :ios, '13.0'

target 'Runner' do
  use_frameworks!
  use_modular_headers!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
  
  # Firebase
  pod 'Firebase/Analytics'
  pod 'Firebase/Crashlytics'
end
```

Sonra çalıştır:
```bash
cd ios
pod install
cd ..
```

## 📱 Uygulama Entegrasyonu

### main.dart Güncellemesi

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase'i başlat
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Firebase servisini başlat
  await FirebaseService.initialize();
  
  runApp(const MyApp());
}
```

## 🔐 Güvenlik

### Environment Variables
`.env` dosyasına Firebase bilgilerini ekleme (opsiyonel):
```
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_API_KEY=your-api-key
```

### .gitignore
Şunların ignore edildiğinden emin ol:
```
# Firebase
google-services.json
GoogleService-Info.plist
firebase_options.dart
.firebase/
```

## 📊 Firestore Veri Yapısı

### Users Collection
```
users/{userId}
  ├── name: string
  ├── email: string
  ├── birthDate: timestamp
  ├── birthTime: string
  ├── birthPlace: string
  ├── risingSign: string?
  ├── moonSign: string?
  ├── interests: array<string>
  ├── isPremium: boolean
  ├── createdAt: timestamp
  └── interactions/{interactionId}
      ├── timestamp: timestamp
      ├── interactionType: string
      ├── content: string
      ├── context: map
      ├── userRating: number?
      └── userFeedback: string?
```

### Feedback Collection
```
feedback/{feedbackId}
  ├── userId: string
  ├── interactionType: string
  ├── rating: number
  ├── feedback: string?
  └── timestamp: timestamp
```

## 🎯 Kullanım Örnekleri

### Authentication
```dart
final firebaseService = FirebaseService();

// Anonymous sign in
await firebaseService.signInAnonymously();

// Email/Password sign up
await firebaseService.signUpWithEmailPassword(email, password);

// Sign out
await firebaseService.signOut();
```

### User Profile
```dart
// Save profile
await firebaseService.saveUserProfile(userProfile);

// Get profile
final profile = await firebaseService.getUserProfile();
```

### Interactions
```dart
// Save interaction
await firebaseService.saveInteraction(interaction);

// Get history
final history = await firebaseService.getInteractionHistory(limit: 50);
```

### Analytics
```dart
// Log horoscope view
await firebaseService.logHoroscopeView('Koç', 'daily');

// Log compatibility check
await firebaseService.logCompatibilityCheck('Koç', 'Aslan');
```

## 🧪 Test Etme

### Emulator Suite
Firebase Console → Emulators → Start emulators

```bash
firebase emulators:start
```

### Test Kullanıcısı
```dart
// Test için anonymous sign in kullan
await FirebaseService().signInAnonymously();
```

## 📈 Monitoring

### Crashlytics
```dart
// Manuel hata kaydı
await FirebaseCrashlytics.instance.recordError(
  error,
  stackTrace,
  reason: 'Custom error',
);
```

### Analytics Dashboard
Firebase Console → Analytics → Dashboard
- Aktif kullanıcılar
- Retention
- Custom events
- User properties

## 🔄 Sync Stratejisi

### Hybrid Approach (Önerilen)
1. Lokal veri `shared_preferences`'ta saklanır (hızlı erişim)
2. Firebase'e periyodik sync yapılır (cloud backup)
3. Uygulama açılışında Firebase'den çekilir (multi-device sync)

```dart
// Sync local to Firebase
final localData = await StorageService().getAllData();
await FirebaseService().syncLocalToFirebase(localData);
```

## 🚨 Sorun Giderme

### "Firebase not initialized"
```dart
// main.dart'ta Firebase.initializeApp() çağrıldığından emin ol
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

### "Permission denied" (Firestore)
- Security rules'u kontrol et
- Kullanıcı authenticate olmuş mu kontrol et

### "google-services.json not found"
```bash
# FlutterFire CLI'yi tekrar çalıştır
flutterfire configure
```

### iOS Build Hatası
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter pub get
```

## 📚 Kaynaklar

- Firebase Documentation: https://firebase.google.com/docs
- FlutterFire: https://firebase.flutter.dev
- Firebase Console: https://console.firebase.google.com
- FlutterFire CLI: https://github.com/invertase/flutterfire_cli

## 🎯 Sonraki Adımlar

1. ✅ Firebase projesini oluştur
2. ✅ FlutterFire CLI ile yapılandır
3. ✅ Servisleri etkinleştir
4. ✅ Security rules'u ayarla
5. ✅ Uygulamayı test et
6. 🔄 Production'a deploy et
7. 📊 Analytics'i izle

---

**Not**: Firebase ücretsiz plan (Spark) ile başlayabilirsin. Kullanıcı sayısı arttıkça Blaze (pay-as-you-go) planına geçebilirsin.
