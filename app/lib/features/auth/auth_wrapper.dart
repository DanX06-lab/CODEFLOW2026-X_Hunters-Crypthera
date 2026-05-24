import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../dashboard/presentation/screens/dashboard_screen.dart';

import 'login/presentation/screens/login_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),

      builder: (context, snapshot) {
        // LOADING

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // USER LOGGED IN

        if (snapshot.hasData) {
          return const DashboardScreen();
        }

        // USER NOT LOGGED IN

        return const LoginScreen();
      },
    );
  }
}
