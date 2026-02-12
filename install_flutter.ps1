# Flutter Kurulum Script'i
# Bu script'i PowerShell'de yönetici olarak çalıştır

Write-Host "Flutter SDK kuruluyor..." -ForegroundColor Green

# Flutter ZIP dosyası
$zipPath = "C:\src\flutter_windows_3.38.9-stable.zip"
$extractPath = "C:\src"

# Kurulum klasörünü oluştur
New-Item -ItemType Directory -Force -Path $extractPath | Out-Null

# ZIP dosyasının varlığını kontrol et
if (-Not (Test-Path $zipPath)) {
    Write-Host "HATA: Flutter ZIP dosyasi bulunamadi: $zipPath" -ForegroundColor Red
    Write-Host "Lutfen dosyanin dogru konumda oldugunu kontrol edin." -ForegroundColor Yellow
    exit 1
}

# Eski Flutter klasörünü sil (varsa)
$flutterDir = "C:\src\flutter"
if (Test-Path $flutterDir) {
    Write-Host "Eski Flutter kurulumu siliniyor..." -ForegroundColor Yellow
    Remove-Item $flutterDir -Recurse -Force
}

# ZIP'i çıkart
Write-Host "Dosyalar cikartiliyor (bu biraz zaman alabilir)..." -ForegroundColor Yellow
Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force

# PATH'e ekle
$flutterBin = "C:\src\flutter\bin"
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")

if ($currentPath -notlike "*$flutterBin*") {
    Write-Host "Flutter PATH'e ekleniyor..." -ForegroundColor Yellow
    [Environment]::SetEnvironmentVariable(
        "Path",
        "$currentPath;$flutterBin",
        "User"
    )
    Write-Host "PATH guncellendi!" -ForegroundColor Green
} else {
    Write-Host "Flutter zaten PATH'te mevcut." -ForegroundColor Green
}

Write-Host "`nKurulum tamamlandi!" -ForegroundColor Green
Write-Host "Simdi terminali kapat ve yeniden ac, sonra 'flutter doctor' komutunu calistir." -ForegroundColor Cyan
Write-Host "`nNot: Android Studio veya VS Code kurman gerekebilir." -ForegroundColor Yellow

# Flutter doctor'ı çalıştır
Write-Host "`nFlutter kontrol ediliyor..." -ForegroundColor Yellow
& "C:\src\flutter\bin\flutter.bat" doctor
