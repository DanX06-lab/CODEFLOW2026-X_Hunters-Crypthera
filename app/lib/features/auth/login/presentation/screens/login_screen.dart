import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

import '../../../../../shared/widgets/custom_text_field.dart';
import '../../../../../shared/widgets/glow_container.dart';
import '../../../../../shared/widgets/primary_button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // GLOW EFFECTS
          Positioned(
            top: 40,
            right: -40,
            child: GlowContainer(size: 220, color: AppColors.primary),
          ),

          Positioned(
            bottom: 80,
            left: -60,
            child: GlowContainer(size: 220, color: AppColors.purple),
          ),

          // CONTENT
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 70),

                  // TITLE
                  Text("Welcome Back", style: AppTextStyles.heading2),

                  const SizedBox(height: 10),

                  Text(
                    "Access your secure digital vault",
                    style: AppTextStyles.bodyMedium,
                  ),

                  const SizedBox(height: 60),

                  // EMAIL
                  const CustomTextField(hintText: "Enter email"),

                  const SizedBox(height: 20),

                  // PASSWORD
                  const CustomTextField(
                    hintText: "Enter password",
                    obscureText: true,
                  ),

                  const SizedBox(height: 40),

                  // LOGIN BUTTON
                  PrimaryButton(text: "Continue Securely", onTap: () {}),

                  const SizedBox(height: 20),

                  // CONNECT WALLET BUTTON
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.stroke),
                    ),
                    child: Center(
                      child: Text(
                        "Connect Wallet",
                        style: AppTextStyles.titleMedium,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // SIGNUP
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: AppTextStyles.bodyMedium,
                      ),
                      Text(
                        "Sign Up",
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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
}
