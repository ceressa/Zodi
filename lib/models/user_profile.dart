class UserProfile {
  // Temel Bilgiler
  final String userId;
  final String name;
  final String email;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime lastActiveAt;
  
  // Doğum Bilgileri
  final DateTime birthDate;
  final String birthTime;
  final String birthPlace;
  final double? birthLatitude;
  final double? birthLongitude;
  
  // Astrolojik Profil
  final String zodiacSign;
  final String? risingSign;
  final String? moonSign;
  final String? venusSign;
  final String? marsSign;
  final String? mercurySign;
  final String? jupiterSign;
  final String? saturnSign;
  final Map<String, dynamic>? birthChart; // Tam doğum haritası
  
  // Cinsiyet
  final String gender; // 'kadın', 'erkek', 'belirtilmemiş'

  // Kişiselleştirme
  final List<String> interests; // İlgi alanları (kariyer, aşk, sağlık, para)
  final List<String> favoriteTopics; // En çok okuduğu konular
  final String preferredLanguage;
  final String preferredTone; // 'casual', 'formal', 'humorous'
  final bool notificationsEnabled;
  final String notificationTime; // Günlük bildirim saati
  
  // Coin Bakiyesi
  final int coinBalance;

  // Premium & Abonelik
  final bool isPremium;
  final String membershipTier; // 'standard', 'altin', 'elmas', 'platinyum'
  final DateTime? premiumStartDate;
  final DateTime? premiumEndDate;
  final String? subscriptionType; // 'monthly', 'yearly', 'lifetime'
  final List<String> purchasedFeatures;
  
  // Kullanım İstatistikleri
  final int totalHoroscopeReads;
  final int totalCompatibilityChecks;
  final int totalDreamInterpretations;
  final int totalDetailedAnalyses;
  final int consecutiveDays; // Ardışık gün sayısı
  final DateTime? lastHoroscopeReadDate;
  final Map<String, int> featureUsageCount; // Her özellik kaç kez kullanıldı
  
  // Favori & Geçmiş
  final List<String> favoriteCompatibilities; // Favori uyum kontrolleri
  final List<String> savedHoroscopes; // Kaydedilen burç yorumları (ID'ler)
  final List<String> savedDreams; // Kaydedilen rüya yorumları
  final String? lastViewedZodiacSign; // Son baktığı burç
  final List<String> recentSearches; // Son aramalar
  
  // Sosyal & İlişkiler
  final String? relationshipStatus; // 'single', 'relationship', 'married', 'engaged', 'complicated'
  final String? partnerName; // Sevdiği kişinin adı
  final String? partnerZodiacSign;
  final DateTime? partnerBirthDate;
  final List<String> friendZodiacSigns; // Arkadaşların burçları
  final String? currentCity; // Yaşadığı şehir
  
  // Kariyer & İş Hayatı
  final String? occupation; // Meslek
  final String? employmentStatus; // 'student', 'employed', 'self_employed', 'unemployed', 'retired'
  final String? workField; // Çalışma alanı (teknoloji, sağlık, eğitim vs.)
  final String? careerGoal; // Kariyer hedefi
  
  // Yaşam & Kişilik
  final String? lifePhase; // 'exploring', 'building', 'established', 'transitioning'
  final List<String> currentChallenges; // Şu anki zorluklar (para, ilişki, kariyer vs.)
  final List<String> lifeGoals; // Hayat hedefleri
  final String? personalityType; // MBTI veya benzeri (opsiyonel)
  final String? spiritualInterest; // Spiritüel ilgi seviyesi: 'curious', 'believer', 'skeptic'
  
  // Davranış Analizi
  final Map<String, dynamic> readingPatterns; // Okuma alışkanlıkları
  final List<String> mostReadCategories; // En çok okunan kategoriler
  final String? preferredReadingTime; // Tercih edilen okuma saati
  final double averageSessionDuration; // Ortalama oturum süresi (dakika)
  final int totalSessions;
  
  // Geri Bildirim & Etkileşim
  final double averageRating; // Ortalama verdiği puan
  final int totalFeedbacks; // Toplam geri bildirim sayısı
  final Map<String, double> categoryRatings; // Kategori bazlı puanlar
  final List<String> reportedIssues; // Bildirilen sorunlar
  
  // Tercihler & Ayarlar
  final Map<String, dynamic> preferences;
  final bool darkMode;
  final String appLanguage;
  final bool autoRefresh;
  final bool shareDataForPersonalization;
  
  // Özel Alanlar
  final Map<String, dynamic>? customFields; // Gelecekte eklenebilecek alanlar
  final List<String> tags; // Kullanıcı etiketleri (segmentasyon için)
  final String? referralCode; // Referans kodu
  final String? referredBy; // Kim tarafından yönlendirildi
  
  // Streak & Progress (for StreakService)
  final Map<String, dynamic>? streak; // Streak data
  final Map<String, dynamic>? progress; // Progress tracking

  UserProfile({
    required this.userId,
    required this.name,
    required this.email,
    this.photoUrl,
    required this.createdAt,
    required this.lastActiveAt,
    required this.birthDate,
    required this.birthTime,
    required this.birthPlace,
    this.birthLatitude,
    this.birthLongitude,
    required this.zodiacSign,
    this.risingSign,
    this.moonSign,
    this.venusSign,
    this.marsSign,
    this.mercurySign,
    this.jupiterSign,
    this.saturnSign,
    this.birthChart,
    this.gender = 'belirtilmemiş',
    this.interests = const [],
    this.favoriteTopics = const [],
    this.preferredLanguage = 'tr',
    this.preferredTone = 'casual',
    this.notificationsEnabled = true,
    this.notificationTime = '09:00',
    this.coinBalance = 0,
    this.isPremium = false,
    this.membershipTier = 'standard',
    this.premiumStartDate,
    this.premiumEndDate,
    this.subscriptionType,
    this.purchasedFeatures = const [],
    this.totalHoroscopeReads = 0,
    this.totalCompatibilityChecks = 0,
    this.totalDreamInterpretations = 0,
    this.totalDetailedAnalyses = 0,
    this.consecutiveDays = 0,
    this.lastHoroscopeReadDate,
    this.featureUsageCount = const {},
    this.favoriteCompatibilities = const [],
    this.savedHoroscopes = const [],
    this.savedDreams = const [],
    this.lastViewedZodiacSign,
    this.recentSearches = const [],
    this.relationshipStatus,
    this.partnerName,
    this.partnerZodiacSign,
    this.partnerBirthDate,
    this.friendZodiacSigns = const [],
    this.currentCity,
    this.occupation,
    this.employmentStatus,
    this.workField,
    this.careerGoal,
    this.lifePhase,
    this.currentChallenges = const [],
    this.lifeGoals = const [],
    this.personalityType,
    this.spiritualInterest,
    this.readingPatterns = const {},
    this.mostReadCategories = const [],
    this.preferredReadingTime,
    this.averageSessionDuration = 0.0,
    this.totalSessions = 0,
    this.averageRating = 0.0,
    this.totalFeedbacks = 0,
    this.categoryRatings = const {},
    this.reportedIssues = const [],
    this.preferences = const {},
    this.darkMode = false,
    this.appLanguage = 'tr',
    this.autoRefresh = true,
    this.shareDataForPersonalization = true,
    this.customFields,
    this.tags = const [],
    this.referralCode,
    this.referredBy,
    this.streak,
    this.progress,
  });

  Map<String, dynamic> toJson() => {
        // Temel Bilgiler
        'userId': userId,
        'name': name,
        'email': email,
        'photoUrl': photoUrl,
        'createdAt': createdAt.toIso8601String(),
        'lastActiveAt': lastActiveAt.toIso8601String(),
        
        // Doğum Bilgileri
        'birthDate': birthDate.toIso8601String(),
        'birthTime': birthTime,
        'birthPlace': birthPlace,
        'birthLatitude': birthLatitude,
        'birthLongitude': birthLongitude,
        
        // Astrolojik Profil
        'zodiacSign': zodiacSign,
        'risingSign': risingSign,
        'moonSign': moonSign,
        'venusSign': venusSign,
        'marsSign': marsSign,
        'mercurySign': mercurySign,
        'jupiterSign': jupiterSign,
        'saturnSign': saturnSign,
        'birthChart': birthChart,
        
        // Cinsiyet
        'gender': gender,

        // Kişiselleştirme
        'interests': interests,
        'favoriteTopics': favoriteTopics,
        'preferredLanguage': preferredLanguage,
        'preferredTone': preferredTone,
        'notificationsEnabled': notificationsEnabled,
        'notificationTime': notificationTime,
        
        // Coin Bakiyesi
        'coinBalance': coinBalance,

        // Premium & Abonelik
        'isPremium': isPremium,
        'membershipTier': membershipTier,
        'premiumStartDate': premiumStartDate?.toIso8601String(),
        'premiumEndDate': premiumEndDate?.toIso8601String(),
        'subscriptionType': subscriptionType,
        'purchasedFeatures': purchasedFeatures,
        
        // Kullanım İstatistikleri
        'totalHoroscopeReads': totalHoroscopeReads,
        'totalCompatibilityChecks': totalCompatibilityChecks,
        'totalDreamInterpretations': totalDreamInterpretations,
        'totalDetailedAnalyses': totalDetailedAnalyses,
        'consecutiveDays': consecutiveDays,
        'lastHoroscopeReadDate': lastHoroscopeReadDate?.toIso8601String(),
        'featureUsageCount': featureUsageCount,
        
        // Favori & Geçmiş
        'favoriteCompatibilities': favoriteCompatibilities,
        'savedHoroscopes': savedHoroscopes,
        'savedDreams': savedDreams,
        'lastViewedZodiacSign': lastViewedZodiacSign,
        'recentSearches': recentSearches,
        
        // Sosyal & İlişkiler
        'relationshipStatus': relationshipStatus,
        'partnerName': partnerName,
        'partnerZodiacSign': partnerZodiacSign,
        'partnerBirthDate': partnerBirthDate?.toIso8601String(),
        'friendZodiacSigns': friendZodiacSigns,
        'currentCity': currentCity,
        
        // Kariyer & İş Hayatı
        'occupation': occupation,
        'employmentStatus': employmentStatus,
        'workField': workField,
        'careerGoal': careerGoal,
        
        // Yaşam & Kişilik
        'lifePhase': lifePhase,
        'currentChallenges': currentChallenges,
        'lifeGoals': lifeGoals,
        'personalityType': personalityType,
        'spiritualInterest': spiritualInterest,
        
        // Davranış Analizi
        'readingPatterns': readingPatterns,
        'mostReadCategories': mostReadCategories,
        'preferredReadingTime': preferredReadingTime,
        'averageSessionDuration': averageSessionDuration,
        'totalSessions': totalSessions,
        
        // Geri Bildirim & Etkileşim
        'averageRating': averageRating,
        'totalFeedbacks': totalFeedbacks,
        'categoryRatings': categoryRatings,
        'reportedIssues': reportedIssues,
        
        // Tercihler & Ayarlar
        'preferences': preferences,
        'darkMode': darkMode,
        'appLanguage': appLanguage,
        'autoRefresh': autoRefresh,
        'shareDataForPersonalization': shareDataForPersonalization,
        
        // Özel Alanlar
        'customFields': customFields,
        'tags': tags,
        'referralCode': referralCode,
        'referredBy': referredBy,
        
        // Streak & Progress
        'streak': streak,
        'progress': progress,
      };

  /// Güvenli DateTime parse — hem ISO string hem Timestamp destekler
  static DateTime _parseDateTime(dynamic value, {DateTime? fallback}) {
    if (value == null) return fallback ?? DateTime.now();
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return fallback ?? DateTime.now();
      }
    }
    // Firebase Timestamp nesnesi
    try {
      return (value as dynamic).toDate();
    } catch (_) {
      return fallback ?? DateTime.now();
    }
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        userId: json['userId'] ?? '',
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        photoUrl: json['photoUrl'],
        createdAt: _parseDateTime(json['createdAt']),
        lastActiveAt: _parseDateTime(json['lastActiveAt']),
        birthDate: _parseDateTime(json['birthDate'], fallback: DateTime(2000, 1, 1)),
        birthTime: json['birthTime'] ?? '',
        birthPlace: json['birthPlace'] ?? '',
        birthLatitude: json['birthLatitude']?.toDouble(),
        birthLongitude: json['birthLongitude']?.toDouble(),
        zodiacSign: json['zodiacSign'] ?? '',
        risingSign: json['risingSign'],
        moonSign: json['moonSign'],
        venusSign: json['venusSign'],
        marsSign: json['marsSign'],
        mercurySign: json['mercurySign'],
        jupiterSign: json['jupiterSign'],
        saturnSign: json['saturnSign'],
        birthChart: json['birthChart'] != null 
            ? Map<String, dynamic>.from(json['birthChart']) 
            : null,
        gender: json['gender'] ?? 'belirtilmemiş',
        interests: List<String>.from(json['interests'] ?? []),
        favoriteTopics: List<String>.from(json['favoriteTopics'] ?? []),
        preferredLanguage: json['preferredLanguage'] ?? 'tr',
        preferredTone: json['preferredTone'] ?? 'casual',
        notificationsEnabled: json['notificationsEnabled'] ?? true,
        notificationTime: json['notificationTime'] ?? '09:00',
        coinBalance: json['coinBalance'] ?? 0,
        isPremium: json['isPremium'] ?? false,
        membershipTier: json['membershipTier'] ?? 'standard',
        premiumStartDate: json['premiumStartDate'] != null
            ? _parseDateTime(json['premiumStartDate'])
            : null,
        premiumEndDate: json['premiumEndDate'] != null
            ? _parseDateTime(json['premiumEndDate'])
            : null,
        subscriptionType: json['subscriptionType'],
        purchasedFeatures: List<String>.from(json['purchasedFeatures'] ?? []),
        totalHoroscopeReads: json['totalHoroscopeReads'] ?? 0,
        totalCompatibilityChecks: json['totalCompatibilityChecks'] ?? 0,
        totalDreamInterpretations: json['totalDreamInterpretations'] ?? 0,
        totalDetailedAnalyses: json['totalDetailedAnalyses'] ?? 0,
        consecutiveDays: json['consecutiveDays'] ?? 0,
        lastHoroscopeReadDate: json['lastHoroscopeReadDate'] != null
            ? _parseDateTime(json['lastHoroscopeReadDate'])
            : null,
        featureUsageCount: (json['featureUsageCount'] as Map?)?.map(
          (key, value) => MapEntry(key.toString(), (value as num?)?.toInt() ?? 0),
        ) ?? {},
        favoriteCompatibilities: List<String>.from(json['favoriteCompatibilities'] ?? []),
        savedHoroscopes: List<String>.from(json['savedHoroscopes'] ?? []),
        savedDreams: List<String>.from(json['savedDreams'] ?? []),
        lastViewedZodiacSign: json['lastViewedZodiacSign'],
        recentSearches: List<String>.from(json['recentSearches'] ?? []),
        relationshipStatus: json['relationshipStatus'],
        partnerName: json['partnerName'],
        partnerZodiacSign: json['partnerZodiacSign'],
        partnerBirthDate: json['partnerBirthDate'] != null
            ? _parseDateTime(json['partnerBirthDate'])
            : null,
        friendZodiacSigns: List<String>.from(json['friendZodiacSigns'] ?? []),
        currentCity: json['currentCity'],
        occupation: json['occupation'],
        employmentStatus: json['employmentStatus'],
        workField: json['workField'],
        careerGoal: json['careerGoal'],
        lifePhase: json['lifePhase'],
        currentChallenges: List<String>.from(json['currentChallenges'] ?? []),
        lifeGoals: List<String>.from(json['lifeGoals'] ?? []),
        personalityType: json['personalityType'],
        spiritualInterest: json['spiritualInterest'],
        readingPatterns: Map<String, dynamic>.from(json['readingPatterns'] ?? {}),
        mostReadCategories: List<String>.from(json['mostReadCategories'] ?? []),
        preferredReadingTime: json['preferredReadingTime'],
        averageSessionDuration: (json['averageSessionDuration'] ?? 0.0).toDouble(),
        totalSessions: json['totalSessions'] ?? 0,
        averageRating: (json['averageRating'] ?? 0.0).toDouble(),
        totalFeedbacks: json['totalFeedbacks'] ?? 0,
        categoryRatings: Map<String, double>.from(
          (json['categoryRatings'] ?? {}).map(
            (key, value) => MapEntry(key, (value ?? 0.0).toDouble()),
          ),
        ),
        reportedIssues: List<String>.from(json['reportedIssues'] ?? []),
        preferences: Map<String, dynamic>.from(json['preferences'] ?? {}),
        darkMode: json['darkMode'] ?? false,
        appLanguage: json['appLanguage'] ?? 'tr',
        autoRefresh: json['autoRefresh'] ?? true,
        shareDataForPersonalization: json['shareDataForPersonalization'] ?? true,
        customFields: json['customFields'] != null 
            ? Map<String, dynamic>.from(json['customFields']) 
            : null,
        tags: List<String>.from(json['tags'] ?? []),
        referralCode: json['referralCode'],
        referredBy: json['referredBy'],
        streak: json['streak'] != null 
            ? Map<String, dynamic>.from(json['streak']) 
            : null,
        progress: json['progress'] != null 
            ? Map<String, dynamic>.from(json['progress']) 
            : null,
      );

  // Helper method: Profil tamamlanma yüzdesi
  double get completionPercentage {
    int completed = 0;
    const int total = 11; // Önemli kişiselleştirme alanları

    // Temel bilgiler (3)
    if (name.isNotEmpty) completed++;
    if (birthPlace.isNotEmpty) completed++;
    if (birthTime.isNotEmpty) completed++;

    // Astrolojik (2)
    if (risingSign != null && risingSign!.isNotEmpty) completed++;
    if (moonSign != null && moonSign!.isNotEmpty) completed++;

    // İlişki (1) — durum seçildiyse yeterli
    if (relationshipStatus != null && relationshipStatus!.isNotEmpty) completed++;

    // Kariyer (2)
    if (occupation != null && occupation!.isNotEmpty) completed++;
    if (employmentStatus != null && employmentStatus!.isNotEmpty) completed++;

    // Yaşam (2)
    if (currentCity != null && currentCity!.isNotEmpty) completed++;
    if (interests.isNotEmpty) completed++;

    // Hedefler (1)
    if (currentChallenges.isNotEmpty || lifeGoals.isNotEmpty) completed++;

    return (completed / total) * 100;
  }
  
  // Helper: Hangi kategoriler eksik
  Map<String, bool> get profileCompletionByCategory {
    return {
      'basic': name.isNotEmpty && birthPlace.isNotEmpty && birthTime.isNotEmpty,
      'astrology': risingSign != null && moonSign != null,
      'relationship': relationshipStatus != null,
      'career': occupation != null || employmentStatus != null,
      'life': currentCity != null && interests.isNotEmpty,
      'goals': currentChallenges.isNotEmpty || lifeGoals.isNotEmpty,
    };
  }

  // Helper method: Aktif kullanıcı mı?
  bool get isActiveUser {
    final daysSinceLastActive = DateTime.now().difference(lastActiveAt).inDays;
    return daysSinceLastActive <= 7;
  }

  // Helper method: Sadık kullanıcı mı?
  bool get isLoyalUser {
    return consecutiveDays >= 7 && totalSessions >= 20;
  }

  // Helper method: Yeni kullanıcı mı?
  bool get isNewUser {
    final daysSinceCreation = DateTime.now().difference(createdAt).inDays;
    return daysSinceCreation <= 7;
  }

  // Copy with method
  UserProfile copyWith({
    String? userId,
    String? name,
    String? email,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? lastActiveAt,
    DateTime? birthDate,
    String? birthTime,
    String? birthPlace,
    double? birthLatitude,
    double? birthLongitude,
    String? zodiacSign,
    String? risingSign,
    String? moonSign,
    String? venusSign,
    String? marsSign,
    String? mercurySign,
    String? jupiterSign,
    String? saturnSign,
    Map<String, dynamic>? birthChart,
    List<String>? interests,
    List<String>? favoriteTopics,
    String? preferredLanguage,
    String? preferredTone,
    bool? notificationsEnabled,
    String? notificationTime,
    bool? isPremium,
    String? membershipTier,
    DateTime? premiumStartDate,
    DateTime? premiumEndDate,
    String? subscriptionType,
    List<String>? purchasedFeatures,
    int? totalHoroscopeReads,
    int? totalCompatibilityChecks,
    int? totalDreamInterpretations,
    int? totalDetailedAnalyses,
    int? consecutiveDays,
    DateTime? lastHoroscopeReadDate,
    Map<String, int>? featureUsageCount,
    List<String>? favoriteCompatibilities,
    List<String>? savedHoroscopes,
    List<String>? savedDreams,
    String? lastViewedZodiacSign,
    List<String>? recentSearches,
    String? relationshipStatus,
    String? partnerName,
    String? partnerZodiacSign,
    DateTime? partnerBirthDate,
    List<String>? friendZodiacSigns,
    String? currentCity,
    String? occupation,
    String? employmentStatus,
    String? workField,
    String? careerGoal,
    String? lifePhase,
    List<String>? currentChallenges,
    List<String>? lifeGoals,
    String? personalityType,
    String? spiritualInterest,
    Map<String, dynamic>? readingPatterns,
    List<String>? mostReadCategories,
    String? preferredReadingTime,
    double? averageSessionDuration,
    int? totalSessions,
    double? averageRating,
    int? totalFeedbacks,
    Map<String, double>? categoryRatings,
    List<String>? reportedIssues,
    Map<String, dynamic>? preferences,
    bool? darkMode,
    String? appLanguage,
    bool? autoRefresh,
    bool? shareDataForPersonalization,
    Map<String, dynamic>? customFields,
    List<String>? tags,
    String? referralCode,
    String? referredBy,
    Map<String, dynamic>? streak,
    Map<String, dynamic>? progress,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      birthDate: birthDate ?? this.birthDate,
      birthTime: birthTime ?? this.birthTime,
      birthPlace: birthPlace ?? this.birthPlace,
      birthLatitude: birthLatitude ?? this.birthLatitude,
      birthLongitude: birthLongitude ?? this.birthLongitude,
      zodiacSign: zodiacSign ?? this.zodiacSign,
      risingSign: risingSign ?? this.risingSign,
      moonSign: moonSign ?? this.moonSign,
      venusSign: venusSign ?? this.venusSign,
      marsSign: marsSign ?? this.marsSign,
      mercurySign: mercurySign ?? this.mercurySign,
      jupiterSign: jupiterSign ?? this.jupiterSign,
      saturnSign: saturnSign ?? this.saturnSign,
      birthChart: birthChart ?? this.birthChart,
      interests: interests ?? this.interests,
      favoriteTopics: favoriteTopics ?? this.favoriteTopics,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      preferredTone: preferredTone ?? this.preferredTone,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      notificationTime: notificationTime ?? this.notificationTime,
      isPremium: isPremium ?? this.isPremium,
      membershipTier: membershipTier ?? this.membershipTier,
      premiumStartDate: premiumStartDate ?? this.premiumStartDate,
      premiumEndDate: premiumEndDate ?? this.premiumEndDate,
      subscriptionType: subscriptionType ?? this.subscriptionType,
      purchasedFeatures: purchasedFeatures ?? this.purchasedFeatures,
      totalHoroscopeReads: totalHoroscopeReads ?? this.totalHoroscopeReads,
      totalCompatibilityChecks: totalCompatibilityChecks ?? this.totalCompatibilityChecks,
      totalDreamInterpretations: totalDreamInterpretations ?? this.totalDreamInterpretations,
      totalDetailedAnalyses: totalDetailedAnalyses ?? this.totalDetailedAnalyses,
      consecutiveDays: consecutiveDays ?? this.consecutiveDays,
      lastHoroscopeReadDate: lastHoroscopeReadDate ?? this.lastHoroscopeReadDate,
      featureUsageCount: featureUsageCount ?? this.featureUsageCount,
      favoriteCompatibilities: favoriteCompatibilities ?? this.favoriteCompatibilities,
      savedHoroscopes: savedHoroscopes ?? this.savedHoroscopes,
      savedDreams: savedDreams ?? this.savedDreams,
      lastViewedZodiacSign: lastViewedZodiacSign ?? this.lastViewedZodiacSign,
      recentSearches: recentSearches ?? this.recentSearches,
      relationshipStatus: relationshipStatus ?? this.relationshipStatus,
      partnerName: partnerName ?? this.partnerName,
      partnerZodiacSign: partnerZodiacSign ?? this.partnerZodiacSign,
      partnerBirthDate: partnerBirthDate ?? this.partnerBirthDate,
      friendZodiacSigns: friendZodiacSigns ?? this.friendZodiacSigns,
      currentCity: currentCity ?? this.currentCity,
      occupation: occupation ?? this.occupation,
      employmentStatus: employmentStatus ?? this.employmentStatus,
      workField: workField ?? this.workField,
      careerGoal: careerGoal ?? this.careerGoal,
      lifePhase: lifePhase ?? this.lifePhase,
      currentChallenges: currentChallenges ?? this.currentChallenges,
      lifeGoals: lifeGoals ?? this.lifeGoals,
      personalityType: personalityType ?? this.personalityType,
      spiritualInterest: spiritualInterest ?? this.spiritualInterest,
      readingPatterns: readingPatterns ?? this.readingPatterns,
      mostReadCategories: mostReadCategories ?? this.mostReadCategories,
      preferredReadingTime: preferredReadingTime ?? this.preferredReadingTime,
      averageSessionDuration: averageSessionDuration ?? this.averageSessionDuration,
      totalSessions: totalSessions ?? this.totalSessions,
      averageRating: averageRating ?? this.averageRating,
      totalFeedbacks: totalFeedbacks ?? this.totalFeedbacks,
      categoryRatings: categoryRatings ?? this.categoryRatings,
      reportedIssues: reportedIssues ?? this.reportedIssues,
      preferences: preferences ?? this.preferences,
      darkMode: darkMode ?? this.darkMode,
      appLanguage: appLanguage ?? this.appLanguage,
      autoRefresh: autoRefresh ?? this.autoRefresh,
      shareDataForPersonalization: shareDataForPersonalization ?? this.shareDataForPersonalization,
      customFields: customFields ?? this.customFields,
      tags: tags ?? this.tags,
      referralCode: referralCode ?? this.referralCode,
      referredBy: referredBy ?? this.referredBy,
      streak: streak ?? this.streak,
      progress: progress ?? this.progress,
    );
  }
}
