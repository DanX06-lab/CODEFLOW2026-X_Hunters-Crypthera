import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

import '../../../../shared/widgets/glow_container.dart';

class AiAssistantScreen extends StatelessWidget {
  const AiAssistantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: Stack(
        children: [
          // GLOW EFFECTS
          Positioned(
            top: -100,
            right: -100,
            child: GlowContainer(size: 280, color: AppColors.primary),
          ),

          Positioned(
            bottom: 120,
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
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.card,
                          border: Border.all(color: AppColors.stroke),
                        ),
                        child: const Icon(
                          LucideIcons.arrowLeft,
                          color: AppColors.textPrimary,
                          size: 20,
                        ),
                      ),

                      const SizedBox(width: 16),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("AI Assistant", style: AppTextStyles.titleLarge),

                          const SizedBox(height: 4),

                          Text(
                            "Crypthera Intelligence",
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // AI CARD
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(26),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Column(
                      children: [
                        // BOT ICON
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary.withOpacity(0.15),
                          ),
                          child: const Icon(
                            LucideIcons.bot,
                            color: AppColors.primary,
                            size: 40,
                          ),
                        ),

                        const SizedBox(height: 22),

                        Text("Crypthera AI", style: AppTextStyles.heading3),

                        const SizedBox(height: 12),

                        Text(
                          "Analyze risks, monitor inactivity, and optimize your vault security intelligently.",
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // SUGGESTED QUESTIONS
                  Text("Suggested Questions", style: AppTextStyles.titleLarge),

                  const SizedBox(height: 20),

                  _buildQuestionChip("How secure is my vault?"),

                  const SizedBox(height: 14),

                  _buildQuestionChip("Optimize inactivity timer"),

                  const SizedBox(height: 14),

                  _buildQuestionChip("Show beneficiary risk analysis"),

                  const SizedBox(height: 40),

                  // INPUT BOX
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                            ),
                            decoration: InputDecoration(
                              hintText: "Ask Crypthera AI...",
                              hintStyle: AppTextStyles.bodyMedium,
                              border: InputBorder.none,
                            ),
                          ),
                        ),

                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary,
                          ),
                          child: const Icon(
                            LucideIcons.send,
                            color: AppColors.background,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionChip(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Text(
        text,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
