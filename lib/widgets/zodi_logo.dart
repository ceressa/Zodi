import 'package:flutter/material.dart';

class ZodiLogo extends StatelessWidget {
  final double size;

  const ZodiLogo({super.key, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.3),
      child: Image.asset(
        'assets/astro_dozi_logo.webp',
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size * 0.3),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF7C3AED), Color(0xFFDB2777)],
            ),
          ),
          child: Icon(
            Icons.auto_awesome,
            color: Colors.white,
            size: size * 0.45,
          ),
        ),
      ),
    );
  }
}
