#!/bin/bash
# Flutter Version Bump Script
# Bu script pubspec.yaml'daki version code'u otomatik olarak artırır

echo -e "\033[36mFlutter Version Bump Script\033[0m"
echo -e "\033[36m=============================\033[0m"
echo ""

# pubspec.yaml dosyasını kontrol et
PUBSPEC="pubspec.yaml"
if [ ! -f "$PUBSPEC" ]; then
    echo -e "\033[31mHATA: pubspec.yaml bulunamadı!\033[0m"
    exit 1
fi

# Mevcut versiyonu bul
CURRENT_VERSION=$(grep '^version:' "$PUBSPEC" | sed 's/version: //')

if [[ $CURRENT_VERSION =~ ^([0-9]+\.[0-9]+\.[0-9]+)\+([0-9]+)$ ]]; then
    VERSION_NAME="${BASH_REMATCH[1]}"
    VERSION_CODE="${BASH_REMATCH[2]}"
    
    echo -e "\033[33mMevcut versiyon: $CURRENT_VERSION\033[0m"
    
    # Version code'u artır
    NEW_VERSION_CODE=$((VERSION_CODE + 1))
    NEW_VERSION="${VERSION_NAME}+${NEW_VERSION_CODE}"
    
    echo -e "\033[32mYeni versiyon: $NEW_VERSION\033[0m"
    
    # Dosyayı güncelle
    sed -i.bak "s/^version: .*/version: $NEW_VERSION/" "$PUBSPEC"
    rm "${PUBSPEC}.bak"
    
    echo ""
    echo -e "\033[32m✓ Version başarıyla güncellendi!\033[0m"
    echo ""
    echo -e "\033[36mŞimdi şunları yapabilirsin:\033[0m"
    echo -e "  1. git add pubspec.yaml"
    echo -e "  2. git commit -m 'chore: bump version to $NEW_VERSION'"
    echo -e "  3. git push"
    echo ""
    echo -e "\033[36mveya\033[0m"
    echo ""
    echo -e "  flutter build appbundle --release"
    echo ""
    
else
    echo -e "\033[31mHATA: Version formatı bulunamadı!\033[0m"
    echo -e "\033[33mBeklenen format: version: X.Y.Z+N\033[0m"
    exit 1
fi
