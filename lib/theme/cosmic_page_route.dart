import 'package:flutter/material.dart';

/// Zodi uygulaması için kozmik sayfa geçiş animasyonu.
/// Slide-up + fade + hafif scale efekti ile akıcı geçiş sağlar.
class CosmicPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  CosmicPageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 350),
          reverseTransitionDuration: const Duration(milliseconds: 280),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Simplified: slide-up + fade (removed nested Scale for performance)
            final slideTween = Tween<Offset>(
              begin: const Offset(0.0, 0.06),
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.easeOutCubic));

            final fadeTween = Tween<double>(begin: 0.0, end: 1.0)
                .chain(CurveTween(curve: Curves.easeOut));

            return SlideTransition(
              position: slideTween.animate(animation),
              child: FadeTransition(
                opacity: fadeTween.animate(animation),
                child: child,
              ),
            );
          },
        );
}

/// Premium ekran için özel geçiş - aşağıdan yukarı sheet tarzı
class CosmicBottomSheetRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  CosmicBottomSheetRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 400),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final slideTween = Tween<Offset>(
              begin: const Offset(0.0, 1.0),
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.easeOutQuart));

            final fadeTween = Tween<double>(begin: 0.0, end: 1.0)
                .chain(CurveTween(curve: const Interval(0.0, 0.5)));

            return SlideTransition(
              position: slideTween.animate(animation),
              child: FadeTransition(
                opacity: fadeTween.animate(animation),
                child: child,
              ),
            );
          },
        );
}

/// Fade-through geçiş - tab değişimleri ve benzer ekranlar arası
class CosmicFadeRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  CosmicFadeRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 250),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final fadeTween = Tween<double>(begin: 0.0, end: 1.0)
                .chain(CurveTween(curve: Curves.easeInOut));

            final scaleTween = Tween<double>(begin: 0.95, end: 1.0)
                .chain(CurveTween(curve: Curves.easeOutCubic));

            return FadeTransition(
              opacity: fadeTween.animate(animation),
              child: ScaleTransition(
                scale: scaleTween.animate(animation),
                child: child,
              ),
            );
          },
        );
}
