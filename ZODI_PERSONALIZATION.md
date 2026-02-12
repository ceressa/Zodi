# 🌟 Zodi Kişiselleştirme Sistemi

## Genel Bakış

Zodi artık sadece burç yorumu yapmıyor - seni tanıyor, öğreniyor ve her etkileşimde daha kişisel yorumlar yapıyor!

## 🎯 Yeni Özellikler

### 1. Kullanıcı Profili Sistemi
**Dosya**: `lib/models/user_profile.dart`

Kullanıcıdan toplanan bilgiler:
- İsim ve e-posta
- Doğum tarihi, saati ve yeri
- Yükselen ve Ay burcu (hesaplanıyor)
- İlgi alanları (Aşk, Kariyer, Para, Sağlık, vb.)
- Tercihler

### 2. Etkileşim Geçmişi
**Dosya**: `lib/models/interaction_history.dart`

Her etkileşim kaydediliyor:
- Tarih ve saat
- Etkileşim tipi (daily, compatibility, analysis, dream)
- İçerik
- Kullanıcı puanı (1-5 yıldız)
- Kullanıcı geri bildirimi

### 3. Davranış Kalıpları
**Dosya**: `lib/services/user_history_service.dart`

Sistem otomatik olarak analiz ediyor:
- Toplam etkileşim sayısı
- En çok kullanılan özellikler
- Favori konular
- Ortalama memnuniyet skoru
- Okuma saati tercihi (sabah/öğleden sonra/akşam/gece)
- Detaylı analiz tercihi
- Uyumluluk/rüya yorumu ilgisi

### 4. Kişiselleştirilmiş Zodi
**Dosya**: `lib/services/gemini_service.dart`

Zodi artık:
- Kullanıcının geçmiş etkileşimlerini hatırlıyor
- Önceki yorumlarla tutarlı kalıyor
- Kullanıcının ilgi alanlarına odaklanıyor
- Geri bildirimlere göre üslubunu ayarlıyor
- Övgü ve eleştiriyi dengeli kullanıyor

## 📱 Kullanıcı Arayüzü

### Profil Kurulum Ekranı
**Dosya**: `lib/screens/profile_setup_screen.dart`

