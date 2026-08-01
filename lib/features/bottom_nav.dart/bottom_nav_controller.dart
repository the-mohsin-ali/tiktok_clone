import 'package:get/get.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tiktok_clone/features/create_view/create_view.dart';
// import 'package:tiktok_clone/features/feed/home_controller.dart';
import 'package:tiktok_clone/features/feed/home_view.dart';
import 'package:tiktok_clone/features/friends_view/friends_view.dart';
import 'package:tiktok_clone/features/inbox_view/inbox_view.dart';
import 'package:tiktok_clone/features/profile_view/profile_view.dart';


class BottomNavController extends GetxController {
  final selectedTabIndex = 0.obs;

  final List<Widget> pages = [HomeView(), FriendsView(), CreateView(), InboxView(), ProfileView()];

  void changeTabIndex(int index) {
    // final previousIndex = selectedTabIndex.value;
    // if (previousIndex == 0 && Get.isRegistered<HomeController>()) {
    //   Get.find<HomeController>().pauseAllVideos();
    // }

    selectedTabIndex.value = index;

    // if (index == 0 && Get.isRegistered<HomeController>()) {
    //   Get.find<HomeController>().resumeCurrentVideo();
    // }
  }
}
