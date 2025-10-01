import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:tiktok_clone/constants/routes/routes_names.dart';
import 'package:tiktok_clone/services/shared_prefs.dart';
import 'package:tiktok_clone/view/feed/home_controller.dart';
import 'package:tiktok_clone/view/feed/search/searched_profile.dart';

class SplashService {
  final String? notificationUserId;
  final HomeController homeController = Get.find<HomeController>();

  SplashService({this.notificationUserId});

  Future<void> handleStartup() async {
    // Show splash for ~1.2s (UX friendly)
    await Future.delayed(const Duration(milliseconds: 1200));

    final bool isLoggedIn = await SharedPrefs.getIsLoggedIn() ?? false;
    final User? currentUser = FirebaseAuth.instance.currentUser;

    // Preload home feed videos
    await homeController.fetchVideos();

    if (homeController.videoControllers.isNotEmpty && homeController.videoControllers[0] != null) {
      int retries = 0;
      while (!homeController.videoControllers[0]!.value.isInitialized && retries < 30) {
        await Future.delayed(const Duration(milliseconds: 100));
        retries++;
      }
    }

    homeController.videos.refresh();

    // Case 1: App opened via notification
    if (notificationUserId != null && notificationUserId!.isNotEmpty) {
      if (isLoggedIn && currentUser != null) {
        Get.offAllNamed(RoutesNames.home);
        Future.delayed(const Duration(milliseconds: 200), () {
          Get.to(() => SearchedProfile(uid: notificationUserId!));
        });
      } else {
        Get.offAllNamed(RoutesNames.login);
      }
      return;
    }

    // Case 2: Normal startup
    if (isLoggedIn && currentUser != null) {
      Get.offAllNamed(RoutesNames.home);
    } else {
      Get.offAllNamed(RoutesNames.login);
    }
  }
}
