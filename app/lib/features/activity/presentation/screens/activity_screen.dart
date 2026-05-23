import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

import '../../../../shared/widgets/activity_tile.dart';
import '../../../../shared/widgets/bottom_navbar.dart';
import '../../../../shared/widgets/glow_container.dart';

import '../../../ai_assistant/presentation/screens/ai_assistant_screen.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: Stack(
        children: [
          // GLOW EFFECTS
          Positioned(
            top: -80,
            right: -80,
            child: GlowContainer(size: 240, color: AppColors.primary),
          ),

          Positioned(
            bottom: 120,
            left: -100,
            child: GlowContainer(size: 220, color: AppColors.purple),
          ),

          // MAIN CONTENT
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),

                  // HEADER
                  Text("Activity", style: AppTextStyles.heading2),

                  const SizedBox(height: 8),

                  Text(
                    "Track all vault and security activity",
                    style: AppTextStyles.bodyMedium,
                  ),

                  const SizedBox(height: 30),

                  // FILTERS
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilter(text: "All", isActive: true),

                        const SizedBox(width: 12),

                        _buildFilter(text: "Transfers", isActive: false),

                        const SizedBox(width: 12),

                        _buildFilter(text: "Security", isActive: false),

                        const SizedBox(width: 12),

                        _buildFilter(text: "Vault", isActive: false),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ACTIVITIES
                  ActivityTile(
                    icon: LucideIcons.shieldCheck,
                    iconColor: AppColors.success,
                    title: "Vault Updated",
                    subtitle: "Security settings modified",
                    time: "2 mins ago",
                  ),

                  const SizedBox(height: 16),

                  ActivityTile(
                    icon: LucideIcons.users,
                    iconColor: AppColors.purple,
                    title: "Beneficiary Added",
                    subtitle: "Allocation updated to 25%",
                    time: "1 hour ago",
                  ),

                  const SizedBox(height: 16),

                  ActivityTile(
                    icon: LucideIcons.arrowLeftRight,
                    iconColor: AppColors.primary,
                    title: "Asset Transfer Completed",
                    subtitle: "0.42 BTC transferred securely",
                    time: "Yesterday",
                  ),

                  const SizedBox(height: 16),

                  ActivityTile(
                    icon: LucideIcons.bot,
                    iconColor: AppColors.primary,
                    title: "AI Security Recommendation",
                    subtitle: "Suggested inactivity timer adjustment",
                    time: "2 days ago",
                  ),

                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),

          // FLOATING AI BUTTON
          Positioned(
            right: 26,
            bottom: 100,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 40,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                LucideIcons.bot,
                color: AppColors.background,
                size: 28,
              ),
            ),
          ),

          // NAVBAR
          const Align(
            alignment: Alignment.bottomCenter,
            child: BottomNavbar(currentIndex: 2),
          ),
        ],
      ),
    );
  }

  Widget _buildFilter({required String text, required bool isActive}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? Colors.transparent : AppColors.stroke,
        ),
      ),
      child: Text(
        text,
        style: AppTextStyles.bodyMedium.copyWith(
          color: isActive ? AppColors.background : AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
