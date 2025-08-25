import 'package:flutter/material.dart';
import 'package:tiktok_clone/services/splash_service.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  void initState() {
    super.initState();
    // Call the splash service to check login status
    SplashService().isLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'images/app_icon.png',
              fit: BoxFit.cover,
              height: 100,
              width: 100,
            ),
            const SizedBox(height: 20),
            Image.asset(
              'images/TikTok_Logo.png',
              fit: BoxFit.cover,
              height: 50,
            ),
          ],
        ),
      ),
    );
  }
}
