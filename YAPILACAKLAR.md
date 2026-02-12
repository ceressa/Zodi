# 🎯 Hemen Yapılacaklar (5 Dakika)

## 1️⃣ Firebase Console'da Authentication Aktifleştir

### Adım 1: Authentication Sayfasına Git
🔗 **Link**: https://console.firebase.google.com/project/zodi-cf6b7/authentication/providers

### Adım 2: Email/Password Aktifleştir
1. "Email/Password" satırına tıkla
2. "Enable" toggle'ını aç
3. "Save" butonuna tıkla

### Adım 3: Google Sign-In Aktifleştir
1. "Google" satırına tıkla
2. "Enable" toggle'ını aç
3. "Project support email" seç (kendi email'in)
4. "Save" butonuna tıkla

---

## 2️⃣ SHA-1 Fingerprint Ekle (ZORUNLU)

### Adım 1: Project Settings'e Git
🔗 **Link**: https://console.firebase.google.com/project/zodi-cf6b7/settings/general

### Adım 2: Android App Bölümünü Bul
- Sayfayı aşağı kaydır
- "Your apps" bölümünde Android app'i bul
- "Add fingerprint" butonuna tıkla

### Adım 3: SHA-1'i Yapıştır
```
8F:92:2C:00:61:B3:F7:34:1D:4C:E6:FC:FD:B4:5E:92:AC:FC:09:7E
```
- Yukarıdaki SHA-1'i kopyala
- Firebase Console'da "SHA certificate fingerprints" alanına yapıştır
- "Save" butonuna tıkla

### Adım 4: google-services.json Güncelle
1. Aynı sayfada "Download google-services.json" butonuna tıkla
2. İndirilen dosyayı şu konuma kopyala (üzerine yaz):
   ```
   C:\Users\Ufuk\AndroidStudioProjects\Zodi\android\app\google-services.json
   ```

---

## 3️⃣ Uygulamayı Test Et

### Uygulamayı Çalıştır
```bash
flutter run
```

### Test Senaryosu
1. ✅ Splash screen açılıyor mu?
2. ✅ Auth screen'de "Google ile Devam Et" butonu var mı?
3. ✅ Google butona tıklayınca hesap seçimi açılıyor mu?
4. ✅ Giriş yaptıktan sonra Selection screen'e yönlendiriyor mu?

---

## 4️⃣ Firestore'u Kontrol Et

### Firestore Console'a Git
🔗 **Link**: https://console.firebase.google.com/project/zodi-cf6b7/firestore/databases/-default-/data

### Kontrol Et
1. Database oluşturuldu mu? ✅
2. Giriş yaptıktan sonra `users` koleksiyonu oluştu mu?
3. Kullanıcı verilerini görebiliyor musun?

---

## ✅ Tamamlandı Kontrolü

- [ ] Authentication → Email/Password aktif
- [ ] Authentication → Google aktif
- [ ] SHA-1 fingerprint eklendi
- [ ] google-services.json güncellendi
- [ ] Uygulama çalışıyor
- [ ] Google Sign-In test edildi
- [ ] Firestore'da kullanıcı verisi görünüyor

---

## 🚨 Sorun mu Yaşıyorsun?

### Google Sign-In Çalışmıyor
**En yaygın sebep**: SHA-1 eklenmemiş veya google-services.json güncellenmemiş

**Çözüm**:
1. SHA-1'in eklendiğinden emin ol
2. google-services.json'u yeniden indir ve kopyala
3. Uygulamayı kapat ve yeniden çalıştır:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

### Firestore Permission Denied
**Sebep**: Kullanıcı giriş yapmamış

**Çözüm**:
1. Önce Google Sign-In ile giriş yap
2. Sonra Firestore işlemlerini dene

---

## 📞 Detaylı Bilgi

Daha fazla bilgi için: `FIREBASE_SETUP_COMPLETE.md`

---

**Toplam Süre**: ~5 dakika
**Zorluk**: Kolay 😊

Başarılar! 🚀
