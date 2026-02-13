import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ZodiLogo extends StatelessWidget {
  final double size;
  
  const ZodiLogo({super.key, this.size = 48});
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.violet400,
                AppColors.purple400,
                AppColors.fuchsia400,
              ],
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Animasyonlu yıldız arka planı
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        AppColors.yellow300.withOpacity(0.2),
                        AppColors.pink300.withOpacity(0.2),
                      ],
                    ),
                  ),
                ),
              ),
              Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: size * 0.45,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [AppColors.violet600, AppColors.fuchsia600],
          ).createShader(bounds),
          child: Text(
            'Zodi',
            style: TextStyle(
              fontSize: size * 0.5,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
