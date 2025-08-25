import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tiktok_clone/constants/color/app_color.dart';
import 'package:tiktok_clone/constants/routes/routes_names.dart';
import 'package:tiktok_clone/constants/utils/utils.dart';
import 'package:tiktok_clone/constants/widgets/round_button.dart';
import 'package:tiktok_clone/view/auth/auth_controller.dart';

class Signup extends GetResponsiveWidget<AuthController> {
  Signup({super.key});

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Create new account',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 60),
                  GestureDetector(
                    onTap: () {
                      controller.pickProfileImage();
                    },
                    child: Stack(
                      children: [
                        Obx(() {
                          return CircleAvatar(
                            radius: 64,
                            backgroundColor: Colors.grey,
                            backgroundImage: controller.pickedImage.value,
                          );
                        }),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColor.buttonActiveColor,
                            child: Icon(Icons.add_a_photo, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Username', style: TextStyle(fontSize: 15)),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: controller.usernameController,
                    decoration: Utils.inputDecoration(title: 'eg emmanuelogah'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your username';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Email', style: TextStyle(fontSize: 15)),
                  ),
                  const SizedBox(height: 20),
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
                  const SizedBox(height: 30),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Password', style: TextStyle(fontSize: 15)),
                  ),
                  TextFormField(
                    controller: controller.passwordController,
                    obscureText: true,
                    decoration: Utils.inputDecoration(title: 'Enter Password'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  // const SizedBox(height: 30),
                  // Align(
                  //   alignment: Alignment.centerLeft,
                  //   child: Text('Phone Number', style: TextStyle(fontSize: 15)),
                  // ),
                  // TextFormField(
                  //   keyboardType: TextInputType.number,
                  //   // controller: controller.phoneController,
                  //   decoration: Utils.inputDecoration(title: 'eg 08012345678'),
                  //   validator: (value) {
                  //     if (value!.isEmpty) {
                  //       return 'Please enter phone number';
                  //     }
                  //     return null;
                  //   },
                  // ),
                  const SizedBox(height: 50),
                  Obx(() {
                    final isActive = controller.isFormFilled.value;
                    return RoundButton(
                      text: 'Signup',
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          controller.signUp();
                        } else {
                          Utils.snackBar('Error', 'Form not valid');
                          print("invalid form at signup");
                        }
                        // controller.clearFields();
                      },
                      color: isActive
                          ? AppColor.buttonActiveColor
                          : AppColor.buttonInactiveColor,
                      isLoading: controller.isLoading.value,
                    );
                  }),
                  const SizedBox(height: 30),
                  Align(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account?',
                          style: TextStyle(fontSize: 15),
                        ),
                        TextButton(
                          onPressed: () {
                            controller.clearFields();
                            Get.offNamed(RoutesNames.login);
                          },
                          child: Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 15,
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
      ),
    );
  }
}
