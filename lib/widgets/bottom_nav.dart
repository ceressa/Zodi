import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  
  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });
  
  static const _items = [
    _NavItem(icon: Icons.explore_rounded, label: 'Keşfet'),
    _NavItem(icon: Icons.auto_awesome, label: 'Günlük'),
    _NavItem(icon: Icons.favorite_rounded, label: 'Uyum'),
    _NavItem(icon: Icons.pie_chart_rounded, label: 'Analiz'),
    _NavItem(icon: Icons.person_rounded, label: 'Profil'),
  ];
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        border: const Border(
          top: BorderSide(color: AppColors.purple100, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.purple200.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (i) {
              final item = _items[i];
              final isActive = i == currentIndex;
              
              return GestureDetector(
                onTap: () => onTap(i),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: isActive
                            ? const LinearGradient(
                                colors: [
                                  AppColors.purple100,
                                  AppColors.fuchsia50,
                                ],
                              )
                            : null,
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(
                            item.icon,
                            size: 24,
                            color: isActive
                                ? AppColors.purple600
                                : AppColors.gray400,
                          ),
                          if (isActive)
                            Positioned(
                              top: -4,
                              right: -4,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.purple500,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                        color: isActive
                            ? AppColors.purple600
                            : AppColors.gray400,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  
  const _NavItem({required this.icon, required this.label});
}
