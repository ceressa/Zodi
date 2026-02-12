# Design Document: Premium Features Enhancement

## Overview

This design specifies the architecture and implementation approach for 10 premium features that enhance the Zodi astrology application. The design leverages existing Flutter infrastructure, Firebase backend, and Gemini AI services while introducing new components for notifications, natal charts, tarot, gamification, subscriptions, and social sharing.

The design follows a modular approach where each feature is implemented as a service or provider that integrates with existing app architecture. All features maintain consistency with Zodi's casual Turkish personality and support the three-tier subscription model (Free, Premium, VIP).

## Architecture

### High-Level Component Structure

```
┌─────────────────────────────────────────────────────────────┐
│                     Flutter UI Layer                         │
│  (Screens, Widgets, Providers)                              │
└────────────────┬────────────────────────────────────────────┘
                 │
┌────────────────┴────────────────────────────────────────────┐
│                   Service Layer                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │ Notification │  │ Natal Chart  │  │    Tarot     │     │
│  │   Service    │  │   Service    │  │   Service    │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │ Achievement  │  │    Streak    │  │ Lucky Items  │     │
│  │   Service    │  │   Service    │  │   Service    │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │    Theme     │  │    Story     │  │ Subscription │     │
│  │   Service    │  │  Generator   │  │   Manager    │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│  ┌──────────────┐                                           │
│  │   Referral   │                                           │
│  │   Service    │                                           │
│  └──────────────┘                                           │
└────────────────┬────────────────────────────────────────────┘
                 │
┌────────────────┴────────────────────────────────────────────┐
│              Existing Infrastructure                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │   Firebase   │  │    Gemini    │  │   Storage    │     │
│  │   Service    │  │   Service    │  │   Service    │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
└─────────────────────────────────────────────────────────────┘
```

### Service Integration Pattern

Each new service follows this pattern:
1. **Initialization**: Service initializes with dependencies (Firebase, Gemini, Storage)
2. **Data Access**: Service reads/writes data through Firebase Service
3. **AI Generation**: Service requests content from Gemini Service when needed
4. **State Management**: Service notifies providers of state changes
5. **Persistence**: Service uses Storage Service for local caching

### Subscription Tier Gating

All premium features check subscription tier before execution:

```dart
if (!subscriptionManager.hasAccess(FeatureTier.PREMIUM)) {
  showPremiumUpgradeDialog();
  return;
}
```

Tier hierarchy:
- **Free**: Basic horoscope, limited features
- **Premium**: All features except VIP exclusives, no ads
- **VIP**: All features, priority support, exclusive content

## Components and Interfaces

### 1. Notification Service

**Purpose**: Schedule and deliver personalized daily horoscope notifications

**Interface**:
```dart
class NotificationService {
  Future<bool> requestPermissions()
  Future<void> scheduleDaily(TimeOfDay time, String zodiacSign)
  Future<void> cancelAll()
  Future<void> updateNotificationContent(String zodiacSign)
  Future<String> generateNotificationPreview(String zodiacSign)
}
```

**Key Methods**:
- `requestPermissions()`: Requests system notification permissions using flutter_local_notifications
- `scheduleDaily()`: Schedules repeating daily notification at specified time
- `generateNotificationPreview()`: Calls Gemini to create short preview text (50-80 characters)
- `updateNotificationContent()`: Updates scheduled notifications when user changes zodiac

**Dependencies**:
- `flutter_local_notifications` package for local notifications
- `timezone` package for accurate scheduling
- Gemini Service for preview generation
- Firebase Service for user preferences

**Data Flow**:
1. User sets notification time in settings
2. Service requests permissions if not granted
3. Service schedules daily notification with timezone
4. At trigger time, service generates preview via Gemini
5. Notification displays with zodiac icon and preview
6. Tap opens app to daily horoscope screen

### 2. Natal Chart Service

**Purpose**: Calculate and visualize complete birth charts with planetary positions

**Interface**:
```dart
class NatalChartService {
  Future<NatalChart> calculateChart(DateTime birth, GeoLocation location)
  Future<Map<Planet, Position>> calculatePlanetaryPositions(DateTime birth)
  Future<List<House>> calculateHouses(DateTime birth, GeoLocation location)
  Future<String> generateInterpretation(NatalChart chart)
  Future<void> saveChart(String userId, NatalChart chart)
}
```

