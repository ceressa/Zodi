# Version Management (Versiyon Yönetimi)

Bu proje için otomatik versiyon yönetimi sistemi kurulmuştur.

## Otomatik Versiyon Artırma

### Yöntem 1: GitHub Actions (Otomatik)

Her `main` veya `master` branch'ine push yapıldığında, GitHub Actions otomatik olarak version code'u artırır.

**Nasıl Çalışır:**
1. Kod değişikliği yap ve commit et
2. `git push` yap
3. GitHub Actions otomatik olarak version code'u artırır
4. Yeni bir commit oluşturur: `chore: bump version to X.Y.Z+N`

**Not:** Aşağıdaki dosyalardaki değişiklikler version bump tetiklemez:
- `pubspec.yaml`
- `.github/**`
- `**.md` (Markdown dosyaları)

### Yöntem 2: Manuel Script (Windows)

PowerShell script'i kullanarak manuel olarak version artır:

```powershell
.\bump_version.ps1
```

**Çıktı:**
```
Flutter Version Bump Script
=============================

Mevcut versiyon: 1.0.0+5
Yeni versiyon: 1.0.0+6

✓ Version başarıyla güncellendi!

Şimdi şunları yapabilirsin:
  1. git add pubspec.yaml
  2. git commit -m 'chore: bump version to 1.0.0+6'
  3. git push
```

### Yöntem 3: Manuel Script (Linux/Mac)

Bash script'i kullanarak manuel olarak version artır:

```bash
./bump_version.sh
```

## Version Format

Flutter projelerinde version formatı: `MAJOR.MINOR.PATCH+BUILD`

**Örnek:** `1.0.0+5`
- `1.0.0` = Version Name (kullanıcıya gösterilen)
- `5` = Version Code (Google Play için unique identifier)

### Version Code Kuralları

- Her Google Play yüklemesi için **benzersiz** olmalı
- **Sadece artmalı**, azalmamalı
- Önceki yüklemelerle çakışmamalı

## Build Alma

Version artırdıktan sonra AAB oluştur:

```bash
flutter build appbundle --release
```

Oluşan dosya: `build/app/outputs/bundle/release/app-release.aab`

## Mevcut Version Kontrolü

Mevcut versiyonu görmek için:

```bash
grep '^version:' pubspec.yaml
```

veya

```bash
flutter --version
```

## Sorun Giderme

### "Version code already used" Hatası

Eğer Google Play'de bu hatayı alıyorsan:

1. Script'i çalıştır: `.\bump_version.ps1`
2. Yeni build al: `flutter build appbundle --release`
3. Yeni AAB'yi yükle

### Script Çalışmıyor

**Windows:**
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\bump_version.ps1
```

**Linux/Mac:**
```bash
chmod +x bump_version.sh
./bump_version.sh
```

## Version Geçmişi

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0+5 | 2026-02-14 | Email login kaldırıldı, sadece Google Sign In |
| 1.0.0+4 | 2026-02-14 | Rising sign bug fix |
| 1.0.0+3 | 2026-02-13 | Tarot images fix |
| 1.0.0+2 | 2026-02-13 | Home page UX improvements |
| 1.0.0+1 | 2026-02-13 | Initial release |

## İpuçları

1. **Her build öncesi version artır:** Google Play her seferinde yeni version code bekler
2. **Script kullan:** Manuel değiştirmekten daha güvenli
3. **Git commit'le:** Version değişikliklerini commit'le ki takip edilebilin
4. **GitHub Actions'a güven:** Push yaptığında otomatik halleder

## Gelecek Planlar

- [ ] Semantic versioning (MAJOR.MINOR.PATCH) otomasyonu
- [ ] Changelog otomatik oluşturma
- [ ] Release notes GitHub'a otomatik push
- [ ] Version tag'leri otomatik oluşturma
