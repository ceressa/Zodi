import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../constants/colors.dart';

/// Uygulama hakkında ekranı
class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _version = '${info.version} (${info.buildNumber})';
        });
      }
    } catch (_) {
      if (mounted) setState(() => _version = '1.0.0');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5FF),
      appBar: AppBar(
        title: const Text(
          'Hakkında',
          style: TextStyle(
            color: Color(0xFF1E1B4B),
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: const Color(0xFFF8F5FF),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Color(0xFF1E1B4B)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Logo
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  colors: [Color(0xFF7C3AED), Color(0xFFA78BFA)],
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  'assets/astro_dozi_logo_char.webp',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.auto_awesome, size: 48, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'Astro Dozi',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1E1B4B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Sürüm $_version',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF666387),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Kozmik rehberin',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.accentPurple,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 32),

            _buildInfoCard(
              title: 'Hakkımızda',
              content:
                  'Astro Dozi, yapay zeka destekli kişiselleştirilmiş astroloji deneyimi sunan '
                  'bir uygulamadır. Google Gemini AI ve İsviçre Efemeris hesaplamaları ile '
                  'doğru ve kişisel yorumlar sunar.',
            ),

            const SizedBox(height: 16),

            _buildInfoCard(
              title: 'Geliştirici',
              content: 'Bardino Technology\nastrodozi@dozi.app',
            ),

            const SizedBox(height: 16),

            _buildInfoCard(
              title: 'Yasal',
              content:
                  'Tüm astroloji yorumları eğlence amaçlıdır. Kişisel kararlarınızda '
                  'profesyonel tavsiye almanız önerilir.',
            ),

            const SizedBox(height: 32),
            Text(
              '© 2025 Bardino Technology. Tüm hakları saklıdır.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.accentPurple,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1E1B4B),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