**Key Methods**:
- `calculateChart()`: Main entry point, orchestrates full chart calculation
- `calculatePlanetaryPositions()`: Uses Swiss Ephemeris for accurate planetary positions
- `calculateHouses()`: Calculates 12 houses using Placidus system
- `generateInterpretation()`: Calls Gemini with chart data for personalized analysis

**Dependencies**:
- `sweph` package for Swiss Ephemeris calculations
- `geocoding` package for location coordinates
- Gemini Service for interpretation
- Firebase Service for chart storage

**Data Models**:
```dart
class NatalChart {
  DateTime birthDateTime
  GeoLocation birthLocation
  Map<Planet, Position> planets
  List<House> houses
  List<Aspect> aspects
  String interpretation
}

class Position {
  double longitude  // 0-360 degrees
  ZodiacSign sign
  int degree        // 0-29
  int minute        // 0-59
  int house         // 1-12
}

class House {
  int number        // 1-12
  double cusp       // Degree of house cusp
  ZodiacSign sign
}

class Aspect {
  Planet planet1
  Planet planet2
  AspectType type   // Conjunction, Trine, Square, etc.
  double orb        // Degrees of exactness
}
```

**Calculation Algorithm**:
1. Convert birth date/time to Julian Day
2. Calculate planetary positions using Swiss Ephemeris
3. Determine zodiac signs for each planet
4. Calculate house cusps using Placidus system
5. Assign planets to houses
6. Calculate major aspects between planets
7. Generate interpretation via Gemini with all data

### 3. Tarot Service

**Purpose**: Generate daily tarot readings integrated with horoscope

**Interface**:
```dart
class TarotService {
  Future<TarotReading> getDailyCard(String userId, String zodiacSign)
  Future<TarotReading> getThreeCardSpread(String userId, String zodiacSign)
  Future<String> generateInterpretation(TarotCard card, String zodiacSign)
  Future<void> saveReading(String userId, TarotReading reading)
}
```

**Key Methods**:
- `getDailyCard()`: Selects one card using seeded random based on date + userId
- `getThreeCardSpread()`: Selects three cards for past/present/future
- `generateInterpretation()`: Calls Gemini with card meaning + zodiac context

**Data Models**:
```dart
class TarotReading {
  DateTime date
  List<TarotCard> cards
  String interpretation
  String zodiacSign
}

class TarotCard {
  String name
  int number
  TarotSuit suit
  bool reversed
  String imageUrl
  String basicMeaning
}

enum TarotSuit {
  majorArcana,
  wands,
  cups,
  swords,
  pentacles
}
```

**Card Selection Algorithm**:
```dart
// Deterministic selection based on date + user
String seed = "${userId}_${DateFormat('yyyyMMdd').format(DateTime.now())}"
Random rng = Random(seed.hashCode)
int cardIndex = rng.nextInt(78)
bool reversed = rng.nextBool()
```

**Gemini Integration**:
- Prompt includes: card name, suit, upright/reversed, basic meaning, user's zodiac
- Response format: Turkish text, Zodi personality, 150-200 words
- Combines tarot symbolism with astrological context

### 4. Achievement Service

**Purpose**: Track user actions and award badges/levels

**Interface**:
```dart
class AchievementService {
  Future<void> trackAction(String userId, AchievementAction action)
  Future<List<Badge>> checkAchievements(String userId)
  Future<void> awardBadge(String userId, Badge badge)
  Future<int> calculateLevel(int experiencePoints)
  Future<UserProgress> getUserProgress(String userId)
}
```

**Key Methods**:
- `trackAction()`: Records user action and checks if achievements unlocked
- `checkAchievements()`: Evaluates all achievement criteria against user data
- `awardBadge()`: Awards badge and shows celebration animation
- `calculateLevel()`: Converts XP to level using exponential curve

**Data Models**:
```dart
class UserProgress {
  int experiencePoints
  int level
  List<Badge> badges
  Map<AchievementAction, int> actionCounts
}

class Badge {
  String id
  String name
  String description
  String iconUrl
  BadgeRarity rarity
  DateTime earnedAt
}

enum AchievementAction {
  viewDailyHoroscope,
  checkCompatibility,
  readDreamInterpretation,
  viewNatalChart,
  drawTarotCard,
  maintainStreak,
  referFriend,
  shareContent
}
```

