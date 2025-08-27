import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tiktok_clone/constants/color/app_color.dart';
import 'package:tiktok_clone/constants/routes/routes_names.dart';
import 'package:tiktok_clone/constants/utils/utils.dart';
import 'package:tiktok_clone/constants/widgets/round_button.dart';
import 'package:tiktok_clone/view/auth/auth_controller.dart';

class LoginView extends GetView<AuthController> {
  LoginView({super.key});

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsetsGeometry.all(20.r),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Login to your account',
                      style: TextStyle(
                        fontSize: 25.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 60.h),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Email', style: TextStyle(fontSize: 15.sp)),
                ),
                // SizedBox(height: 20.h),
                TextFormField(
                  controller: controller.emailController,
                  decoration: Utils.inputDecoration(
                    title: 'eg emmanuel@gmail.com',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 30.h),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Password', style: TextStyle(fontSize: 15.sp)),
                ),
                TextFormField(
                  controller: controller.passwordController,
                  obscureText: true,
                  decoration: Utils.inputDecoration(title: '********'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: AppColor.buttonActiveColor,
                    ),
                  ),
                ),
                SizedBox(height: 30.h),
                Obx(() {
                  final isActive = controller.isFormFilled.value;
                  return RoundButton(
                    isLoading: controller.isLoading.value,
                    text: 'Login',
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        controller.login();
                      } else {
                        Utils.snackBar('Error', 'Form not valid');
                        print("invalid form at signup");
                      }
                    },
                    color: isActive
                        ? AppColor.buttonActiveColor
                        : AppColor.buttonInactiveColor,
                  );
                }),
                const Spacer(),
                Align(
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Don\'t have an account?',
                        style: TextStyle(fontSize: 15.sp),
                      ),
                      TextButton(
                        onPressed: () {
                          controller.clearFields();
                          Get.offNamed(RoutesNames.signup);
                        },
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: AppColor.buttonActiveColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
