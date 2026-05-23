import 'package:flutter/material.dart';

import 'core/theme/app_colors.dart';
import 'features/splash/presentation/screens/splash_screen.dart';
import 'features/auth/login/presentation/screens/login_screen.dart';
import 'features/auth/signup/presentation/screens/signup_screen.dart';
import 'features/dashboard/presentation/screens/dashboard_screen.dart';
import 'features/vault/presentation/screens/vault_screen.dart';
import 'features/activity/presentation/screens/activity_screen.dart';
import 'features/ai_assistant/presentation/screens/ai_assistant_screen.dart';

void main() {
  runApp(const CryptheraApp());
}

class CryptheraApp extends StatelessWidget {
  const CryptheraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Crypthera',
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
      ),
      home: const AiAssistantScreen(),
    );
  }
}