**Achievement Definitions**:
```dart
final achievements = [
  Achievement(
    id: 'first_steps',
    name: 'İlk Adımlar',
    description: 'İlk burç yorumunu oku',
    criteria: (counts) => counts[AchievementAction.viewDailyHoroscope] >= 1,
    xpReward: 10
  ),
  Achievement(
    id: 'week_warrior',
    name: 'Hafta Savaşçısı',
    description: '7 gün üst üste giriş yap',
    criteria: (counts) => counts[AchievementAction.maintainStreak] >= 7,
    xpReward: 50
  ),
  Achievement(
    id: 'tarot_master',
    name: 'Tarot Ustası',
    description: '50 tarot kartı çek',
    criteria: (counts) => counts[AchievementAction.drawTarotCard] >= 50,
    xpReward: 100
  ),
  // ... more achievements
]
```

**Level Calculation**:
```dart
int calculateLevel(int xp) {
  // Exponential curve: level = floor(sqrt(xp / 100))
  return (sqrt(xp / 100)).floor() + 1
}

int xpForNextLevel(int currentLevel) {
  return (currentLevel * currentLevel) * 100
}
```

### 5. Streak Service

**Purpose**: Track consecutive daily usage and maintain statistics

**Interface**:
```dart
class StreakService {
  Future<void> recordDailyVisit(String userId)
  Future<StreakData> getStreakData(String userId)
  Future<bool> useStreakProtection(String userId)
  Future<UserStatistics> getStatistics(String userId)
}
```

**Key Methods**:
- `recordDailyVisit()`: Called on app open, updates streak if new day
- `getStreakData()`: Returns current streak, longest streak, protection status
- `useStreakProtection()`: Activates protection to save streak (Premium only)

**Data Models**:
```dart
class StreakData {
  int currentStreak
  int longestStreak
  DateTime lastVisit
  bool protectionActive
  DateTime protectionUsedDate
}

class UserStatistics {
  int totalDaysActive
  int currentStreak
  int longestStreak
  Map<String, int> featureUsageCounts
  DateTime firstUseDate
  DateTime lastUseDate
}
```

**Streak Logic**:
```dart
Future<void> recordDailyVisit(String userId) async {
  StreakData data = await getStreakData(userId)
  DateTime today = DateTime.now().startOfDay
  DateTime lastVisit = data.lastVisit.startOfDay
  
  int daysDiff = today.difference(lastVisit).inDays
  
  if (daysDiff == 0) {
    // Same day, no change
    return
  } else if (daysDiff == 1) {
    // Consecutive day, increment streak
    data.currentStreak++
    if (data.currentStreak > data.longestStreak) {
      data.longestStreak = data.currentStreak
    }
  } else if (daysDiff == 2 && data.protectionActive) {
    // Missed one day but protection active
    data.currentStreak++
    data.protectionActive = false
  } else {
    // Streak broken
    data.currentStreak = 1
  }
  
  data.lastVisit = today
  await saveStreakData(userId, data)
  
  // Award achievement if milestone reached
  if (data.currentStreak % 7 == 0) {
    await achievementService.trackAction(userId, AchievementAction.maintainStreak)
  }
}
```

### 6. Lucky Items Service

**Purpose**: Generate daily lucky numbers, colors, and stones

**Interface**:
```dart
class LuckyItemsService {
  Future<LuckyItems> getDailyLuckyItems(String zodiacSign)
  Future<List<int>> generateLuckyNumbers(String zodiacSign, DateTime date)
  Future<List<LuckyColor>> generateLuckyColors(String zodiacSign, DateTime date)
  Future<List<LuckyStone>> generateLuckyStones(String zodiacSign, DateTime date)
}
```

**Key Methods**:
- `getDailyLuckyItems()`: Main entry point, generates all lucky items for the day
- `generateLuckyNumbers()`: Creates 3-5 lucky numbers via Gemini
- `generateLuckyColors()`: Selects colors based on zodiac + planetary transits
- `generateLuckyStones()`: Recommends crystals aligned with daily energy

