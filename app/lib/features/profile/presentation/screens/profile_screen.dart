import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

import '../../../../shared/widgets/bottom_navbar.dart';
import '../../../../shared/widgets/glow_container.dart';

import '../../../ai_assistant/presentation/screens/ai_assistant_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: Stack(
        children: [
          // GLOWS
          Positioned(
            top: -80,
            right: -80,
            child: GlowContainer(size: 260, color: AppColors.primary),
          ),

          Positioned(
            bottom: 120,
            left: -100,
            child: GlowContainer(size: 240, color: AppColors.purple),
          ),

          // CONTENT
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),

                  // HEADER
                  Text("Profile & Security", style: AppTextStyles.heading2),

                  const SizedBox(height: 8),

                  Text(
                    "Manage your vault protection settings",
                    style: AppTextStyles.bodyMedium,
                  ),

                  const SizedBox(height: 30),

                  // PROFILE CARD
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Row(
                      children: [
                        // AVATAR
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary.withOpacity(0.15),
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

                        const SizedBox(width: 18),

                        // USER INFO
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Ishika Kundu",
                              style: AppTextStyles.titleLarge,
                            ),

                            const SizedBox(height: 6),

                            Text(
                              "ishika@crypthera.app",
                              style: AppTextStyles.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // SECURITY OPTIONS
                  _buildSecurityTile(
                    icon: LucideIcons.shieldCheck,
                    iconColor: AppColors.success,
                    title: "Two-Factor Authentication",
                    subtitle: "Enabled",
                  ),

                  const SizedBox(height: 16),

                  _buildSecurityTile(
                    icon: LucideIcons.fingerprint,
                    iconColor: AppColors.primary,
                    title: "Biometric Lock",
                    subtitle: "Active",
                  ),

                  const SizedBox(height: 16),

                  _buildSecurityTile(
                    icon: LucideIcons.smartphone,
                    iconColor: AppColors.purple,
                    title: "Trusted Devices",
                    subtitle: "2 Devices Connected",
                  ),

                  const SizedBox(height: 16),

                  _buildSecurityTile(
                    icon: LucideIcons.alertTriangle,
                    iconColor: AppColors.danger,
                    title: "Recovery Phrase",
                    subtitle: "Stored Securely",
                  ),

                  const SizedBox(height: 30),

                  // LOGOUT BUTTON
                  Container(
                    width: double.infinity,
                    height: 58,
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.stroke),
                    ),
                    child: Center(
                      child: Text(
                        "Logout Securely",
                        style: AppTextStyles.titleMedium,
                      ),
                    ),
                  ),

                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),

          Positioned(
            right: 26,
            bottom: 100,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AiAssistantScreen()),
                );
              },

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
          ),
          // NAVBAR
          const Align(
            alignment: Alignment.bottomCenter,
            child: BottomNavbar(currentIndex: 3),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          // ICON
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconColor.withOpacity(0.15),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),

          const SizedBox(width: 16),

          // TEXTS
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.titleSmall),

                const SizedBox(height: 6),

                Text(subtitle, style: AppTextStyles.bodySmall),
              ],
            ),
          ),

          const Icon(
            LucideIcons.chevronRight,
            color: AppColors.textSecondary,
            size: 20,
          ),
        ],
      ),
    );
  }
}
