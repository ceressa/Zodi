# Tarot Card Assets Guide - Phase 1: Major Arcana

## Overview
İlk aşamada 22 Major Arcana kartını oluşturuyoruz. Kartlar:
- ✅ İngilizce isimler içerecek
- ✅ WebP formatında olacak
- ✅ Purple-gold Zodi teması
- ✅ "Zodi" branding
- ✅ Mystical starry backgrounds

## Phase 1: Major Arcana (0-21) - 22 Cards

### File Naming
Kartlar `0.webp` ile `21.webp` arasında numaralandırılacak.

### Complete List with English Names

```
0.webp   - The Fool
1.webp   - The Magician
2.webp   - The High Priestess
3.webp   - The Empress
4.webp   - The Emperor
5.webp   - The Hierophant
6.webp   - The Lovers
7.webp   - The Chariot
8.webp   - Strength
9.webp   - The Hermit
10.webp  - Wheel of Fortune
11.webp  - Justice
12.webp  - The Hanged Man
13.webp  - Death
14.webp  - Temperance
15.webp  - The Devil
16.webp  - The Tower
17.webp  - The Star
18.webp  - The Moon
19.webp  - The Sun
20.webp  - Judgement
21.webp  - The World
```

## Card Design Specifications

### Layout Requirements
Each card should have:
1. **Top Section**: "Zodi" logo/text in elegant font
2. **Center**: Card name in English (e.g., "The Fool", "The Magician")
3. **Main Image**: Symbolic artwork representing the card
4. **Background**: Mystical starry purple-gold gradient
5. **Frame**: Ornate gold decorative border