**Data Models**:
```dart
class LuckyItems {
  DateTime date
  String zodiacSign
  List<int> numbers
  List<LuckyColor> colors
  List<LuckyStone> stones
  String explanation
}

class LuckyColor {
  String name
  String hexCode
  String reason
}

class LuckyStone {
  String name
  String properties
  String reason
}
```

**Generation Strategy**:
- Numbers: Gemini generates based on numerology + zodiac
- Colors: Combination of zodiac element colors + daily planetary influences
- Stones: Gemini selects from curated list based on astrological energy

**Gemini Prompt Structure**:
```
Sen Zodi'sin, samimi bir astroloji asistanısın.
Bugün {date} için {zodiacSign} burcu için şanslı öğeler belirle:

1. 3-5 şanslı sayı (1-99 arası)
2. 2-3 şanslı renk (hex kodu ile)
3. 2-3 şanslı taş/kristal

Her öğe için kısa açıklama yaz. Samimi ve eğlenceli ol.

JSON formatında döndür:
{
  "numbers": [int],
  "colors": [{"name": str, "hex": str, "reason": str}],
  "stones": [{"name": str, "properties": str, "reason": str}]
}
```

### 7. Theme Service

**Purpose**: Manage zodiac-themed visual customization

**Interface**:
```dart
class ThemeService {
  ThemeData getZodiacTheme(String zodiacSign)
  Future<void> applyTheme(String userId, ThemeConfig config)
  Future<void> enableAnimatedBackground(String userId, AnimationType type)
  Future<void> setCustomFont(String userId, String fontFamily)
  ThemeConfig getUserTheme(String userId)
}
```

**Key Methods**:
- `getZodiacTheme()`: Returns ThemeData with zodiac-specific colors
- `applyTheme()`: Applies theme and persists to Firebase
- `enableAnimatedBackground()`: Activates animated background (Premium)
- `setCustomFont()`: Changes horoscope text font (VIP)

**Data Models**:
```dart
class ThemeConfig {
  String zodiacSign
  ColorScheme colorScheme
  AnimationType backgroundAnimation
  String fontFamily
  bool darkMode
}

enum AnimationType {
  none,
  particles,
  gradient,
  constellation,
  zodiacSymbol
}
```

**Zodiac Color Schemes**:
```dart
final zodiacColors = {
  'aries': ColorScheme(
    primary: Color(0xFFE74C3C),
    secondary: Color(0xFFFF6B6B),
    accent: Color(0xFFFFD93D)
  ),
  'taurus': ColorScheme(
    primary: Color(0xFF27AE60),
    secondary: Color(0xFF6BCF7F),
    accent: Color(0xFFFFE66D)
  ),
  // ... all 12 signs
}
```

**Animated Background Implementation**:
- Particles: Custom painter with moving dots
- Gradient: Animated gradient shader
- Constellation: Connected stars animation
- Zodiac Symbol: Subtle rotating symbol watermark

### 8. Story Generator Service

**Purpose**: Create shareable Instagram-style story images

**Interface**:
```dart
class StoryGeneratorService {
  Future<Uint8List> generateStory(StoryContent content, StoryTemplate template)
  Future<void> shareToSocial(Uint8List image)
  Future<void> saveToGallery(Uint8List image)
  List<StoryTemplate> getAvailableTemplates()
}
```

**Key Methods**:
- `generateStory()`: Creates 1080x1920 image with content and branding
- `shareToSocial()`: Uses platform share sheet
- `saveToGallery()`: Saves to device photo library

**Data Models**:
```dart
class StoryContent {
  String zodiacSign
  String mainText
  String? subtitle
  ThemeConfig theme
  bool includeWatermark
}

class StoryTemplate {
  String id
  String name
  String previewUrl
  TemplateLayout layout
}

enum TemplateLayout {
  centered,
  topHeavy,
  bottomHeavy,
  split,
  minimal
}
```

**Image Generation Process**:
1. Create canvas (1080x1920)
2. Apply background (gradient or solid color)
3. Add zodiac symbol watermark
4. Render main text with proper typography
5. Add Zodi branding (logo + name)
6. Apply watermark if free user
7. Encode to PNG bytes

