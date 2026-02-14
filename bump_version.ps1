# Flutter Version Bump Script
Write-Host "Flutter Version Bump Script" -ForegroundColor Cyan
Write-Host "=============================" -ForegroundColor Cyan
Write-Host ""

$pubspecPath = "pubspec.yaml"
if (-not (Test-Path $pubspecPath)) {
    Write-Host "HATA: pubspec.yaml bulunamadi!" -ForegroundColor Red
    exit 1
}

$lines = Get-Content $pubspecPath
$updated = $false
$newLines = @()

foreach ($line in $lines) {
    if ($line -match '^version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)') {
        $major = $matches[1]
        $minor = $matches[2]
        $patch = $matches[3]
        $buildNumber = [int]$matches[4]
        
        $currentVersion = "$major.$minor.$patch+$buildNumber"
        Write-Host "Mevcut versiyon: $currentVersion" -ForegroundColor Yellow
        
        $newBuildNumber = $buildNumber + 1
        $newVersion = "$major.$minor.$patch+$newBuildNumber"
        
        Write-Host "Yeni versiyon: $newVersion" -ForegroundColor Green
        
        $newLines += "version: $newVersion"
        $updated = $true
    } else {
        $newLines += $line
    }
}

if ($updated) {
    $newLines | Set-Content -Path $pubspecPath
    
    Write-Host ""
    Write-Host "Basarili!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Simdi yapabilirsin:" -ForegroundColor Cyan
    Write-Host "  git add pubspec.yaml" -ForegroundColor White
    Write-Host "  git commit -m 'chore: bump version to $newVersion'" -ForegroundColor White
    Write-Host "  git push" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host "HATA: Version formati bulunamadi!" -ForegroundColor Red
    exit 1
}
