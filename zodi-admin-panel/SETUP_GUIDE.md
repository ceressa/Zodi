# 🚀 Zodi Admin Panel - Hızlı Başlangıç

## 📋 Önkoşullar

- ✅ Node.js 18+ yüklü
- ✅ npm veya yarn yüklü
- ✅ Firebase projesi oluşturulmuş
- ✅ Firebase Authentication aktif
- ✅ Firestore Database oluşturulmuş

## ⚡ 5 Dakikada Kurulum

### 1. Bağımlılıkları Yükle
\`\`\`bash
cd zodi-admin-panel
npm install
\`\`\`

### 2. Firebase Yapılandır
\`\`\`bash
cp .env.example .env
\`\`\`

`.env` dosyasını düzenle ve Firebase bilgilerini ekle.

### 3. Çalıştır
\`\`\`bash
npm run dev
\`\`\`

Panel `http://localhost:3001` adresinde hazır! 🎉

## 🔑 Firebase Admin Kullanıcısı Oluşturma

Firebase Console'da:

1. **Authentication** → **Users** → **Add User**
2. Email: `admin@zodi.com`
3. Password: Güçlü bir şifre belirle
4. **Add User** butonuna tıkla

Bu bilgilerle panele giriş yapabilirsin!

## 📊 Test Verisi Ekleme

Firestore'a test verisi eklemek için:

\`\`\`javascript
// Firebase Console → Firestore → Add Collection

// Collection: users
{
  name: "Test Kullanıcı",
  email: "test@example.com",
  zodiacSign: "♈",
  isPremium: false,
  createdAt: new Date(),
  lastActive: new Date()
}
\`\`\`

## 🎨 Özelleştirme

### Renkleri Değiştir
`tailwind.config.js` dosyasında:
\`\`\`javascript
colors: {
  primary: {
    600: '#9333ea', // Ana renk
  }
}
\`\`\`

### Logo Değiştir
`src/components/Layout.jsx` dosyasında Sparkles icon'unu değiştir.

## 🚀 Production Deploy

### Vercel (Önerilen)
\`\`\`bash
npm run build
vercel --prod
\`\`\`

### Firebase Hosting
\`\`\`bash
npm run build
firebase init hosting
firebase deploy
\`\`\`

## 📱 Özellikler

✅ Dashboard - Gerçek zamanlı istatistikler
✅ Kullanıcı Yönetimi - Filtreleme, arama, export
✅ Analitik - Grafikler ve metrikler
✅ Gelir Takibi - Premium ve reklam geliri
✅ İçerik Yönetimi - Uygulama içeriği
✅ Ayarlar - Sistem yapılandırması

## 🐛 Sorun Giderme

**Problem:** Firebase bağlanamıyor
**Çözüm:** `.env` dosyasını kontrol et, Firebase config doğru mu?

**Problem:** Login çalışmıyor
**Çözüm:** Firebase Authentication'da Email/Password provider aktif mi?

**Problem:** Veriler görünmüyor
**Çözüm:** Firestore'da `users` collection'ı var mı?

## 📞 Yardım

Takıldığın yer mi var? README.md dosyasına bak veya issue aç!

---

**Kolay gelsin! ✨**
