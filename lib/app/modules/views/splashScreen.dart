import 'package:flutter/material.dart';
import 'package:lets_do_it/app/modules/views/homeScreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Delayed navigation to HomeScreen after 3 seconds
    Future.delayed(const Duration(seconds: 2), () {
      // Use `mounted` to check if the widget is still in the tree
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF326AFF),
              Color(0xFF30ABF3),
            ],
          ),
        ),
        child: const Center(
          child: SizedBox(
            width: double.infinity, // Take full width
            child: Text(
              'Lets Do It 👊',
              style: TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center, // Center align the text
            ),
          ),
        ),
      ),
    );
  }
}
