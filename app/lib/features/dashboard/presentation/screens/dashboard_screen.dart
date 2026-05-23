import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

import '../../../../shared/widgets/activity_tile.dart';
import '../../../../shared/widgets/bottom_navbar.dart';
import '../../../../shared/widgets/glow_container.dart';
import '../../../../shared/widgets/stat_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

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
            child: GlowContainer(size: 260, color: AppColors.primary),
          ),

          Positioned(
            bottom: 140,
            left: -100,
            child: GlowContainer(size: 240, color: AppColors.purple),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // LEFT TEXTS
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Welcome Back,",
                            style: AppTextStyles.bodyMedium,
                          ),

                          const SizedBox(height: 4),

                          Text("Ishika 👋", style: AppTextStyles.heading2),
                        ],
                      ),

                      // PROFILE AVATAR
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary.withOpacity(0.15),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.25),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            "IK",
                            style: AppTextStyles.titleMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // HERO CARD
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(26),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Total Assets", style: AppTextStyles.bodyMedium),

                        const SizedBox(height: 12),

                        Text("\$128,450", style: AppTextStyles.heading2),

                        const SizedBox(height: 18),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "Vault Protected",
                            style: AppTextStyles.successText,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // OVERVIEW
                  Text("Overview", style: AppTextStyles.titleLarge),

                  const SizedBox(height: 20),

                  // STATS GRID
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          title: "Beneficiaries",
                          value: "04",
                          icon: LucideIcons.users,
                          iconColor: AppColors.purple,
                        ),
                      ),

                      const SizedBox(width: 16),

                      Expanded(
                        child: StatCard(
                          title: "Transactions",
                          value: "128",
                          icon: LucideIcons.arrowLeftRight,
                          iconColor: AppColors.primary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          title: "AI Status",
                          value: "Active",
                          icon: LucideIcons.bot,
                          iconColor: AppColors.primary,
                        ),
                      ),

                      const SizedBox(width: 16),

                      Expanded(
                        child: StatCard(
                          title: "Security",
                          value: "Strong",
                          icon: LucideIcons.shieldCheck,
                          iconColor: AppColors.success,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // RECENT ACTIVITY
                  Text("Recent Activity", style: AppTextStyles.titleLarge),

                  const SizedBox(height: 18),

                  ActivityTile(
                    icon: LucideIcons.shieldCheck,
                    iconColor: AppColors.success,
                    title: "Vault Updated",
                    subtitle: "Security settings modified",
                    time: "2 mins ago",
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
            child: BottomNavbar(currentIndex: 0),
          ),
        ],
      ),
    );
  }
}
