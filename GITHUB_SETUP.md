# GitHub Repository Setup Guide

## 🚀 GitHub'da Repo Oluşturma

### Adım 1: GitHub'da Yeni Repo Oluştur

1. https://github.com/new adresine git
2. Repository name: `zodi-flutter`
3. Description: `🌟 AI-Powered Astrology App - Yıldızlar senin için konuşuyor ✨`
4. Visibility: **Private** (veya Public)
5. **Initialize this repository with** seçeneklerini BOŞALT (README, .gitignore, license ekleme)
6. "Create repository" butonuna tıkla

### Adım 2: Local Repo'yu GitHub'a Bağla

Terminal'de şu komutları çalıştır:

```bash
# Remote ekle (USERNAME yerine GitHub kullanıcı adını yaz)
git remote add origin https://github.com/USERNAME/zodi-flutter.git

# Branch adını main yap (opsiyonel)
git branch -M main

# İlk push
git push -u origin main
```

### Adım 3: Repository Ayarları

#### About Bölümü
1. Repo sayfasında sağ üstteki ⚙️ (Settings) ikonuna tıkla
2. Description: `🌟 AI-Powered Astrology App - Yıldızlar senin için konuşuyor ✨`
3. Website: `https://zodi.app` (varsa)
4. Topics ekle:
   - `flutter`
   - `dart`
   - `astrology`
   - `ai`
   - `gemini`
   - `firebase`
   - `mobile-app`
   - `turkish`
   - `tarot`
   - `horoscope`

#### Branch Protection (Opsiyonel)
Settings → Branches → Add rule:
- Branch name pattern: `main`
- ✅ Require pull request reviews before merging
- ✅ Require status checks to pass before merging

#### Secrets (API Keys için)
Settings → Secrets and variables → Actions → New repository secret:
- Name: `GEMINI_API_KEY`
- Value: [API anahtarınız]

### Adım 4: GitHub Actions (CI/CD) - Opsiyonel

`.github/workflows/flutter.yml` dosyası oluştur:

```yaml
name: Flutter CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3
    
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.0.0'
        channel: 'stable'
    
    - name: Install dependencies
      run: flutter pub get
    
    - name: Analyze code
      run: flutter analyze
    
    - name: Run tests
      run: flutter test
    
    - name: Build APK
      run: flutter build apk --release
```

## 📝 Sonraki Adımlar

### 1. README'yi Güncelle
- Ekran görüntüleri ekle (`docs/screenshots/` klasörüne)
- GitHub username'i güncelle
- İletişim bilgilerini güncelle

### 2. Issues Template Oluştur
`.github/ISSUE_TEMPLATE/bug_report.md`:
```markdown
---
name: Bug Report
about: Create a report to help us improve
title: '[BUG] '
labels: bug
assignees: ''
---

**Describe the bug**
A clear and concise description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Go to '...'
2. Click on '....'
3. See error

**Expected behavior**
A clear and concise description of what you expected to happen.

**Screenshots**
If applicable, add screenshots to help explain your problem.

**Device (please complete the following information):**
 - Device: [e.g. Samsung Galaxy S21]
 - OS: [e.g. Android 12]
 - App Version: [e.g. 1.0.0]
```

### 3. Pull Request Template
`.github/pull_request_template.md`:
```markdown
## Description
Please include a summary of the change and which issue is fixed.

Fixes # (issue)

## Type of change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Checklist:
- [ ] My code follows the style guidelines
- [ ] I have performed a self-review
- [ ] I have commented my code
- [ ] I have made corresponding changes to the documentation
- [ ] My changes generate no new warnings
- [ ] I have added tests that prove my fix is effective
- [ ] New and existing unit tests pass locally
```

### 4. GitHub Pages (Dokümantasyon için)
Settings → Pages:
- Source: Deploy from a branch
- Branch: `main` / `docs` folder

### 5. Releases
1. Repo sayfasında "Releases" → "Create a new release"
2. Tag: `v1.0.0`
3. Title: `🌟 Zodi v1.0.0 - Initial Release`
4. Description: CHANGELOG.md'den kopyala
5. APK dosyasını ekle (opsiyonel)

## 🔒 Güvenlik

### .env Dosyası
`.env` dosyası `.gitignore`'da olduğundan commit edilmeyecek. 
Yeni geliştiriciler için `.env.example` oluştur:

```bash
# .env.example
GEMINI_API_KEY=your_api_key_here
```

### Firebase Credentials
`google-services.json` ve `GoogleService-Info.plist` dosyaları 
`.gitignore`'da olduğundan commit edilmeyecek.

## 📊 GitHub Badges

README.md'ye eklenebilecek badge'ler:

```markdown
![Build Status](https://github.com/USERNAME/zodi-flutter/workflows/Flutter%20CI/badge.svg)
![License](https://img.shields.io/github/license/USERNAME/zodi-flutter)
![Stars](https://img.shields.io/github/stars/USERNAME/zodi-flutter)
![Forks](https://img.shields.io/github/forks/USERNAME/zodi-flutter)
![Issues](https://img.shields.io/github/issues/USERNAME/zodi-flutter)
![Last Commit](https://img.shields.io/github/last-commit/USERNAME/zodi-flutter)
```

## 🎉 Tamamlandı!

Repo'nuz artık GitHub'da! 🚀

Repo URL: `https://github.com/USERNAME/zodi-flutter`
