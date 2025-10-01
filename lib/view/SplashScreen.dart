import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tiktok_clone/constants/color/app_color.dart';
import 'package:tiktok_clone/services/splash_service.dart';

class Splashscreen extends StatefulWidget {
  final String? notificationUserId;
  const Splashscreen({super.key, this.notificationUserId});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  void initState() {
    super.initState();
    // Call the splash service to check login status
    SplashService(notificationUserId: widget.notificationUserId).handleStartup();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primaryColor,
      body: Stack(
        children: [
          // Center the column horizontally, offset vertically
          Align(
            alignment: Alignment(0, -0.23), // x = 0 (center), y = -0.3 (slightly up)
            child: Column(
              mainAxisSize: MainAxisSize.min, // Wrap content vertically
              children: [
                Image.asset('assets/images/app_icon.png', fit: BoxFit.cover, height: 70.h, width: 70.w),
                SizedBox(height: 10.h),
                Image.asset('assets/images/tiktok_name.png', fit: BoxFit.cover, height: 25.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
