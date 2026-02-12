import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/colors.dart';

class AnimatedCard extends StatelessWidget {
  final Widget child;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final double? elevation;
  final Duration? delay;

  const AnimatedCard({
    super.key,
    required this.child,
    this.gradient,
    this.onTap,
    this.padding,
    this.elevation,
    this.delay,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient == null ? (isDark ? AppColors.cardDark : AppColors.cardLight) : null,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (gradient != null ? AppColors.accentPurple : Colors.black)
                .withOpacity(0.1),
            blurRadius: elevation ?? 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(20),
            child: child,
          ),
        ),
      ),
    )
        .animate(delay: delay ?? Duration.zero)
        .fadeIn(duration: 400.ms, curve: Curves.easeOut)
        .slideY(begin: 0.2, end: 0, duration: 400.ms, curve: Curves.easeOut)
        .scale(begin: const Offset(0.95, 0.95), duration: 400.ms);
  }
}
