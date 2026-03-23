import 'package:flutter/material.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/signup_screen.dart';
import 'features/main/main_screen.dart';



class LegoRentalApp extends StatelessWidget {
  const LegoRentalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginScreen(),
        '/signup': (_) => const SignUpScreen(),
        '/main': (_) => const MainScreen(),
      },
    );
  }
}