import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tiktok_clone/constants/color/app_color.dart';
import 'package:tiktok_clone/view/feed/search/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:tiktok_clone/view/feed/home_controller.dart';
import 'package:tiktok_clone/view/feed/video_player_item.dart';
import 'package:get/get.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    bool isFetching = false;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Theme(
        data: ThemeData.dark(),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Obx(() {
            final videos = controller.videos;

            if (videos.isEmpty) {
              return Center(child: CircularProgressIndicator());
            }

            return NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is OverscrollNotification &&
                    notification.overscroll < 0 &&
                    controller.pageController.page == 0 &&
                    !controller.isLoading.value &&
                    !isFetching) {
                  isFetching = true;
                  controller.fetchVideos().whenComplete(() {
                    isFetching = false;
                  });
                }
                return false;
              },
              child: Stack(
                children: [
                  PageView.builder(
                    controller: controller.pageController,
                    scrollDirection: Axis.vertical,
                    itemCount: videos.length,
                    onPageChanged: (index) {
                      controller.onPageChanged(index, videos);
                    },
                    itemBuilder: (context, index) {
                      final video = videos[index];
                      // ⚡️ Pehle yahan se videoControllers check ho raha tha, uski zarurat nahi hai ab
                      return VideoPlayerItem(video: video, listController: controller);
                    },
                  ),

                  // 🔎 Global Search Button
                  Positioned(
                    top: 40.h,
                    right: 20.w,
                    child: GestureDetector(
                      onTap: () => Get.to(() => SearchScreen()),
                      child: Icon(Icons.search_sharp, color: AppColor.buttonInactiveColor, size: 38),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
