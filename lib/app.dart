import 'package:flutter/material.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/signup_screen.dart';
import 'features/main/main_screen.dart';
import 'core/theme/app_theme.dart';

class LegoRentalApp extends StatelessWidget {
  const LegoRentalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginScreen(),
        '/signup': (_) => const SignUpScreen(),
        '/main': (_) => const MainScreen(),
      },
    );
  }
}