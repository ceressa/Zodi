import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../providers/auth_provider.dart';
import '../services/firebase_service.dart';

class PersonalizationScreen extends StatefulWidget {
  const PersonalizationScreen({super.key});

  @override
  State<PersonalizationScreen> createState() => _PersonalizationScreenState();
}

class _PersonalizationScreenState extends State<PersonalizationScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  
  bool _isLoading = true;
  
  // Form controllers
  final _partnerNameController = TextEditingController();
  final _occupationController = TextEditingController();
  final _careerGoalController = TextEditingController();
  final _cityController = TextEditingController();
  
  // Form values
  String _gender = 'belirtilmemiş';
  String? _relationshipStatus;
  String? _employmentStatus;
  String? _workField;
  String? _lifePhase;
  String? _spiritualInterest;
  List<String> _interests = [];
  List<String> _currentChallenges = [];
  List<String> _lifeGoals = [];

  // Options
  static const Map<String, String> _genderLabels = {
    'kadın': 'Kadın 👩',
    'erkek': 'Erkek 👨',
    'belirtilmemiş': 'Belirtmek İstemiyorum 🤷',
  };

  static const Map<String, String> _relationshipLabels = {
    'single': 'Bekar 💔',
    'dating': 'Flört Ediyor 💕',
    'relationship': 'İlişkisi Var 💑',
    'engaged': 'Nişanlı 💍',
    'married': 'Evli 💒',
    'complicated': 'Karmaşık 🤷',
    'prefer_not_say': 'Söylemek İstemiyorum',
  };

  static const Map<String, String> _employmentLabels = {
    'student': 'Öğrenci 📚',
    'employed': 'Çalışan 💼',
    'self_employed': 'Kendi İşi 🚀',
    'freelancer': 'Freelancer 💻',
    'unemployed': 'İş Arıyor 🔍',
    'homemaker': 'Ev Hanımı/Babası 🏠',
    'retired': 'Emekli 🌴',
  };

  static const Map<String, String> _workFieldLabels = {
    'tech': 'Teknoloji 💻',
    'health': 'Sağlık 🏥',
    'education': 'Eğitim 📖',
    'finance': 'Finans 💰',
    'arts': 'Sanat & Medya 🎨',
    'retail': 'Perakende 🛍️',
    'service': 'Hizmet Sektörü 🤝',
    'manufacturing': 'Üretim 🏭',
    'government': 'Kamu 🏛️',
    'other': 'Diğer',
  };

  static const Map<String, String> _lifePhaseLabels = {
    'exploring': 'Keşfediyorum 🔭',
    'building': 'İnşa Ediyorum 🏗️',
    'established': 'Yerleştim 🏡',
    'transitioning': 'Geçiş Dönemindeyim 🔄',
    'uncertain': 'Belirsiz 🤔',
  };

  static const Map<String, String> _spiritualLabels = {
    'believer': 'İnanıyorum ✨',
    'curious': 'Meraklıyım 🔮',
    'skeptic': 'Şüpheciyim 🤨',
    'just_fun': 'Sadece Eğlence 🎭',
  };

  static const List<String> _interestOptions = [
    'Aşk & İlişkiler 💕',
    'Kariyer 💼',
    'Para & Finans 💰',
    'Sağlık 🏃',
    'Aile 👨‍👩‍👧‍👦',
    'Arkadaşlık 👯',
    'Kişisel Gelişim 🌱',
    'Seyahat ✈️',
    'Eğitim 📚',
    'Spiritüellik 🔮',
  ];

  static const List<String> _challengeOptions = [
    'Para Sıkıntısı 💸',
    'İlişki Problemleri 💔',
    'Kariyer Belirsizliği 🤷',
    'Sağlık Endişeleri 🏥',
    'Aile Sorunları 👨‍👩‍👧',
    'Özgüven Eksikliği 😔',
    'Stres & Kaygı 😰',
    'Yalnızlık 🌙',
    'Motivasyon Kaybı 😴',
    'Büyük Karar Aşaması 🎯',
  ];

  static const List<String> _goalOptions = [
    'Aşkı Bulmak 💕',
    'Kariyer Atılımı 🚀',
    'Finansal Özgürlük 💰',
    'Sağlıklı Yaşam 🏃',
    'Evlenmek 💒',
    'Çocuk Sahibi Olmak 👶',
    'Kendi İşini Kurmak 🏢',
    'Yurt Dışına Çıkmak ✈️',
    'İç Huzur 🧘',
    'Yeni Beceriler 📚',
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _partnerNameController.dispose();
    _occupationController.dispose();
    _careerGoalController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _firebaseService.getUserProfile();
      debugPrint('📋 PersonalizationScreen _loadProfile: profile=${profile != null}');
      if (profile != null && mounted) {
        debugPrint('📋 Loaded: gender=${profile.gender}, relationship=${profile.relationshipStatus}, '
            'employment=${profile.employmentStatus}, city=${profile.currentCity}, '
            'interests=${profile.interests.length}, challenges=${profile.currentChallenges.length}, '
            'goals=${profile.lifeGoals.length}, lifePhase=${profile.lifePhase}, '
            'spiritualInterest=${profile.spiritualInterest}');
        setState(() {
          _gender = profile.gender;
          _relationshipStatus = profile.relationshipStatus;
          _partnerNameController.text = profile.partnerName ?? '';
          _employmentStatus = profile.employmentStatus;
          _occupationController.text = profile.occupation ?? '';
          _workField = profile.workField;
          _careerGoalController.text = profile.careerGoal ?? '';
          _lifePhase = profile.lifePhase;
          _spiritualInterest = profile.spiritualInterest;
          _cityController.text = profile.currentCity ?? '';
          _interests = List<String>.from(profile.interests);
          _currentChallenges = List<String>.from(profile.currentChallenges);
          _lifeGoals = List<String>.from(profile.lifeGoals);
          _isLoading = false;
        });
        debugPrint('📋 Completion after load: ${_completionPercentage.toInt()}%');
      } else {
        debugPrint('📋 No profile found or not mounted');
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e, stack) {
      debugPrint('❌ PersonalizationScreen _loadProfile error: $e');
      debugPrint('❌ Stack: $stack');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    try {
      setState(() => _isLoading = true);
      
      await _firebaseService.updatePersonalizationInfo(
        gender: _gender,
        relationshipStatus: _relationshipStatus,
        partnerName: _partnerNameController.text.isEmpty ? null : _partnerNameController.text,
        employmentStatus: _employmentStatus,
        occupation: _occupationController.text.isEmpty ? null : _occupationController.text,
        workField: _workField,
        careerGoal: _careerGoalController.text.isEmpty ? null : _careerGoalController.text,
        lifePhase: _lifePhase,
        spiritualInterest: _spiritualInterest,
        currentCity: _cityController.text.isEmpty ? null : _cityController.text,
        interests: _interests,
        currentChallenges: _currentChallenges,
        lifeGoals: _lifeGoals,
      );

      // AuthProvider profilini yenile — uygulama genelinde güncel kalsın
      if (mounted) {
        await context.read<AuthProvider>().reloadProfile();
      }

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                const Text('Astro Dozi seni daha iyi tanıyor artık! ✨'),
              ],
            ),
            backgroundColor: AppColors.positive,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bir hata oluştu: $e'),
            backgroundColor: AppColors.negative,
          ),
        );
      }
    }
  }

  double get _completionPercentage {
    int completed = 0;
    int total = 10;

    if (_gender != 'belirtilmemiş') completed++;
    if (_relationshipStatus != null) completed++;
    if (_employmentStatus != null) completed++;
    if (_occupationController.text.isNotEmpty) completed++;
    if (_workField != null) completed++;
    if (_cityController.text.isNotEmpty) completed++;
    if (_interests.isNotEmpty) completed++;
    if (_currentChallenges.isNotEmpty) completed++;
    if (_lifeGoals.isNotEmpty) completed++;
    if (_lifePhase != null) completed++;

    return (completed / total) * 100;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF1E1E3F), const Color(0xFF0D0D1A)]
                : [const Color(0xFFF8F5FF), const Color(0xFFEDE7F6)],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.accentPurple))
              : CustomScrollView(
                  slivers: [
                    _buildAppBar(isDark),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildCompletionCard(isDark),
                            const SizedBox(height: 24),
                            _buildCategoryCard(
                              isDark: isDark,
                              icon: '🧑',
                              title: 'Cinsiyet',
                              subtitle: 'Burç yorumları cinsiyete göre değişir',
                              child: _buildGenderSection(isDark),
                              delay: 0,
                            ),
                            const SizedBox(height: 16),
                            _buildCategoryCard(
                              isDark: isDark,
                              icon: '💕',
                              title: 'İlişki Durumu',
                              subtitle: 'Aşk hayatın hakkında bilgi ver',
                              child: _buildRelationshipSection(isDark),
                              delay: 50,
                            ),
                            const SizedBox(height: 16),
                            _buildCategoryCard(
                              isDark: isDark,
                              icon: '💼',
                              title: 'Kariyer & İş',
                              subtitle: 'Profesyonel hayatını anlat',
                              child: _buildCareerSection(isDark),
                              delay: 150,
                            ),
                            const SizedBox(height: 16),
                            _buildCategoryCard(
                              isDark: isDark,
                              icon: '🏠',
                              title: 'Yaşam',
                              subtitle: 'Hayat tarzını paylaş',
                              child: _buildLifeSection(isDark),
                              delay: 250,
                            ),
                            const SizedBox(height: 16),
                            _buildCategoryCard(
                              isDark: isDark,
                              icon: '🎯',
                              title: 'İlgi Alanları',
                              subtitle: 'Hangi konularda yorum istiyorsun?',
                              child: _buildInterestsSection(isDark),
                              delay: 300,
                            ),
                            const SizedBox(height: 16),
                            _buildCategoryCard(
                              isDark: isDark,
                              icon: '⚡',
                              title: 'Şu Anki Zorluklar',
                              subtitle: 'Nelerle mücadele ediyorsun?',
                              child: _buildChallengesSection(isDark),
                              delay: 400,
                            ),
                            const SizedBox(height: 16),
                            _buildCategoryCard(
                              isDark: isDark,
                              icon: '🌟',
                              title: 'Hayat Hedefleri',
                              subtitle: 'Nereye ulaşmak istiyorsun?',
                              child: _buildGoalsSection(isDark),
                              delay: 500,
                            ),
                            const SizedBox(height: 32),
                            _buildSaveButton(isDark),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildAppBar(bool isDark) {
    return SliverAppBar(
      floating: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new,
          color: isDark ? Colors.white : AppColors.textDark,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Astro Dozi Seni Tanısın',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : AppColors.textDark,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildCompletionCard(bool isDark) {
    final percentage = _completionPercentage;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accentPurple.withOpacity(0.2),
            AppColors.accentBlue.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.accentPurple.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AppColors.purpleGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profil Tamamlanma',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.textDark,
                      ),
                    ),
                    Text(
                      'Ne kadar çok bilgi, o kadar kişisel yorum!',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white70 : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '%${percentage.toInt()}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.accentPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: isDark ? Colors.white24 : Colors.black12,
              valueColor: AlwaysStoppedAnimation(
                percentage >= 80 ? AppColors.positive : AppColors.accentPurple,
              ),
              minHeight: 8,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0);
  }

  Widget _buildCategoryCard({
    required bool isDark,
    required String icon,
    required String title,
    required String subtitle,
    required Widget child,
    required int delay,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentPurple.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: delay < 200,
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          leading: Text(icon, style: const TextStyle(fontSize: 28)),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textDark,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white60 : AppColors.textMuted,
            ),
          ),
          iconColor: AppColors.accentPurple,
          collapsedIconColor: isDark ? Colors.white54 : AppColors.textMuted,
          children: [child],
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: delay), duration: 400.ms)
        .slideX(begin: 0.05, end: 0);
  }

  Widget _buildGenderSection(bool isDark) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _genderLabels.entries.map((entry) {
        final isSelected = _gender == entry.key;
        return ChoiceChip(
          label: Text(
            entry.value,
            style: TextStyle(
              color: isSelected ? Colors.white : (isDark ? AppColors.textSecondary : Colors.black87),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          selected: isSelected,
          selectedColor: AppColors.accentPurple,
          backgroundColor: isDark ? AppColors.cardDark : Colors.grey.shade200,
          onSelected: (selected) {
            if (selected) setState(() => _gender = entry.key);
          },
        );
      }).toList(),
    );
  }

  Widget _buildRelationshipSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdown(
          label: 'Durumun',
          value: _relationshipStatus,
          items: _relationshipLabels,
          onChanged: (v) => setState(() => _relationshipStatus = v),
          isDark: isDark,
        ),
        if (_relationshipStatus != null && 
            _relationshipStatus != 'single' && 
            _relationshipStatus != 'prefer_not_say') ...[
          const SizedBox(height: 16),
          _buildTextField(
            controller: _partnerNameController,
            label: 'Sevdiğin Kişinin Adı',
            hint: 'İsim (Yorumlarda kullanılır)',
            icon: Icons.favorite,
            isDark: isDark,
          ),
        ],
      ],
    );
  }

  Widget _buildCareerSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdown(
          label: 'Çalışma Durumu',
          value: _employmentStatus,
          items: _employmentLabels,
          onChanged: (v) => setState(() => _employmentStatus = v),
          isDark: isDark,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _occupationController,
          label: 'Meslek / Alan',
          hint: 'Ne iş yapıyorsun?',
          icon: Icons.work,
          isDark: isDark,
        ),
        const SizedBox(height: 16),
        _buildDropdown(
          label: 'Sektör',
          value: _workField,
          items: _workFieldLabels,
          onChanged: (v) => setState(() => _workField = v),
          isDark: isDark,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _careerGoalController,
          label: 'Kariyer Hedefi',
          hint: 'Kısa veya uzun vadeli hedefin',
          icon: Icons.flag,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildLifeSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          controller: _cityController,
          label: 'Şehir',
          hint: 'Nerede yaşıyorsun?',
          icon: Icons.location_city,
          isDark: isDark,
        ),
        const SizedBox(height: 16),
        _buildDropdown(
          label: 'Hayat Dönemi',
          value: _lifePhase,
          items: _lifePhaseLabels,
          onChanged: (v) => setState(() => _lifePhase = v),
          isDark: isDark,
        ),
        const SizedBox(height: 16),
        _buildDropdown(
          label: 'Astrolojiye Bakışın',
          value: _spiritualInterest,
          items: _spiritualLabels,
          onChanged: (v) => setState(() => _spiritualInterest = v),
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildInterestsSection(bool isDark) {
    return _buildChipSelection(
      options: _interestOptions,
      selected: _interests,
      onChanged: (list) => setState(() => _interests = list),
      isDark: isDark,
      maxSelection: 5,
    );
  }

  Widget _buildChallengesSection(bool isDark) {
    return _buildChipSelection(
      options: _challengeOptions,
      selected: _currentChallenges,
      onChanged: (list) => setState(() => _currentChallenges = list),
      isDark: isDark,
      maxSelection: 3,
    );
  }

  Widget _buildGoalsSection(bool isDark) {
    return _buildChipSelection(
      options: _goalOptions,
      selected: _lifeGoals,
      onChanged: (list) => setState(() => _lifeGoals = list),
      isDark: isDark,
      maxSelection: 3,
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required Map<String, String> items,
    required Function(String?) onChanged,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? Colors.white12 : Colors.grey.shade200,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              hint: Text(
                'Seç...',
                style: TextStyle(
                  color: isDark ? Colors.white38 : Colors.grey,
                ),
              ),
              dropdownColor: isDark ? AppColors.cardDark : Colors.white,
              items: items.entries.map((e) => DropdownMenuItem(
                value: e.key,
                child: Text(
                  e.value,
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textDark,
                  ),
                ),
              )).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.textDark,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: isDark ? Colors.white38 : Colors.grey,
            ),
            prefixIcon: Icon(icon, color: AppColors.accentPurple, size: 20),
            filled: true,
            fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? Colors.white12 : Colors.grey.shade200,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? Colors.white12 : Colors.grey.shade200,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.accentPurple, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildChipSelection({
    required List<String> options,
    required List<String> selected,
    required Function(List<String>) onChanged,
    required bool isDark,
    int maxSelection = 5,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'En fazla $maxSelection seçebilirsin',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white54 : AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selected.contains(option);
            final canSelect = isSelected || selected.length < maxSelection;
            
            return FilterChip(
              label: Text(
                option,
                style: TextStyle(
                  fontSize: 13,
                  color: isSelected
                      ? Colors.white
                      : (canSelect
                          ? (isDark ? Colors.white70 : AppColors.textDark)
                          : (isDark ? Colors.white30 : Colors.grey)),
                ),
              ),
              selected: isSelected,
              onSelected: canSelect
                  ? (sel) {
                      final newList = List<String>.from(selected);
                      if (sel) {
                        newList.add(option);
                      } else {
                        newList.remove(option);
                      }
                      onChanged(newList);
                    }
                  : null,
              selectedColor: AppColors.accentPurple,
              backgroundColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
              checkmarkColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? AppColors.accentPurple
                      : (isDark ? Colors.white12 : Colors.grey.shade300),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSaveButton(bool isDark) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: AppColors.purpleGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentPurple.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _saveProfile,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.white),
                const SizedBox(width: 8),
                const Text(
                  'Kaydet & Kişiselleştir',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0);
  }
}
