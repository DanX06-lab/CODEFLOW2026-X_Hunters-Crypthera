import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

import 'core/theme/app_colors.dart';
import 'features/splash/presentation/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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
