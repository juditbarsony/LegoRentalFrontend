import 'package:flutter/material.dart';
import 'features/auth/login_screen.dart';
//import 'features/home/home_screen.dart'; // ha már lesz ilyen
import 'features/auth/signup_screen.dart';
import 'features/main/main_screen.dart';
import 'features/set_detail/set_detail_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(
    const ProviderScope(
      child: LegoRentalApp(),
    ),
  );
}


class LegoRentalApp extends StatelessWidget {
  const LegoRentalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      //initialRoute: '/set-detail',
      routes: {
        '/login': (_) => const LoginScreen(),
        '/signup': (_) => const SignUpScreen(),
        '/main': (_) => const MainScreen(),
        '/set-detail': (_) => const SetDetailScreen(),
      },
    );
  }
}
