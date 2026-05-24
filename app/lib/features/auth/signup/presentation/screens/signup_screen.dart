import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../../core/services/auth_service.dart';
import '../../../../../core/services/firestore_service.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

import '../../../../../shared/widgets/custom_text_field.dart';
import '../../../../../shared/widgets/primary_button.dart';

import '../../../../dashboard/presentation/screens/dashboard_screen.dart';
import '../../../login/presentation/screens/login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // CONTROLLERS

  final TextEditingController fullNameController = TextEditingController();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final TextEditingController confirmPasswordController =
      TextEditingController();

  // SERVICES

  final AuthService _authService = AuthService();

  final FirestoreService _firestoreService = FirestoreService();

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
              Text("Create Account", style: AppTextStyles.heading1),

              const SizedBox(height: 10),

              Text(
                "Secure your digital legacy",
                style: AppTextStyles.bodyMedium,
              ),

              const SizedBox(height: 50),

              // FULL NAME FIELD
              CustomTextField(
                controller: fullNameController,

                hintText: "Enter Full Name",
              ),

              const SizedBox(height: 22),

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

                hintText: "Create Password",

                obscureText: true,
              ),

              const SizedBox(height: 22),

              // CONFIRM PASSWORD FIELD
              CustomTextField(
                controller: confirmPasswordController,

                hintText: "Confirm Password",

                obscureText: true,
              ),

              const SizedBox(height: 36),

              // SIGNUP BUTTON
              PrimaryButton(
                text: isLoading ? "Loading..." : "Continue Securely",

                onTap: () async {
                  // PASSWORD MATCH CHECK

                  if (passwordController.text.trim() !=
                      confirmPasswordController.text.trim()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Passwords do not match")),
                    );

                    return;
                  }

                  setState(() {
                    isLoading = true;
                  });

                  try {
                    // FIREBASE AUTH SIGNUP

                    final userCredential = await _authService.signUp(
                      email: emailController.text.trim(),

                      password: passwordController.text.trim(),
                    );

                    // CREATE FIRESTORE USER DOCUMENT

                    await _firestoreService.createUser(
                      uid: userCredential.user!.uid,

                      email: emailController.text.trim(),

                      fullName: fullNameController.text.trim(),
                    );

                    if (!context.mounted) return;

                    // NAVIGATE TO DASHBOARD

                    Navigator.pushReplacement(
                      context,

                      MaterialPageRoute(
                        builder: (_) => const DashboardScreen(),
                      ),
                    );
                  } on FirebaseAuthException catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.message ?? "Signup Failed")),
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

              // LOGIN NAVIGATION
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

                        MaterialPageRoute(builder: (_) => const LoginScreen()),
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

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