### Color Palette
- **Primary**: Deep purple (#6B46C1, #7C3AED)
- **Accent**: Gold (#FFD700, #FFA500)
- **Background**: Dark purple with stars
- **Text**: White or light gold

### Dimensions (Based on Your Design)
- **Width**: 682px (actual from your images)
- **Height**: 1024px (actual from your images)
- **Aspect Ratio**: 2:3 (0.666:1) - Perfect tarot card ratio!
- **Format**: WebP or PNG
- **Quality**: 85-90%
- **File Size**: ~400-600KB per image

### Display Sizes in App (Auto-adapted)
- **Small cards**: 170x256px (maintains 2:3 ratio)
- **Medium cards**: 200x300px (single card view)
- **Fullscreen**: 80% of screen width, max 400px (maintains aspect ratio)
- **Widget automatically adapts to any image size you provide**

### Interactive Features
- Tap on any card to view fullscreen
- Smooth fade transition
- Hero animation between views
- Tap anywhere to close fullscreen

## AI Generation Prompts

### Base Prompt Template
```
Create a mystical tarot card in vertical format:
- Card name "[CARD NAME]" prominently displayed in elegant serif font
- "Zodi" branding at the top in stylized text
- Deep purple and gold color scheme
- Ornate gold decorative frame with intricate corners
- Mystical starry background with purple nebula
- [CARD-SPECIFIC SYMBOLISM]
- Professional, high-quality digital art
- Vertical orientation (2:3 aspect ratio)
- Magical, ethereal atmosphere
```

### Individual Card Prompts

#### 0 - The Fool
```
Young figure stepping off a cliff with confidence, white rose in hand, 
small dog companion, sun in background, carefree expression, 
symbolizing new beginnings and innocence
```

#### 1 - The Magician
```
Figure with one hand pointing up, one down, infinity symbol above head,
tools on table (wand, cup, sword, pentacle), red roses and white lilies,
symbolizing manifestation and power
```

#### 2 - The High Priestess
```
Seated figure between two pillars (B and J), crescent moon crown,
scroll labeled "TORA", pomegranates on veil behind,
symbolizing intuition and mystery
```

#### 3 - The Empress
```
Regal figure on throne with cushions, crown of stars, 
wheat field in background, Venus symbol on shield,
symbolizing fertility and abundance
```

#### 4 - The Emperor
```
Authoritative figure on stone throne with ram heads,
holding ankh and orb, mountains in background,
symbolizing structure and authority
```

#### 5 - The Hierophant
```
Religious figure with triple crown, two acolytes before him,
crossed keys at feet, raised hand in blessing,
symbolizing tradition and spiritual wisdom
```

#### 6 - The Lovers
```
Man and woman beneath angel, tree of knowledge with serpent,
tree of life with flames, mountain in background,
symbolizing love and choices
```

#### 7 - The Chariot
```
Warrior in chariot pulled by black and white sphinxes,
city in background, starry canopy, crescent moons on shoulders,
symbolizing willpower and victory
```

#### 8 - Strength
```
Gentle figure closing lion's mouth with bare hands,
infinity symbol above head, flowers in background,
symbolizing courage and inner strength
```

#### 9 - The Hermit
```
Robed figure on mountain peak holding lantern with star inside,
staff in other hand, snow-covered peaks below,
symbolizing introspection and guidance
```

#### 10 - Wheel of Fortune
```
Large wheel with symbols (TARO/ROTA), sphinx on top,
snake descending, Anubis rising, four winged creatures in corners,
symbolizing cycles and destiny
```

#### 11 - Justice
```
Figure seated between pillars, holding sword and scales,
crown on head, purple veil behind,
symbolizing fairness and truth
```

#### 12 - The Hanged Man
```
Figure suspended upside down from T-shaped tree,
halo around head, serene expression, one leg crossed,
symbolizing sacrifice and new perspective
```

#### 13 - Death
```
Skeleton in black armor on white horse, black flag with white rose,
sun rising between towers, figures before the horse,
symbolizing transformation and endings
```

#### 14 - Temperance
```
Angel with wings, one foot on land one in water,
pouring water between two cups, triangle on chest, iris flowers,
symbolizing balance and moderation
```

#### 15 - The Devil
```
Horned figure on pedestal, inverted pentagram on forehead,
two chained figures below (man and woman with tails),
torch in hand, symbolizing bondage and materialism
```

#### 16 - The Tower
```
Tall tower struck by lightning, crown falling from top,
figures falling from windows, flames emerging,
symbolizing sudden change and revelation
```

#### 17 - The Star
```
Naked figure kneeling by water, pouring water from two jugs,
large star above with seven smaller stars, bird in tree,
symbolizing hope and inspiration
```

#### 18 - The Moon
```
Full moon with face, two towers, dog and wolf howling,
crayfish emerging from water, winding path between towers,
symbolizing illusion and intuition
```

#### 19 - The Sun
```
Large smiling sun, naked child on white horse,
sunflowers in background, red banner,
symbolizing success and vitality
```

#### 20 - Judgement
```
Angel Gabriel blowing trumpet, people rising from coffins,
mountains in background, cross on banner,
symbolizing rebirth and inner calling
```

#### 21 - The World
```
Dancing figure in wreath, four creatures in corners (angel, eagle, lion, bull),
purple cloth, wands in hands,
symbolizing completion and achievement
```

## Installation Steps

### 1. Create Directory
```bash
mkdir assets\tarot
```

### 2. Add First 22 Cards
Place files `0.webp` through `21.webp` in `assets/tarot/` folder.

### 3. Verify Files
```bash
dir assets\tarot
```
Should show 22 .webp files.

### 4. Run Flutter
```bash
flutter pub get
flutter run
```

## WebP Conversion (if needed)

If you have PNG files and need to convert to WebP:

### Using Online Tools
- [Squoosh.app](https://squoosh.app/) - Google's image optimizer
- [CloudConvert](https://cloudconvert.com/png-to-webp)

### Using Command Line (if you have cwebp installed)
```bash
cwebp -q 85 input.png -o output.webp
```

## Testing Checklist

After adding the 22 cards:
- [ ] All files named correctly (0.webp to 21.webp)
- [ ] Files are in `assets/tarot/` folder
- [ ] Run `flutter pub get`
- [ ] Open Tarot screen in app
- [ ] Verify cards display correctly
- [ ] Check flip animation works
- [ ] Test both daily and three-card spread

## Next Phases

### Phase 2: Wands (22-35) - 14 cards
### Phase 3: Cups (36-49) - 14 cards  
### Phase 4: Swords (50-63) - 14 cards
### Phase 5: Pentacles (64-77) - 14 cards

## Current Status

✅ Code updated for .webp format
✅ English names added to TarotData
✅ Widget supports webp with fallback
✅ Detailed prompts for all 22 Major Arcana cards
⏳ Generate/obtain 22 Major Arcana cards
⏳ Place in assets/tarot/ folder

### Wands/Asalar (22-35) - 14 cards
```
22.png  - Asaların Ası (Ace of Wands)
23.png  - Asaların İkilisi (Two of Wands)
24.png  - Asaların Üçlüsü (Three of Wands)
25.png  - Asaların Dörtlüsü (Four of Wands)
26.png  - Asaların Beşlisi (Five of Wands)
27.png  - Asaların Altılısı (Six of Wands)
28.png  - Asaların Yedilisi (Seven of Wands)
29.png  - Asaların Sekizlisi (Eight of Wands)
30.png  - Asaların Dokuzlusu (Nine of Wands)
31.png  - Asaların Onlusu (Ten of Wands)
32.png  - Asaların Prensi (Page of Wands)
33.png  - Asaların Şövalyesi (Knight of Wands)
34.png  - Asaların Kraliçesi (Queen of Wands)
35.png  - Asaların Kralı (King of Wands)
```

### Cups/Kadehler (36-49) - 14 cards
```
36.png  - Kadehlerin Ası (Ace of Cups)
37.png  - Kadehlerin İkilisi (Two of Cups)
38.png  - Kadehlerin Üçlüsü (Three of Cups)
39.png  - Kadehlerin Dörtlüsü (Four of Cups)
40.png  - Kadehlerin Beşlisi (Five of Cups)
41.png  - Kadehlerin Altılısı (Six of Cups)
42.png  - Kadehlerin Yedilisi (Seven of Cups)
43.png  - Kadehlerin Sekizlisi (Eight of Cups)
44.png  - Kadehlerin Dokuzlusu (Nine of Cups)
45.png  - Kadehlerin Onlusu (Ten of Cups)
46.png  - Kadehlerin Prensi (Page of Cups)
47.png  - Kadehlerin Şövalyesi (Knight of Cups)
48.png  - Kadehlerin Kraliçesi (Queen of Cups)
49.png  - Kadehlerin Kralı (King of Cups)
```

### Swords/Kılıçlar (50-63) - 14 cards
```
50.png  - Kılıçların Ası (Ace of Swords)
51.png  - Kılıçların İkilisi (Two of Swords)
52.png  - Kılıçların Üçlüsü (Three of Swords)
53.png  - Kılıçların Dörtlüsü (Four of Swords)
54.png  - Kılıçların Beşlisi (Five of Swords)
55.png  - Kılıçların Altılısı (Six of Swords)
56.png  - Kılıçların Yedilisi (Seven of Swords)
57.png  - Kılıçların Sekizlisi (Eight of Swords)
58.png  - Kılıçların Dokuzlusu (Nine of Swords)
59.png  - Kılıçların Onlusu (Ten of Swords)
60.png  - Kılıçların Prensi (Page of Swords)
61.png  - Kılıçların Şövalyesi (Knight of Swords)
62.png  - Kılıçların Kraliçesi (Queen of Swords)
63.png  - Kılıçların Kralı (King of Swords)
```

### Pentacles/Tılsımlar (64-77) - 14 cards
```
64.png  - Tılsımların Ası (Ace of Pentacles)
65.png  - Tılsımların İkilisi (Two of Pentacles)
66.png  - Tılsımların Üçlüsü (Three of Pentacles)
67.png  - Tılsımların Dörtlüsü (Four of Pentacles)
68.png  - Tılsımların Beşlisi (Five of Pentacles)
69.png  - Tılsımların Altılısı (Six of Pentacles)
70.png  - Tılsımların Yedilisi (Seven of Pentacles)
71.png  - Tılsımların Sekizlisi (Eight of Pentacles)
72.png  - Tılsımların Dokuzlusu (Nine of Pentacles)
73.png  - Tılsımların Onlusu (Ten of Pentacles)
74.png  - Tılsımların Prensi (Page of Pentacles)
75.png  - Tılsımların Şövalyesi (Knight of Pentacles)
76.png  - Tılsımların Kraliçesi (Queen of Pentacles)
77.png  - Tılsımların Kralı (King of Pentacles)
```

## Installation Steps

### 1. Create Directory
```bash
mkdir assets\tarot
```

### 2. Add All Card Images
Place all 78 PNG files (0.png through 77.png) in the `assets/tarot/` folder.

### 3. Run Flutter Command
```bash
flutter pub get
```

### 4. Test the App
```bash
flutter run
```

## Image Specifications

### Recommended Dimensions
- **Width**: 600-800px
- **Height**: 1000-1200px
- **Aspect Ratio**: 2:3 (vertical)
- **Format**: PNG with transparency (if needed)
- **File Size**: Keep under 500KB per image for optimal performance

### Design Consistency
All cards should maintain:
- Same frame style
- Same "Zodi" logo placement
- Same color scheme (purple-gold)
- Same background style (starry/mystical)
- Same border/ornament design

## How It Works in the App

1. **Card Selection**: The app uses deterministic selection based on userId + date
2. **Display**: Cards show with flip animation
3. **Fallback**: If image not found, shows colored icon placeholder
4. **Reversed Cards**: Same image, marked with "Ters" badge

## AI Generation Tips (if using AI)

If you're using AI to generate the remaining 72 cards, use prompts like:

```
Create a tarot card in vertical format with:
- "Zodi" text at the top in elegant font
- Purple and gold color scheme
- Ornate gold frame with decorative corners
- Mystical starry background
- [Card name] symbolism in the center
- Professional, mystical aesthetic
- High quality, detailed artwork
```

## Where to Get Cards

### Option 1: AI Generation (Recommended)
- **Midjourney**: Best quality, consistent style
- **DALL-E 3**: Good for specific requests
- **Stable Diffusion**: Free, requires more prompting

### Option 2: Commission an Artist
- Fiverr, Upwork for custom tarot deck
- Ensure you get commercial rights

### Option 3: Stock Assets + Customization
- Purchase tarot card templates
- Add Zodi branding and recolor

## Current Status

✅ Code is ready and configured
✅ pubspec.yaml updated
✅ Widget supports real images with fallback
✅ 6 sample cards designed (shown by user)
⏳ Need 72 more cards in same style

## Next Action

Generate or obtain the remaining 72 cards, then place them in `assets/tarot/` with the correct numbering (0-77).
