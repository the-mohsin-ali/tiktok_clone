import 'package:get/get.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tiktok_clone/view/create_view/create_view.dart';
// import 'package:tiktok_clone/view/feed/home_controller.dart';
import 'package:tiktok_clone/view/feed/home_view.dart';
import 'package:tiktok_clone/view/friends_view/friends_view.dart';
import 'package:tiktok_clone/view/inbox_view/inbox_view.dart';
import 'package:tiktok_clone/view/profile_view/profile_view.dart';


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
