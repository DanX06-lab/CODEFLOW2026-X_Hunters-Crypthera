import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../../core/services/auth_service.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

import '../../../../../shared/widgets/custom_text_field.dart';
import '../../../../../shared/widgets/primary_button.dart';

import '../../../../dashboard/presentation/screens/dashboard_screen.dart';
import '../../../signup/presentation/screens/signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final AuthService _authService = AuthService();

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 26),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 70),

              // TITLE
              Text("Welcome Back", style: AppTextStyles.heading1),

              const SizedBox(height: 10),

              Text(
                "Securely access your digital vault",
                style: AppTextStyles.bodyMedium,
              ),

              const SizedBox(height: 50),

              // EMAIL FIELD
              CustomTextField(
                controller: emailController,
                hintText: "Enter Email",
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 22),

              // PASSWORD FIELD
              CustomTextField(
                controller: passwordController,
                hintText: "Enter Password",
                obscureText: true,
              ),

              const SizedBox(height: 36),

              // LOGIN BUTTON
              PrimaryButton(
                text: isLoading ? "Loading..." : "Continue Securely",

                onTap: () async {
                  setState(() {
                    isLoading = true;
                  });

                  try {
                    await _authService.login(
                      email: emailController.text.trim(),

                      password: passwordController.text.trim(),
                    );

                    if (!context.mounted) return;
                    Navigator.pushReplacement(
                      context,

                      MaterialPageRoute(
                        builder: (_) => const DashboardScreen(),
                      ),
                    );
                  } on FirebaseAuthException catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.message ?? "Login Failed")),
                    );
                  } finally {
                    if (mounted) {
                      setState(() {
                        isLoading = false;
                      });
                    }
                  }
                },
              ),

              const SizedBox(height: 28),

              // SIGNUP NAVIGATION
              Row(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  Text(
                    "Don't have an account? ",
                    style: AppTextStyles.bodyMedium,
                  ),

                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,

                        MaterialPageRoute(builder: (_) => const SignupScreen()),
                      );
                    },

                    child: Text(
                      "Sign Up",

                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,

                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