**Text Rendering**:
- Max 280 characters for readability
- Auto-sizing based on text length
- Proper line breaks and spacing
- High contrast for readability
- Custom fonts for Premium/VIP

### 9. Subscription Manager

**Purpose**: Handle multi-tier subscription logic and in-app purchases

**Interface**:
```dart
class SubscriptionManager {
  Future<void> initialize()
  Future<List<SubscriptionTier>> getAvailableTiers()
  Future<bool> purchaseSubscription(String tierId)
  Future<bool> restorePurchases()
  bool hasAccess(FeatureTier requiredTier)
  Future<SubscriptionStatus> getSubscriptionStatus(String userId)
  Future<void> handleSubscriptionExpiry(String userId)
}
```

**Key Methods**:
- `initialize()`: Sets up in-app purchase connection
- `purchaseSubscription()`: Initiates platform purchase flow
- `restorePurchases()`: Restores previous purchases
- `hasAccess()`: Checks if user's tier grants access to feature

**Data Models**:
```dart
class SubscriptionTier {
  String id
  String name
  String description
  double price
  String currency
  Duration duration
  List<String> features
  FeatureTier tier
}

enum FeatureTier {
  free,
  premium,
  vip
}

class SubscriptionStatus {
  FeatureTier currentTier
  DateTime? expiryDate
  bool autoRenew
  String? platform
  String? transactionId
}
```

**Tier Definitions**:
```dart
final tiers = [
  SubscriptionTier(
    id: 'premium_monthly',
    name: 'Premium Aylık',
    price: 49.99,
    duration: Duration(days: 30),
    tier: FeatureTier.premium,
    features: [
      'Reklamsız deneyim',
      'Doğum haritası',
      'Tarot okumalar',
      'Şanslı renkler ve taşlar',
      'Tema özelleştirme',
      'Sınırsız uyumluluk',
    ]
  ),
  SubscriptionTier(
    id: 'vip_monthly',
    name: 'VIP Aylık',
    price: 99.99,
    duration: Duration(days: 30),
    tier: FeatureTier.vip,
    features: [
      'Tüm Premium özellikler',
      'Özel fontlar',
      'Öncelikli destek',
      'Özel içerik',
      'Filigransız paylaşım',
      'Streak koruması',
    ]
  ),
]
```

**Purchase Flow**:
1. User selects tier in Premium screen
2. Manager initiates platform purchase
3. Platform handles payment
4. On success, verify transaction
5. Update Firebase with subscription data
6. Notify user and refresh UI
7. Schedule expiry check

**Platform Integration**:
- iOS: StoreKit via `in_app_purchase` package
- Android: Google Play Billing via `in_app_purchase` package
- Verification: Server-side receipt validation (Firebase Functions)

### 10. Referral Service

**Purpose**: Manage user referrals and rewards

**Interface**:
```dart
class ReferralService {
  Future<String> generateReferralCode(String userId)
  Future<void> applyReferralCode(String newUserId, String code)
  Future<void> awardReferralReward(String referrerId, String referredId)
  Future<ReferralStats> getReferralStats(String userId)
  Future<String> createGiftSubscription(String senderId, String tierId, Duration duration)
  Future<void> redeemGiftCode(String recipientId, String giftCode)
}
```

**Key Methods**:
- `generateReferralCode()`: Creates unique 6-character code
- `applyReferralCode()`: Links new user to referrer
- `awardReferralReward()`: Grants rewards to both users
- `createGiftSubscription()`: Generates gift code for premium access

**Data Models**:
```dart
class ReferralStats {
  String referralCode
  int totalReferrals
  int pendingReferrals
  int completedReferrals
  int rewardPointsEarned
  int premiumDaysEarned
}

class ReferralReward {
  String referrerId
  String referredId
  DateTime awardedAt
  RewardType type
  int value
}

enum RewardType {
  premiumDays,
  points,
  badge
}

class GiftSubscription {
  String giftCode
  String senderId
  String? recipientId
  String tierId
  Duration duration
  DateTime createdAt
  DateTime? redeemedAt
  bool redeemed
}
```

**Referral Code Generation**:
```dart
String generateReferralCode(String userId) {
  // Create deterministic but unique code
  String hash = sha256.convert(utf8.encode(userId)).toString()
  String code = hash.substring(0, 6).toUpperCase()
  return code
}
```

