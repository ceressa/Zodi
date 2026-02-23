import 'package:flutter/material.dart';

/// Sabit alt buton çubuğu — Paylaş, Kaydet gibi butonları ekranın altına sabitler.
/// Bu widget her sonuç ekranında kullanılmalıdır!
///
/// Kullanım:
/// ```dart
/// Scaffold(
///   bottomNavigationBar: StickyBottomActions(
///     children: [
///       StickyBottomActions.primaryButton(
///         label: 'Paylaş',
///         icon: Icons.share_rounded,
///         gradient: [Color(0xFF7C3AED), Color(0xFFA78BFA)],
///         onTap: _share,
///       ),
///       StickyBottomActions.iconButton(
///         icon: Icons.download_rounded,
///         color: Color(0xFF7C3AED),
///         onTap: _save,
///       ),
///     ],
///   ),
/// )
/// ```
class StickyBottomActions extends StatelessWidget {
  final List<Widget> children;

  const StickyBottomActions({super.key, required this.children});

  /// Gradient arka planlı ana buton
  static Widget primaryButton({
    required String label,
    required IconData icon,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Kare ikon buton (tekrar dene, kaydet vb.)
  static Widget iconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    String? tooltip,
  }) {
    return Container(
      height: 50,
      width: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Icon(icon, color: color),
        ),
      ),
    );
  }

  /// Outline buton (kaydet vb.)
  static Widget outlineButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F5FF),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: children.expand((w) sync* {
          final idx = children.indexOf(w);
          if (idx > 0) yield const SizedBox(width: 12);
          yield w;
        }).toList(),
      ),
    );
  }
}