İlk kullanımda gösterilen ekran:
- Temel bilgiler (isim, e-posta)
- Doğum bilgileri (tarih, saat, yer)
- İlgi alanları seçimi (chip'ler ile)
- Animasyonlu, kullanıcı dostu tasarım

### Geri Bildirim Widget'ı
**Dosya**: `lib/widgets/feedback_widget.dart`

Her yorumdan sonra kullanıcı:
- 1-5 yıldız puan verebilir
- Opsiyonel metin geri bildirimi ekleyebilir
- Anında teşekkür mesajı görür

### Günlük Burç Ekranı Güncellemesi
**Dosya**: `lib/screens/daily_screen.dart`

Yeni eklenen:
- "Yorumum Nasıldı?" butonu
- Geri bildirim modal'ı
- Kullanıcı etkileşimi kaydı

### Yükselen Burç Ekranı Güncellemesi
**Dosya**: `lib/screens/rising_sign_screen.dart`

Yeni eklenen:
- Burç sembollerinin altında burç isimleri
- Daha net ve anlaşılır görünüm

## 🔄 Veri Akışı

```
1. Kullanıcı profil oluşturur
   ↓
2. Profil UserHistoryService'e kaydedilir
   ↓
3. Kullanıcı burç yorumu ister
   ↓
4. GeminiService kişiselleştirilmiş bağlam oluşturur
   ↓
5. Gemini AI kullanıcıya özel yorum yapar
   ↓
6. Etkileşim geçmişe kaydedilir
   ↓
7. Kullanıcı geri bildirim verir
   ↓
8. Davranış kalıpları güncellenir
   ↓
9. Bir sonraki yorum daha kişisel olur
```

## 💾 Veri Saklama

Tüm veriler `shared_preferences` ile lokal olarak saklanıyor:
- `userProfile` - Kullanıcı profili
- `interactionHistory` - Son 100 etkileşim
- `behaviorPattern` - Analiz edilmiş davranış kalıpları

## 🎨 Zodi Karakteri

**Dosya**: `ZODI_CHARACTER.md`

Detaylı karakter profili içerir:
- Görsel tasarım önerileri
- Kişilik özellikleri
- İletişim tarzı
- Konuşma örnekleri
- Logo tasarım promptu
- Karakter illüstrasyonu promptu

## 🚀 Kullanım

### Profil Kurulumu
```dart
// İlk kullanımda göster
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ProfileSetupScreen(
      onComplete: () {
        // Profil tamamlandı, ana ekrana dön
      },
    ),
  ),
);
```

### Geri Bildirim Alma
```dart
// Herhangi bir ekrandan çağır
showFeedbackDialog(context, 'daily');
```

### Kişiselleştirilmiş Bağlam
```dart
// GeminiService otomatik olarak kullanır
final horoscope = await geminiService.fetchDailyHoroscope(sign);
```

## 📊 Analitik

Sistem şu metrikleri takip ediyor:
- Toplam etkileşim sayısı
- Etkileşim türü dağılımı
- Ortalama kullanıcı memnuniyeti
- En popüler özellikler
- Kullanım saatleri
- Geri bildirim oranı

## 🔮 Gelecek Geliştirmeler

1. **Makine Öğrenmesi**: Kullanıcı tercihlerini daha iyi tahmin etme
2. **Sosyal Özellikler**: Arkadaşlarla uyumluluk karşılaştırma
3. **Bildirimler**: Kişiselleştirilmiş günlük hatırlatmalar
4. **Raporlar**: Aylık kişisel astroloji raporu
5. **Chatbot**: Zodi ile sohbet özelliği

## 🎯 Başarı Metrikleri

Kişiselleştirme başarısını ölçmek için:
- Kullanıcı geri bildirim puanı (hedef: >4.0/5.0)
- Günlük aktif kullanıcı oranı (hedef: %60+)
- Geri bildirim verme oranı (hedef: %30+)
- Premium dönüşüm oranı (hedef: %10+)

## 🛠️ Teknik Detaylar

### Bağımlılıklar
```yaml
dependencies:
  shared_preferences: ^2.2.2  # Lokal veri saklama
  provider: ^6.1.1            # State management
  google_generative_ai: ^0.2.2 # Gemini AI
  flutter_animate: ^4.5.0     # Animasyonlar
```

### Performans
- Geçmiş son 100 etkileşimle sınırlı (hafıza optimizasyonu)
- Davranış kalıpları her etkileşimde güncelleniyor
- Kişiselleştirilmiş bağlam cache'leniyor

### Güvenlik
- Tüm veriler lokal cihazda
- API key'ler .env dosyasında
- Kişisel veriler şifrelenmeli (TODO)

## 📝 Örnek Kullanım Senaryosu

**Senaryo**: Yeni kullanıcı Ayşe

1. **Gün 1**: Ayşe uygulamayı indiriyor
   - Profil kurulum ekranı açılıyor
   - Doğum bilgilerini giriyor
   - "Aşk ve İlişkiler" ile "Kariyer" seçiyor
   - İlk günlük falını alıyor
   - 5 yıldız veriyor: "Çok beğendim!"

2. **Gün 2**: Ayşe tekrar geliyor
   - Zodi artık ismini biliyor
   - Yorum daha samimi: "Ayşe, bugün aşk hayatında..."
   - Kariyer konusuna da değiniyor
   - 4 yıldız veriyor

3. **Gün 7**: Ayşe düzenli kullanıcı
   - Zodi onun sabah kişisi olduğunu öğrenmiş
   - Yorumlar daha detaylı (tercih ediyor)
   - Uyumluluk özelliğini keşfediyor
   - Premium'a geçiyor

4. **Gün 30**: Ayşe sadık kullanıcı
   - Zodi onu çok iyi tanıyor
   - Yorumlar tutarlı ve kişisel
   - Her gün geri bildirim veriyor
   - Arkadaşlarına öneriyor

## 🎨 Logo ve Karakter Tasarımı

### Logo İçin Gemini/ChatGPT Promptu
`ZODI_CHARACTER.md` dosyasında detaylı prompt var. Özetle:
- Mor-mavi gradyan "Z" harfi
- Yıldız konstelasyonu şeklinde
- Minimalist ama mistik
- Hem teknolojik hem ruhani

### Karakter İçin Prompt
- 25-30 yaş, androgyn
- Mor-mavi gradyan saçlar
- Galaksi gözler
- Modern ceket üzerinde burç sembolleri
- Elinde kristal küre ve tarot kartları
- Studio Ghibli + Cyberpunk + Cosmic Art karışımı

## 📞 Destek

Sorular için:
- Kod: `lib/services/user_history_service.dart`
- Karakter: `ZODI_CHARACTER.md`
- Genel: `README_FLUTTER.md`

---

**Not**: Bu sistem kullanıcı deneyimini kişiselleştirmek için tasarlandı. Gizlilik ve veri güvenliği her zaman öncelik olmalı!
