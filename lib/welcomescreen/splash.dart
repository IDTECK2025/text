import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:text/login.dart';
import 'package:text/main.dart';
import 'package:text/pin.dart';
import 'dart:async';

import 'package:text/welcomescreen/onboardmain.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: SplashScreen());
  }
}

// Splash Screen
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Navigate to next page after 6 seconds
    Timer(Duration(seconds: 6), () {
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (context) => OnboardingScreen()),
      // );
      _checkAuthStatus();
    });

    _controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check if there's a valid auth token
      final token = prefs.getString('token');
      

      if (token != null && token.isNotEmpty) {
        // User is authenticated, navigate to dashboard
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => BottomNavController(
                   // You can pass null if phoneNumber is optional
                ),
          ),
        );
      } else {
        // No valid token, navigate to login
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => OnboardingScreen()),
        );
      }
    } catch (e) {
      print('Error checking auth status: $e');

      // In case of error, navigate to login
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OnboardingScreen()),
      );
    }
  }

  Widget buildDot(int index) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        double opacity = 0.2;
        int currentDot = (_animation.value * 3).floor() % 3;
        if (index == currentDot) {
          opacity = 1.0;
        }
        return Opacity(
          opacity: opacity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: CircleAvatar(radius: 6, backgroundColor: Colors.white),
          ),
        );
      },
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image.asset('assets/images/image2 (1).png', height: 120),
            SizedBox(height: 30),

            // Welcome Text
           

            SizedBox(height: 30),

            // Loading Dots
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [buildDot(0), buildDot(1), buildDot(2)],
            ),
          ],
        ),
      ),
    );
  }

  // Next Page (HomePage)
}
