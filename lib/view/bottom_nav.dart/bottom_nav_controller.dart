import 'package:get/get.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:tiktok_clone/view/bottom_nav.dart/bottom_nav_controller.dart';
import 'package:tiktok_clone/view/create_view/create_view.dart';
import 'package:tiktok_clone/view/feed/home_view.dart';
import 'package:tiktok_clone/view/friends_view/friends_view.dart';
import 'package:tiktok_clone/view/inbox_view/inbox_view.dart';
import 'package:tiktok_clone/view/profile_view/profile_view.dart';

class BottomBinds extends Bindings {
  @override
  void dependencies() {
    Get.put(BottomNavController());
  }
}

class BottomNavController extends GetxController {
  final selectedTabIndex = 0.obs;

  // final RxBool isPop = false.obs;

  final List<Widget> pages = [
    HomeView(),
    FriendsView(),
    CreateView(),
    InboxView(),
    ProfileView(),
  ];

  void changeTabIndex(int index) {
    selectedTabIndex.value = index;
  }
}
