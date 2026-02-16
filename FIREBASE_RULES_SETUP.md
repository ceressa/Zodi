# 🔥 Firebase Security Rules Kurulumu

## Sorun
Admin panel "Missing or insufficient permissions" hatası veriyor çünkü Firestore Security Rules varsayılan olarak tüm erişimi engelliyor.

## Çözüm

### Yöntem 1: Firebase Console (Hızlı)

1. **Firebase Console'a git:** https://console.firebase.google.com
2. **Projeyi seç:** zodi-cf6b7
3. **Firestore Database** → **Rules** sekmesine git
4. Aşağıdaki kuralları yapıştır:

\`\`\`
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    
    // Users collection - Herkes okuyabilir
    match /users/{userId} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Analytics collection
    match /analytics/{document=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    // Content collection
    match /content/{document=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    // Feedback collection
    match /feedback/{document=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    // User history
    match /user_history/{userId} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
\`\`\`

5. **Publish** butonuna tıkla
6. Admin paneli yenile

### Yöntem 2: Firebase CLI (Otomatik)

\`\`\`bash
# Firebase CLI yükle (eğer yoksa)
npm install -g firebase-tools

# Login
firebase login

# Deploy rules
firebase deploy --only firestore:rules
\`\`\`

## Güvenlik Notları

⚠️ **Önemli:** Bu kurallar development için uygundur. Production'da:

1. **Admin Authentication ekle:**
\`\`\`
allow read: if request.auth != null && request.auth.token.admin == true;
\`\`\`

2. **IP whitelist kullan** (Firebase Console → Authentication → Settings)

3. **Rate limiting ekle** (App Check kullan)

## Test

Kurallar deploy edildikten sonra:
1. Admin paneli yenile (Ctrl+R)
2. Dashboard'da kullanıcı sayısını görmeli
3. Users sayfasında kullanıcı listesini görmeli
4. Analytics'te burç dağılımını görmeli

## Sorun Devam Ederse

Console'da hala hata varsa:
1. Firebase Console → Firestore → Rules → Simulator ile test et
2. Browser console'da tam hata mesajını kontrol et
3. Firebase project ID'nin doğru olduğundan emin ol (.env dosyası)

---

**Şu anda yapman gereken:** Firebase Console'a git ve yukarıdaki kuralları yapıştır! 🚀
