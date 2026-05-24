import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

import '../../../../../shared/widgets/bottom_navbar.dart';

import '../../../auth/login/presentation/screens/login_screen.dart';
import '../../../ai_assistant/presentation/screens/ai_assistant_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: SafeArea(
        child: Stack(
          children: [
            // MAIN CONTENT
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 26),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  const SizedBox(height: 20),

                  // HEADER
                  Text("Profile", style: AppTextStyles.heading2),

                  const SizedBox(height: 30),

                  // PROFILE CARD
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),

                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(28),
                    ),

                    child: Column(
                      children: [
                        // AVATAR
                        Container(
                          width: 90,
                          height: 90,

                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary.withOpacity(0.15),
                          ),

                          child: const Icon(
                            LucideIcons.user,
                            color: AppColors.primary,
                            size: 42,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // NAME
                        Text("Crypthera User", style: AppTextStyles.heading3),

                        const SizedBox(height: 8),

                        // EMAIL
                        Text(
                          FirebaseAuth.instance.currentUser?.email ??
                              "No Email",

                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 34),

                  // SETTINGS TITLE
                  Text("Settings", style: AppTextStyles.titleLarge),

                  const SizedBox(height: 20),

                  // AI ASSISTANT
                  _buildProfileOption(
                    context: context,
                    icon: LucideIcons.bot,
                    title: "AI Assistant",

                    onTap: () {
                      Navigator.push(
                        context,

                        MaterialPageRoute(
                          builder: (_) => const AiAssistantScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // SECURITY
                  _buildProfileOption(
                    context: context,
                    icon: LucideIcons.shield,
                    title: "Security",
                  ),

                  const SizedBox(height: 16),

                  // NOTIFICATIONS
                  _buildProfileOption(
                    context: context,
                    icon: LucideIcons.bell,
                    title: "Notifications",
                  ),

                  const SizedBox(height: 16),

                  // LOGOUT
                  _buildProfileOption(
                    context: context,
                    icon: LucideIcons.logOut,
                    title: "Logout",

                    onTap: () async {
                      await FirebaseAuth.instance.signOut();

                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,

                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),

                          (route) => false,
                        );
                      }
                    },
                  ),

                  const SizedBox(height: 120),
                ],
              ),
            ),

            // AI BUTTON
            Positioned(
              right: 26,
              bottom: 100,

              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,

                    MaterialPageRoute(
                      builder: (_) => const AiAssistantScreen(),
                    ),
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
      ),
    );
  }

  Widget _buildProfileOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),

        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),

          border: Border.all(color: AppColors.stroke),
        ),

        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 22),

            const SizedBox(width: 16),

            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,

                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            Icon(
              LucideIcons.chevronRight,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
