import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/onboardingscreen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => OnboardingScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7F7F7), // Background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/splash.gif", width: 300), // Your Logo
            const SizedBox(height: 50),
            // const CircularProgressIndicator(
            //     color: Colors.black), // Loading Animation
          ],
        ),
      ),
    );
  }
}
