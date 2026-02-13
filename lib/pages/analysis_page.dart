import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/zodi_character.dart';
import '../screens/analysis_screen.dart';

class AnalysisPage extends StatelessWidget {
  const AnalysisPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 8),
          const ZodiCharacter(size: ZodiSize.medium),
          const SizedBox(height: 16),
          ShaderMask(
            shaderCallback: (b) => const LinearGradient(
              colors: [AppColors.violet600, AppColors.fuchsia600],
            ).createShader(b),
            child: const Text(
              'Detaylı Analiz',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Hayatının her alanını keşfet ✨',
            style: TextStyle(
              color: AppColors.purple600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          
          // Mevcut analysis screen'i göster
          const AnalysisScreen(),
        ],
      ),
    );
  }
}
