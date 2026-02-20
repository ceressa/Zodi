import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/colors.dart';

class ZodiLoading extends StatelessWidget {
  final String? message;
  
  const ZodiLoading({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Zodi Character
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentPurple.withOpacity(0.3),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Image.asset(
              'assets/astro_dozi_main.webp',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.purpleGradient,
                ),
                child: const Icon(Icons.auto_awesome, size: 60, color: Colors.white),
              ),
            ),
          )
          .animate(onPlay: (controller) => controller.repeat())
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.1, 1.1),
            duration: 1.5.seconds,
            curve: Curves.easeInOut,
          )
          .then()
          .scale(
            begin: const Offset(1.1, 1.1),
            end: const Offset(1, 1),
            duration: 1.5.seconds,
            curve: Curves.easeInOut,
          ),
          
          const SizedBox(height: 32),
          
          // Loading dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.purpleGradient,
                ),
              )
              .animate(onPlay: (controller) => controller.repeat())
              .fadeIn(delay: (index * 200).ms, duration: 600.ms)
              .then()
              .fadeOut(duration: 600.ms);
            }),
          ),
          
          if (message != null) ...[
            const SizedBox(height: 24),
            Text(
              message!,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.textSecondary
                    : AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 300.ms),
          ],
        ],
      ),
    );
  }
}
