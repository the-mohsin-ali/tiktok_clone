import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tiktok_clone/constants/routes/routes_names.dart';
import 'package:tiktok_clone/view/SplashScreen.dart';
import 'package:tiktok_clone/view/auth/login_view.dart';
import 'package:tiktok_clone/view/auth/signup.dart';
import 'package:tiktok_clone/view/bottom_nav.dart/bottom_nav.dart';
import 'package:tiktok_clone/view/bottom_nav.dart/bottom_nav_controller.dart';
import 'package:tiktok_clone/view/feed/home_view.dart';

class AppRoutes {
  static List<GetPage> routes = [
    GetPage(
      name: RoutesNames.splash,
      page: () => const Splashscreen(),
      transition: Transition.fade,
      transitionDuration: Duration(milliseconds: 250),
    ),

    GetPage(
      name: RoutesNames.signup,
      page: () => Signup(),
      transition: Transition.fade,
      transitionDuration: Duration(milliseconds: 250),
    ),

    GetPage(
      name: RoutesNames.login,
      page: () => LoginView(),
      transition: Transition.fade,
      transitionDuration: Duration(milliseconds: 250),
    ),

    GetPage(
      name: RoutesNames.home,
      binding: BottomBinds(),
      page: () => BottomNav(),
      transition: Transition.fade,
      transitionDuration: Duration(milliseconds: 250),
    ),
  ];
}
