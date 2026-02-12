import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/auth_provider.dart';
import '../providers/horoscope_provider.dart';
import '../constants/colors.dart';
import '../widgets/animated_card.dart';

class RisingSignScreen extends StatefulWidget {
  const RisingSignScreen({super.key});

  @override
  State<RisingSignScreen> createState() => _RisingSignScreenState();
}

class _RisingSignScreenState extends State<RisingSignScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _birthDate;
  final _birthTimeController = TextEditingController();
  final _birthPlaceController = TextEditingController();
  bool _hasPrefilledProfileData = false;
  bool _isBirthDateLocked = false;
  
  // Turkish cities for autocomplete
  static const List<String> _turkishCities = [
    'Adana',
    'Adıyaman',
    'Afyonkarahisar',
    'Ağrı',
    'Aksaray',
    'Amasya',
    'Ankara',
    'Antalya',
    'Ardahan',
    'Artvin',
    'Aydın',
    'Balıkesir',
    'Bartın',
    'Batman',
    'Bayburt',
    'Bilecik',
    'Bingöl',
    'Bitlis',
    'Bolu',
    'Burdur',
    'Bursa',
    'Çanakkale',
    'Çankırı',
    'Çorum',
    'Denizli',
    'Diyarbakır',
    'Düzce',
    'Edirne',
    'Elazığ',
    'Erzincan',
    'Erzurum',
    'Eskişehir',
    'Gaziantep',
    'Giresun',
    'Gümüşhane',
    'Hakkari',
    'Hatay',
    'Iğdır',
    'Isparta',
    'İstanbul',
    'İzmir',
    'Kahramanmaraş',
    'Karabük',
    'Karaman',
    'Kars',
    'Kastamonu',
    'Kayseri',
    'Kırıkkale',
    'Kırklareli',
    'Kırşehir',
    'Kilis',
    'Kocaeli',
    'Konya',
    'Kütahya',
    'Malatya',
    'Manisa',
    'Mardin',
    'Mersin',
    'Muğla',
    'Muş',
    'Nevşehir',
    'Niğde',
    'Ordu',
    'Osmaniye',
    'Rize',
    'Sakarya',
    'Samsun',
    'Siirt',
    'Sinop',
    'Sivas',
    'Şanlıurfa',
    'Şırnak',
    'Tekirdağ',
    'Tokat',
    'Trabzon',
    'Tunceli',
    'Uşak',
    'Van',
    'Yalova',
    'Yozgat',
    'Zonguldak',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_hasPrefilledProfileData) return;

    final profile = Provider.of<AuthProvider>(context).userProfile;

    if (profile == null) return;

    if (profile.birthDate.year > 1900) {
      _birthDate = profile.birthDate;
      _isBirthDateLocked = true;
    }

    if (profile.birthTime.trim().isNotEmpty) {
      _birthTimeController.text = profile.birthTime.trim();
    }

    if (profile.birthPlace.trim().isNotEmpty) {
      _birthPlaceController.text = profile.birthPlace.trim();
    }

    _hasPrefilledProfileData = true;
  }

  @override
  void dispose() {
    _birthTimeController.dispose();
    _birthPlaceController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.accentPurple,
              onPrimary: Colors.white,
              surface: AppColors.cardDark,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 12, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.accentPurple,
              onPrimary: Colors.white,
              surface: AppColors.cardDark,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _birthTimeController.text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _calculate() async {
    if (!_formKey.currentState!.validate() || _birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen tüm alanları doldurun')),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final horoscopeProvider = context.read<HoroscopeProvider>();

    if (authProvider.selectedZodiac == null) return;

    await horoscopeProvider.calculateRisingSign(
      sunSign: authProvider.selectedZodiac!,
      birthDate: _birthDate!,
      birthTime: _birthTimeController.text,
      birthPlace: _birthPlaceController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final horoscopeProvider = context.watch<HoroscopeProvider>();
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [AppColors.bgDark, AppColors.cardDark]
                : [AppColors.bgLight, AppColors.surfaceLight],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back,
                        color: isDark ? AppColors.textPrimary : AppColors.textDark,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Yükselen Burç',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: isDark ? AppColors.textPrimary : AppColors.textDark,
                            ),
                          ),
                          Text(
                            'Gerçek kişiliğini keşfet',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? AppColors.textSecondary : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Form
                AnimatedCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Doğum Bilgilerin',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.textPrimary : AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Birth Date
                        InkWell(
                          onTap: _isBirthDateLocked ? null : _selectDate,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: (isDark ? AppColors.textPrimary : AppColors.textDark).withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: (isDark ? AppColors.textPrimary : AppColors.textDark).withOpacity(0.1),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  color: AppColors.accentPurple,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _birthDate == null
                                        ? 'Doğum Tarihi'
                                        : '${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: _birthDate == null
                                          ? AppColors.textMuted
                                          : (isDark ? AppColors.textPrimary : AppColors.textDark),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_isBirthDateLocked)
                          Padding(
                            padding: const EdgeInsets.only(top: 8, left: 4),
                            child: Text(
                              'Doğum tarihi profilinden otomatik alındı',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),

                        const SizedBox(height: 16),
                        
                        // Birth Time
                        InkWell(
                          onTap: _selectTime,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: (isDark ? AppColors.textPrimary : AppColors.textDark).withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: (isDark ? AppColors.textPrimary : AppColors.textDark).withOpacity(0.1),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  color: AppColors.accentPurple,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _birthTimeController.text.isEmpty
                                        ? 'Doğum Saati'
                                        : _birthTimeController.text,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: _birthTimeController.text.isEmpty
                                          ? AppColors.textMuted
                                          : (isDark ? AppColors.textPrimary : AppColors.textDark),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Birth Place with Autocomplete
                        Autocomplete<String>(
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text.isEmpty) {
                              return const Iterable<String>.empty();
                            }
                            return _turkishCities.where((String city) {
                              return city.toLowerCase().contains(textEditingValue.text.toLowerCase());
                            });
                          },
                          onSelected: (String selection) {
                            _birthPlaceController.text = selection;
                          },
                          fieldViewBuilder: (
                            BuildContext context,
                            TextEditingController fieldTextEditingController,
                            FocusNode fieldFocusNode,
                            VoidCallback onFieldSubmitted,
                          ) {
                            // Sync with our controller
                            fieldTextEditingController.text = _birthPlaceController.text;
                            fieldTextEditingController.addListener(() {
                              _birthPlaceController.text = fieldTextEditingController.text;
                            });
                            
                            return TextFormField(
                              controller: fieldTextEditingController,
                              focusNode: fieldFocusNode,
                              decoration: InputDecoration(
                                labelText: 'Doğum Yeri',
                                hintText: 'Şehir adı yazın (örn: Aksaray)',
                                helperText: 'Sadece şehir adı yeterli',
                                prefixIcon: Icon(Icons.location_on, color: AppColors.accentPurple),
                                filled: true,
                                fillColor: (isDark ? AppColors.textPrimary : AppColors.textDark).withOpacity(0.05),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: (isDark ? AppColors.textPrimary : AppColors.textDark).withOpacity(0.1),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: (isDark ? AppColors.textPrimary : AppColors.textDark).withOpacity(0.1),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: AppColors.accentPurple, width: 2),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Doğum yeri gerekli';
                                }
                                return null;
                              },
                            );
                          },
                          optionsViewBuilder: (
                            BuildContext context,
                            AutocompleteOnSelected<String> onSelected,
                            Iterable<String> options,
                          ) {
                            return Align(
                              alignment: Alignment.topLeft,
                              child: Material(
                                elevation: 4,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  constraints: const BoxConstraints(maxHeight: 200),
                                  width: MediaQuery.of(context).size.width - 48,
                                  decoration: BoxDecoration(
                                    color: isDark ? AppColors.cardDark : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ListView.builder(
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    itemCount: options.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      final String option = options.elementAt(index);
                                      return InkWell(
                                        onTap: () => onSelected(option),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                color: (isDark ? AppColors.textPrimary : AppColors.textDark).withOpacity(0.1),
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.location_city,
                                                size: 16,
                                                color: AppColors.accentPurple,
                                              ),
                                              const SizedBox(width: 12),
                                              Text(
                                                option,
                                                style: TextStyle(
                                                  color: isDark ? AppColors.textPrimary : AppColors.textDark,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Calculate Button
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: AppColors.cosmicGradient,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: horoscopeProvider.isLoadingRisingSign ? null : _calculate,
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: horoscopeProvider.isLoadingRisingSign
                                    ? const Center(
                                        child: SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      )
                                    : const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                                          SizedBox(width: 8),
                                          Text(
                                            'Hesapla',
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
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Results
                if (horoscopeProvider.risingSignResult != null) ...[
                  const SizedBox(height: 24),
                  
                  AnimatedCard(
                    delay: 200.ms,
                    gradient: AppColors.purpleGradient,
                    child: Column(
                      children: [
                        const Text(
                          'Burç Üçlüsü',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildSignBadge(
                              horoscopeProvider.risingSignResult!.sunSign.symbol,
                              'Güneş',
                              signName: horoscopeProvider.risingSignResult!.sunSign.displayName,
                            ),
                            _buildSignBadge(
                              horoscopeProvider.risingSignResult!.risingSign.symbol,
                              'Yükselen',
                              signName: horoscopeProvider.risingSignResult!.risingSign.displayName,
                            ),
                            _buildSignBadge(
                              horoscopeProvider.risingSignResult!.moonSign.symbol,
                              'Ay',
                              signName: horoscopeProvider.risingSignResult!.moonSign.displayName,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  AnimatedCard(
                    delay: 300.ms,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSection(
                          Icons.person,
                          'Kişilik',
                          horoscopeProvider.risingSignResult!.personality,
                          isDark,
                        ),
                        const Divider(height: 24),
                        _buildSection(
                          Icons.star,
                          'Güçlü Yönler',
                          horoscopeProvider.risingSignResult!.strengths,
                          isDark,
                        ),
                        const Divider(height: 24),
                        _buildSection(
                          Icons.warning_amber,
                          'Zayıf Yönler',
                          horoscopeProvider.risingSignResult!.weaknesses,
                          isDark,
                        ),
                        const Divider(height: 24),
                        _buildSection(
                          Icons.explore,
                          'Hayata Yaklaşım',
                          horoscopeProvider.risingSignResult!.lifeApproach,
                          isDark,
                        ),
                        const Divider(height: 24),
                        _buildSection(
                          Icons.favorite,
                          'İlişkiler',
                          horoscopeProvider.risingSignResult!.relationships,
                          isDark,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignBadge(String symbol, String label, {String? signName}) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              symbol,
              style: const TextStyle(fontSize: 32),
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (signName != null) ...[
          Text(
            signName,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
        ],
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildSection(IconData icon, String title, String content, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.accentPurple, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textPrimary : AppColors.textDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            fontSize: 14,
            height: 1.6,
            color: isDark ? AppColors.textSecondary : AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}