**Reward Structure**:
- New user completes onboarding: Referrer gets 3 premium days
- New user purchases premium: Referrer gets 7 premium days
- Milestone rewards: 5 referrals = special badge, 10 referrals = 30 premium days

**Gift Subscription Flow**:
1. Premium user creates gift in app
2. Service generates unique gift code
3. User shares code via messaging/social
4. Recipient enters code in app
5. Service validates and activates subscription
6. Both users receive notification

## Data Models

### Firebase Firestore Collections

#### users/{userId}
```dart
{
  "email": String,
  "displayName": String,
  "zodiacSign": String,
  "birthDate": Timestamp?,
  "birthTime": String?,
  "birthLocation": GeoPoint?,
  "subscription": {
    "tier": String,  // "free", "premium", "vip"
    "expiryDate": Timestamp?,
    "autoRenew": bool,
    "platform": String?,
    "transactionId": String?
  },
  "preferences": {
    "notificationTime": String?,  // "HH:mm"
    "notificationsEnabled": bool,
    "theme": String,
    "animatedBackground": String?,
    "customFont": String?
  },
  "progress": {
    "experiencePoints": int,
    "level": int,
    "badges": List<String>,
    "actionCounts": Map<String, int>
  },
  "streak": {
    "current": int,
    "longest": int,
    "lastVisit": Timestamp,
    "protectionActive": bool,
    "protectionUsedDate": Timestamp?
  },
  "referral": {
    "code": String,
    "referredBy": String?,
    "totalReferrals": int,
    "rewardPointsEarned": int,
    "premiumDaysEarned": int
  },
  "createdAt": Timestamp,
  "updatedAt": Timestamp
}
```

#### natalCharts/{userId}
```dart
{
  "birthDateTime": Timestamp,
  "birthLocation": {
    "latitude": double,
    "longitude": double,
    "city": String,
    "country": String
  },
  "planets": {
    "sun": {
      "longitude": double,
      "sign": String,
      "degree": int,
      "minute": int,
      "house": int
    },
    // ... other planets
  },
  "houses": [
    {
      "number": int,
      "cusp": double,
      "sign": String
    }
  ],
  "aspects": [
    {
      "planet1": String,
      "planet2": String,
      "type": String,
      "orb": double
    }
  ],
  "interpretation": String,
  "calculatedAt": Timestamp
}
```

#### tarotReadings/{userId}/readings/{readingId}
```dart
{
  "date": Timestamp,
  "zodiacSign": String,
  "cards": [
    {
      "name": String,
      "number": int,
      "suit": String,
      "reversed": bool,
      "position": String?  // "past", "present", "future" for 3-card
    }
  ],
  "interpretation": String,
  "type": String,  // "daily", "three_card"
  "createdAt": Timestamp
}
```

#### achievements/{achievementId}
```dart
{
  "id": String,
  "name": String,
  "description": String,
  "iconUrl": String,
  "rarity": String,
  "criteria": String,
  "xpReward": int,
  "category": String
}
```

#### userAchievements/{userId}/earned/{achievementId}
```dart
{
  "achievementId": String,
  "earnedAt": Timestamp,
  "xpAwarded": int
}
```

#### referrals/{referralCode}
```dart
{
  "userId": String,
  "code": String,
  "createdAt": Timestamp,
  "referrals": [
    {
      "referredUserId": String,
      "referredAt": Timestamp,
      "completed": bool,
      "rewardAwarded": bool
    }
  ]
}
```

#### giftSubscriptions/{giftCode}
```dart
{
  "code": String,
  "senderId": String,
  "recipientId": String?,
  "tierId": String,
  "durationDays": int,
  "createdAt": Timestamp,
  "redeemedAt": Timestamp?,
  "redeemed": bool,
  "expiresAt": Timestamp
}
```

### Local Storage (SharedPreferences)

```dart
// Cached data for offline access
"cached_lucky_items_{date}": String (JSON)
"cached_daily_horoscope_{date}": String (JSON)
"last_streak_check": String (ISO date)
"theme_config": String (JSON)
"notification_permission_asked": bool
```

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

