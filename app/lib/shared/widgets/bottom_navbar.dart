import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors.dart';

class BottomNavbar extends StatelessWidget {
  final int currentIndex;

  const BottomNavbar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 82,
      padding: const EdgeInsets.symmetric(horizontal: 30),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.stroke)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavItem(icon: LucideIcons.home, isActive: currentIndex == 0),

          _buildNavItem(icon: LucideIcons.shield, isActive: currentIndex == 1),

          _buildNavItem(
            icon: LucideIcons.activity,
            isActive: currentIndex == 2,
          ),

          _buildNavItem(icon: LucideIcons.user, isActive: currentIndex == 3),
        ],
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required bool isActive}) {
    return Icon(
      icon,
      color: isActive ? AppColors.primary : AppColors.textSecondary,
      size: 24,
    );
  }
}
