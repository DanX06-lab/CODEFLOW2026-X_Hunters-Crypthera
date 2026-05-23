import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors.dart';

import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/vault/presentation/screens/vault_screen.dart';
import '../../features/activity/presentation/screens/activity_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';

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
          // HOME
          _buildNavItem(
            context: context,
            icon: LucideIcons.home,
            isActive: currentIndex == 0,
            screen: const DashboardScreen(),
          ),

          // VAULT
          _buildNavItem(
            context: context,
            icon: LucideIcons.shield,
            isActive: currentIndex == 1,
            screen: const VaultScreen(),
          ),

          // ACTIVITY
          _buildNavItem(
            context: context,
            icon: LucideIcons.activity,
            isActive: currentIndex == 2,
            screen: const ActivityScreen(),
          ),

          // PROFILE
          _buildNavItem(
            context: context,
            icon: LucideIcons.user,
            isActive: currentIndex == 3,
            screen: const ProfileScreen(),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required bool isActive,
    required Widget screen,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => screen),
        );
      },

      child: Icon(
        icon,
        color: isActive ? AppColors.primary : AppColors.textSecondary,
        size: 24,
      ),
    );
  }
}
