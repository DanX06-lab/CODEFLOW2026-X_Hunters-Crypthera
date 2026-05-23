import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

import '../../../../../shared/widgets/custom_text_field.dart';
import '../../../../../shared/widgets/glow_container.dart';
import '../../../../../shared/widgets/primary_button.dart';

import '../../../login/presentation/screens/login_screen.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

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
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 70),

                  // TITLE
                  Text("Create Account", style: AppTextStyles.heading2),

                  const SizedBox(height: 10),

                  Text(
                    "Start securing your digital legacy",
                    style: AppTextStyles.bodyMedium,
                  ),

                  const SizedBox(height: 50),

                  // FULL NAME
                  const CustomTextField(hintText: "Full name"),

                  const SizedBox(height: 20),

                  // EMAIL
                  const CustomTextField(hintText: "Enter email"),

                  const SizedBox(height: 20),

                  // PASSWORD
                  const CustomTextField(
                    hintText: "Create password",
                    obscureText: true,
                  ),

                  const SizedBox(height: 20),

                  // CONFIRM PASSWORD
                  const CustomTextField(
                    hintText: "Confirm password",
                    obscureText: true,
                  ),

                  const SizedBox(height: 40),

                  // BUTTON
                  PrimaryButton(text: "Continue Securely", onTap: () {}),

                  const SizedBox(height: 40),

                  // LOGIN TEXT
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account? ",
                        style: AppTextStyles.bodyMedium,
                      ),

                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                        },

                        child: Text(
                          "Login",
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
