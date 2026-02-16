# 🌟 Zodi Admin Panel

Zodi astroloji uygulaması için modern, responsive ve özellik dolu admin dashboard.

## ✨ Özellikler

### 📊 Dashboard
- Gerçek zamanlı istatistikler
- Kullanıcı büyüme grafikleri
- Gelir analizi
- Özellik kullanım metrikleri
- Son aktiviteler

### 👥 Kullanıcı Yönetimi
- Kullanıcı listesi ve filtreleme
- Premium/Free kullanıcı ayrımı
- Arama ve sıralama
- CSV export
- Detaylı kullanıcı profilleri

### 📈 Analitik
- Burç dağılımı (Pie chart)
- Özellik etkileşim metrikleri
- Kullanım istatistikleri
- Trend analizi

### 💰 Gelir Yönetimi
- Premium gelir takibi
- Reklam geliri analizi
- Dönüşüm oranları
- Aylık gelir grafikleri

### 📝 İçerik Yönetimi
- Günlük yorum yönetimi
- Tarot kartları
- Rüya sembolleri
- Eğitim içerikleri

### ⚙️ Ayarlar
- Bildirim ayarları
- Güvenlik yapılandırması
- Veritabanı yönetimi
- Tema özelleştirme

## 🚀 Kurulum

### Gereksinimler
- Node.js 18+
- npm veya yarn
- Firebase projesi

### Adımlar

1. **Bağımlılıkları yükle:**
\`\`\`bash
cd zodi-admin-panel
npm install
\`\`\`

2. **Firebase yapılandırması:**
\`\`\`bash
cp .env.example .env
\`\`\`

`.env` dosyasını Firebase bilgilerinizle doldurun:
\`\`\`
VITE_FIREBASE_API_KEY=your_api_key
VITE_FIREBASE_AUTH_DOMAIN=your_project.firebaseapp.com
VITE_FIREBASE_PROJECT_ID=your_project_id
VITE_FIREBASE_STORAGE_BUCKET=your_project.appspot.com
VITE_FIREBASE_MESSAGING_SENDER_ID=your_sender_id
VITE_FIREBASE_APP_ID=your_app_id
VITE_FIREBASE_MEASUREMENT_ID=G-XXXXXXXXXX
\`\`\`

3. **Development server başlat:**
\`\`\`bash
npm run dev
\`\`\`

Panel `http://localhost:3001` adresinde çalışacak.

4. **Production build:**
\`\`\`bash
npm run build
\`\`\`

## 🎨 Teknoloji Stack

- **React 18** - UI framework
- **Vite** - Build tool
- **Tailwind CSS** - Styling
- **React Router** - Routing
- **Firebase** - Backend & Auth
- **Recharts** - Data visualization
- **Lucide React** - Icons
- **date-fns** - Date formatting

## 📱 Responsive Design

Panel tüm ekran boyutlarında mükemmel çalışır:
- Desktop (1920px+)
- Laptop (1024px+)
- Tablet (768px+)
- Mobile (320px+)

## 🔐 Güvenlik

- Firebase Authentication ile güvenli giriş
- Admin-only erişim kontrolü
- Firestore Security Rules
- Environment variables ile API key koruması

## 📊 Firestore Koleksiyonları

Panel aşağıdaki Firestore koleksiyonlarını kullanır:

\`\`\`
users/
  - name: string
  - email: string
  - zodiacSign: string
  - isPremium: boolean
  - createdAt: timestamp
  - lastActive: timestamp
  - birthDate: timestamp
  - birthPlace: string

analytics/
  - featureUsage: map
  - dailyStats: map
  - revenueData: map

content/
  - dailyHoroscopes: array
  - tarotCards: array
  - dreamSymbols: array
\`\`\`

## 🎯 Kullanım

### Giriş Yapma
1. Panel açıldığında login ekranı görünür
2. Firebase Authentication ile kayıtlı admin e-posta ve şifrenizi girin
3. Başarılı girişten sonra dashboard'a yönlendirilirsiniz

### Kullanıcı Filtreleme
- Arama çubuğundan isim veya e-posta ile arama yapın
- "Tümü", "Premium", "Ücretsiz" butonları ile filtreleyin
- CSV export ile kullanıcı listesini indirin

### Grafikleri İnceleme
- Dashboard'da genel metrikleri görün
- Analytics sayfasında detaylı analizleri inceleyin
- Revenue sayfasında gelir trendlerini takip edin

## 🛠️ Geliştirme

### Yeni Sayfa Eklemek

1. `src/pages/` altında yeni component oluşturun
2. `src/App.jsx` içinde route ekleyin
3. `src/components/Layout.jsx` içinde navigation item ekleyin

### Yeni Grafik Eklemek

Recharts kullanarak:
\`\`\`jsx
import { LineChart, Line, XAxis, YAxis, Tooltip } from 'recharts'

<ResponsiveContainer width="100%" height={300}>
  <LineChart data={yourData}>
    <XAxis dataKey="name" />
    <YAxis />
    <Tooltip />
    <Line type="monotone" dataKey="value" stroke="#9333ea" />
  </LineChart>
</ResponsiveContainer>
\`\`\`

## 📦 Build & Deploy

### Vercel Deploy
\`\`\`bash
npm run build
vercel --prod
\`\`\`

### Firebase Hosting
\`\`\`bash
npm run build
firebase deploy --only hosting
\`\`\`

### Netlify Deploy
\`\`\`bash
npm run build
netlify deploy --prod --dir=dist
\`\`\`

## 🐛 Troubleshooting

### Firebase bağlantı hatası
- `.env` dosyasının doğru yapılandırıldığından emin olun
- Firebase Console'da Web App eklendiğinden emin olun

### Grafik görünmüyor
- Firestore'da veri olduğundan emin olun
- Console'da hata mesajlarını kontrol edin

### Login çalışmıyor
- Firebase Authentication'ın aktif olduğundan emin olun
- Email/Password provider'ın etkin olduğunu kontrol edin

## 📄 Lisans

MIT License - Zodi Admin Panel

## 🤝 Katkıda Bulunma

1. Fork yapın
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Commit yapın (`git commit -m 'Add amazing feature'`)
4. Push edin (`git push origin feature/amazing-feature`)
5. Pull Request açın

## 📞 Destek

Sorularınız için:
- GitHub Issues
- Email: support@zodi.app

---

**Zodi Admin Panel** - Yıldızların gücüyle yönetin ✨
