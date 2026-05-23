import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

import '../../../../shared/widgets/beneficiary_tile.dart';
import '../../../../shared/widgets/bottom_navbar.dart';
import '../../../../shared/widgets/glow_container.dart';

class VaultScreen extends StatelessWidget {
  const VaultScreen({super.key});

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
            bottom: 100,
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
                  Text("Digital Vault", style: AppTextStyles.heading2),

                  const SizedBox(height: 8),

                  Text(
                    "Secure and automate your crypto inheritance",
                    style: AppTextStyles.bodyMedium,
                  ),

                  const SizedBox(height: 30),

                  // VAULT STATUS CARD
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Vault Status", style: AppTextStyles.bodyMedium),

                        const SizedBox(height: 12),

                        Text(
                          "Protected",
                          style: AppTextStyles.heading3.copyWith(
                            color: AppColors.success,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          "Connected Wallet",
                          style: AppTextStyles.bodySmall,
                        ),

                        const SizedBox(height: 4),

                        Text("0x4F...9A21", style: AppTextStyles.titleSmall),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // BENEFICIARIES
                  Text("Beneficiaries", style: AppTextStyles.titleLarge),

                  const SizedBox(height: 20),

                  BeneficiaryTile(
                    initials: "SB",
                    name: "Souvik Biswas",
                    allocation: "40% Allocation",
                    progress: 0.40,
                    progressColor: AppColors.primary,
                  ),

                  const SizedBox(height: 16),

                  BeneficiaryTile(
                    initials: "AK",
                    name: "Amita Kundu",
                    allocation: "30% Allocation",
                    progress: 0.30,
                    progressColor: AppColors.purple,
                  ),

                  const SizedBox(height: 30),

                  // EMERGENCY PROTOCOL
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Emergency Protocol",
                              style: AppTextStyles.titleMedium,
                            ),

                            const Spacer(),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.success.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "Active",
                                style: AppTextStyles.successText,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        Text(
                          "Auto-transfer triggers after inactivity verification",
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // INACTIVITY TIMER
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary.withOpacity(0.15),
                          ),
                          child: const Icon(
                            LucideIcons.clock3,
                            color: AppColors.primary,
                          ),
                        ),

                        const SizedBox(width: 16),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Inactivity Timer",
                              style: AppTextStyles.titleMedium,
                            ),

                            const SizedBox(height: 6),

                            Text("90 Days", style: AppTextStyles.bodyMedium),
                          ],
                        ),
                      ],
                    ),
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
            child: BottomNavbar(currentIndex: 1),
          ),
        ],
      ),
    );
  }
}
