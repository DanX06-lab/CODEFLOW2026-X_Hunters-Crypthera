import 'package:flutter/material.dart';

import 'core/theme/app_colors.dart';

import 'features/splash/presentation/screens/splash_screen.dart';

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

      home: const SplashScreen(),
    );
  }
}
