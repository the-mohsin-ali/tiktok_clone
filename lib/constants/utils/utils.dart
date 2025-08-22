import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tiktok_clone/constants/color/app_color.dart';

class Utils {
  static InputDecoration inputDecoration({
    required String title,
    IconData? suffixIcon,
    VoidCallback? onTap,
  }) {
    return InputDecoration(
      // fillColor: AppColor.buttonInactiveColor,
      hintStyle: TextStyle(color: Colors.grey.shade400),
      // border: OutlineInputBorder(
      //   // borderSide: BorderSide.none,
      //   borderRadius: BorderRadius.circular(8),
      // ),
      hintText: title,
      filled: false,
      suffixIcon: suffixIcon != null
          ? GestureDetector(onTap: onTap, child: Icon(suffixIcon))
          : null,
    );
  }

  static snackBar(String title, String message) {
    Get.snackbar(title, message, snackPosition: SnackPosition.BOTTOM, colorText: AppColor.secondaryColor, backgroundColor: AppColor.primaryColor);
  }
}
