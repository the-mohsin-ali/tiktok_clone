import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tiktok_clone/constants/color/app_color.dart';

class NotificationPermissionDialog extends StatelessWidget {
  const NotificationPermissionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 28.w),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
        decoration: BoxDecoration(
          color: AppColor.secondaryColor,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Turn on notifications',
              style: TextStyle(color: AppColor.primaryColor, fontSize: 17, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 10.h),
            const Text(
              'You won\'t get alerts for new messages or activity until notifications are enabled in your device settings.',
              style: TextStyle(color: AppColor.primaryColor, fontSize: 14, height: 1.4),
            ),
            SizedBox(height: 22.h),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Close', style: TextStyle(color: Colors.grey)),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Get.back();
                      openAppSettings();
                    },
                    child: Text('Go to Settings', style: TextStyle(color: AppColor.buttonActiveColor, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void showNotificationPermissionDialog() {
  Get.dialog(const NotificationPermissionDialog(), barrierDismissible: true);
}