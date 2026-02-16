import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/theme_service.dart';
import '../models/theme_config.dart';
import '../constants/colors.dart';
import '../theme/cosmic_page_route.dart';
import 'premium_screen.dart';

class ThemeCustomizationScreen extends StatefulWidget {
  const ThemeCustomizationScreen({super.key});

  @override
  State<ThemeCustomizationScreen> createState() => _ThemeCustomizationScreenState();
}

class _ThemeCustomizationScreenState extends State<ThemeCustomizationScreen> {
  final ThemeService _themeService = ThemeService();
  String? _selectedZodiac;
  AnimationType _selectedAnimation = AnimationType.none;
  String? _selectedFont;
  bool _isLoading = true;

  final List<String> _availableFonts = [
    'Default',
    'Roboto',
    'Lato',
    'Montserrat',
    'Playfair Display',
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentTheme();
  }

  Future<void> _loadCurrentTheme() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final userId = authProvider.userId;

      if (userId != null) {
        final theme = await _themeService.getUserTheme(userId);
        
        if (theme != null && mounted) {
          setState(() {
            _selectedZodiac = theme.zodiacSign;
            _selectedAnimation = theme.backgroundAnimation;
            _selectedFont = theme.fontFamily ?? 'Default';
          });
        }
      }
    } catch (e) {
      print('Error loading theme: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _applyTheme() async {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.userId;

    if (userId == null || _selectedZodiac == null) return;

    try {
      final colors = _themeService.getZodiacColors(_selectedZodiac!);
      
      final config = ThemeConfig(
        zodiacSign: _selectedZodiac!,
        colorScheme: ColorScheme.fromSeed(
          seedColor: colors.primary,
          brightness: Theme.of(context).brightness,
        ),
        backgroundAnimation: _selectedAnimation,
        fontFamily: _selectedFont == 'Default' ? null : _selectedFont,
        darkMode: Theme.of(context).brightness == Brightness.dark,
      );

      await _themeService.applyTheme(userId, config);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✨ Tema uygulandı!'),
            backgroundColor: AppColors.positive,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error applying theme: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Tema uygulanırken hata oluştu'),
            backgroundColor: AppColors.negative,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        title: const Text('Tema Özelleştirme'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _applyTheme,
              child: const Text(
                'Uygula',
                style: TextStyle(
                  color: AppColors.accentPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Zodiac Theme Selection
                  _buildSectionTitle('Burç Teması', Icons.palette),
                  const SizedBox(height: 16),
                  _buildZodiacThemeGrid(),
                  const SizedBox(height: 32),

                  // Animated Background (Premium)
                  _buildSectionTitle('Animasyonlu Arkaplan', Icons.auto_awesome),
                  const SizedBox(height: 8),
                  if (!authProvider.isPremium)
                    _buildPremiumBadge()
                  else
                    _buildAnimationSelector(),
                  const SizedBox(height: 32),

                  // Custom Font (VIP)
                  _buildSectionTitle('Özel Font', Icons.font_download),
                  const SizedBox(height: 8),
                  if (!authProvider.isPremium)
                    _buildVIPBadge()
                  else
                    _buildFontSelector(),
                  const SizedBox(height: 32),

                  // Preview
                  _buildSectionTitle('Önizleme', Icons.visibility),
                  const SizedBox(height: 16),
                  _buildPreview(),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Icon(icon, color: AppColors.accentPurple, size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildZodiacThemeGrid() {
    final themes = _themeService.getAllZodiacThemes();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: themes.length,
      itemBuilder: (context, index) {
        final theme = themes[index];
        final colors = theme['colors'] as ZodiacColorScheme;
        final isSelected = _selectedZodiac == theme['key'];

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedZodiac = theme['key'] as String;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colors.primary, colors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 3,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: colors.primary.withOpacity(0.5),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  theme['name'] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 20,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimationSelector() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: AnimationType.values.map((type) {
        return RadioListTile<AnimationType>(
          value: type,
          groupValue: _selectedAnimation,
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedAnimation = value;
              });
            }
          },
          title: Text(
            _getAnimationName(type),
            style: TextStyle(
              color: isDark ? Colors.white : AppColors.textDark,
            ),
          ),
          activeColor: AppColors.accentPurple,
        );
      }).toList(),
    );
  }

  Widget _buildFontSelector() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: _availableFonts.map((font) {
        return RadioListTile<String>(
          value: font,
          groupValue: _selectedFont,
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedFont = value;
              });
            }
          },
          title: Text(
            font,
            style: TextStyle(
              color: isDark ? Colors.white : AppColors.textDark,
              fontFamily: font == 'Default' ? null : font,
            ),
          ),
          activeColor: AppColors.accentPurple,
        );
      }).toList(),
    );
  }

  Widget _buildPremiumBadge() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accentPurple.withOpacity(0.2),
            AppColors.accentBlue.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accentPurple, width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock, color: AppColors.accentPurple),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('Premium özellik - Animasyonlu arkaplanlar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(context, CosmicBottomSheetRoute(page: const PremiumScreen()));
            },
            child: const Text('Aç'),
          ),
        ],
      ),
    );
  }

  Widget _buildVIPBadge() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.gold.withOpacity(0.2),
            AppColors.gold.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gold, width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.workspace_premium, color: AppColors.gold),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('VIP özellik - Özel fontlar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(context, CosmicBottomSheetRoute(page: const PremiumScreen()));
            },
            child: const Text('Aç'),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    if (_selectedZodiac == null) {
      return const SizedBox();
    }

    final colors = _themeService.getZodiacColors(_selectedZodiac!);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors.primary, colors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Günlük Falın',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: _selectedFont == 'Default' ? null : _selectedFont,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getAnimationName(_selectedAnimation),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getAnimationName(AnimationType type) {
    switch (type) {
      case AnimationType.none:
        return 'Animasyon Yok';
      case AnimationType.particles:
        return 'Parçacıklar';
      case AnimationType.gradient:
        return 'Gradient';
      case AnimationType.constellation:
        return 'Takımyıldızlar';
      case AnimationType.zodiacSymbol:
        return 'Burç Sembolü';
    }
  }
}
