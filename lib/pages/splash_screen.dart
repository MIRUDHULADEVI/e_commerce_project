import 'package:flutter/material.dart';
import 'dart:async';
import 'login_page.dart'; // Ensure LoginPage is correctly imported

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(243, 252, 251, 232),
      body: Center(
        child: Image.asset(
          'assets/images/logo.png',  // <- correct path
          width: MediaQuery.of(context).size.width * 0.4,
          height: MediaQuery.of(context).size.width * 0.4,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
