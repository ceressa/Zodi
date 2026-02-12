# Katkıda Bulunma Rehberi

Zodi projesine katkıda bulunmak istediğiniz için teşekkürler! 🎉

## 📋 İçindekiler

- [Davranış Kuralları](#davranış-kuralları)
- [Nasıl Katkıda Bulunabilirim?](#nasıl-katkıda-bulunabilirim)
- [Geliştirme Süreci](#geliştirme-süreci)
- [Kod Standartları](#kod-standartları)
- [Commit Mesajları](#commit-mesajları)
- [Pull Request Süreci](#pull-request-süreci)

## 🤝 Davranış Kuralları

Bu projede herkes için saygılı ve kapsayıcı bir ortam sağlamayı taahhüt ediyoruz. Lütfen:

- Saygılı ve yapıcı olun
- Farklı bakış açılarına açık olun
- Yapıcı eleştiri kabul edin
- Topluluk için en iyisine odaklanın

## 🚀 Nasıl Katkıda Bulunabilirim?

### Bug Bildirimi

Bug bulduysanız, lütfen bir issue açın ve şunları ekleyin:

- Bug'ın açık bir açıklaması
- Yeniden üretme adımları
- Beklenen davranış
- Gerçek davranış
- Ekran görüntüleri (varsa)
- Cihaz/platform bilgisi

### Özellik Önerisi

Yeni bir özellik önermek için:

- Özelliğin detaylı açıklaması
- Kullanım senaryoları
- Mockup'lar veya tasarımlar (varsa)
- Teknik uygulama fikirleri

### Kod Katkısı

1. Issue'yu kontrol edin veya yeni bir tane açın
2. Fork edin ve branch oluşturun
3. Kodunuzu yazın
4. Test edin
5. Pull request açın

## 🛠️ Geliştirme Süreci

### 1. Repo'yu Fork Edin

```bash
# GitHub'da fork butonuna tıklayın
# Sonra klonlayın
git clone https://github.com/YOUR_USERNAME/zodi-flutter.git
cd zodi-flutter
```

### 2. Upstream Ekleyin

```bash
git remote add upstream https://github.com/ORIGINAL_OWNER/zodi-flutter.git
```

### 3. Branch Oluşturun

```bash
git checkout -b feature/amazing-feature
# veya
git checkout -b fix/bug-fix
```

### 4. Geliştirme Yapın

```bash
# Bağımlılıkları yükleyin
flutter pub get

# Uygulamayı çalıştırın
flutter run

# Testleri çalıştırın
flutter test
```

### 5. Değişiklikleri Commit Edin

```bash
git add .
git commit -m "feat: Add amazing feature"
```

### 6. Push Edin

```bash
git push origin feature/amazing-feature
```

### 7. Pull Request Açın

GitHub'da pull request açın ve şunları ekleyin:

- Değişikliklerin açıklaması
- İlgili issue numarası
- Test sonuçları
- Ekran görüntüleri (UI değişiklikleri için)

## 📝 Kod Standartları

### Dart/Flutter Standartları

```dart
// ✅ İyi
class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Text('Hello'),
    );
  }
}

// ❌ Kötü
class mywidget extends StatelessWidget {
  mywidget();
  
  Widget build(context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Text('Hello')
    );
  }
}
```

### Dosya İsimlendirme

- Dosyalar: `snake_case.dart`
- Sınıflar: `PascalCase`
- Değişkenler: `camelCase`
- Sabitler: `SCREAMING_SNAKE_CASE`

### Kod Organizasyonu

```dart
// 1. Imports
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// 2. Constants
const double kPadding = 16.0;

// 3. Class
class MyScreen extends StatefulWidget {
  // 3.1. Constructor
  const MyScreen({super.key});

  // 3.2. Override methods
  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  // 4.1. State variables
  bool _isLoading = false;

  // 4.2. Lifecycle methods
  @override
  void initState() {
    super.initState();
  }

  // 4.3. Build method
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }

  // 4.4. Helper methods
  void _loadData() {
    // ...
  }
}
```

### Yorum Yazma

```dart
// Tek satırlık yorumlar için //

/// Dokümantasyon yorumları için ///
/// Bu method kullanıcı verilerini yükler
Future<void> loadUserData() async {
  // Implementation
}

/* 
 * Çok satırlı yorumlar için
 * bu formatı kullanın
 */
```

## 💬 Commit Mesajları

### Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Type

- `feat`: Yeni özellik
- `fix`: Bug düzeltme
- `docs`: Dokümantasyon
- `style`: Kod formatı
- `refactor`: Kod yeniden yapılandırma
- `test`: Test ekleme/düzeltme
- `chore`: Build/config değişiklikleri
- `perf`: Performans iyileştirme

### Örnekler

```bash
feat(tarot): Add three-card spread layout

- Implement new spread algorithm
- Add animation for card reveal
- Update UI for better spacing

Closes #123
```

```bash
fix(auth): Resolve login timeout issue

The login was timing out after 5 seconds.
Increased timeout to 30 seconds and added
retry logic.

Fixes #456
```

## 🔄 Pull Request Süreci

### PR Checklist

- [ ] Kod Flutter/Dart standartlarına uygun
- [ ] Tüm testler geçiyor
- [ ] Yeni özellikler için testler eklendi
- [ ] Dokümantasyon güncellendi
- [ ] Commit mesajları standartlara uygun
- [ ] UI değişiklikleri için ekran görüntüleri eklendi
- [ ] Breaking changes dokümante edildi

### PR Template

```markdown
## Açıklama
Bu PR'da ne değişti?

## Motivasyon ve Bağlam
Neden bu değişiklik gerekli?

## Nasıl Test Edildi?
- [ ] Manuel test
- [ ] Unit testler
- [ ] Integration testler

## Ekran Görüntüleri (varsa)
[Ekran görüntülerini buraya ekleyin]

## İlgili Issue'lar
Closes #123
```

### Review Süreci

1. En az bir maintainer review yapmalı
2. Tüm testler geçmeli
3. Conflict olmamalı
4. CI/CD pipeline başarılı olmalı

## 🧪 Test Yazma

### Unit Test Örneği

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:zodi_flutter/services/gemini_service.dart';

void main() {
  group('GeminiService', () {
    late GeminiService service;

    setUp(() {
      service = GeminiService();
    });

    test('should fetch daily horoscope', () async {
      final result = await service.fetchDailyHoroscope(ZodiacSign.aries);
      expect(result, isNotNull);
      expect(result.motto, isNotEmpty);
    });
  });
}
```

### Widget Test Örneği

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:zodi_flutter/widgets/animated_card.dart';

void main() {
  testWidgets('AnimatedCard displays child', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AnimatedCard(
          child: Text('Test'),
        ),
      ),
    );

    expect(find.text('Test'), findsOneWidget);
  });
}
```

## 📚 Kaynaklar

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- [Provider Documentation](https://pub.dev/packages/provider)
- [Firebase Documentation](https://firebase.google.com/docs)

## ❓ Sorular?

Sorularınız için:

- GitHub Discussions kullanın
- Issue açın
- Email: dev@zodi.app

---

Katkılarınız için teşekkürler! 🙏
