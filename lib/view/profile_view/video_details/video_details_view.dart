// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:tiktok_clone/constants/color/app_color.dart';
// import 'package:tiktok_clone/interfaces/video_list_controller.dart';
// import 'package:tiktok_clone/services/shared_prefs.dart';
// import 'package:tiktok_clone/view/feed/comments/comments_bottomsheet.dart';
import 'package:flutter/material.dart';
import 'package:tiktok_clone/view/feed/video_player_item.dart';
import 'package:tiktok_clone/view/profile_view/profile_view_controller.dart';
import 'package:get/get.dart';

class VideoDetailsView extends StatelessWidget {
  final int initialIndex;
  final ProfileViewController controller = Get.find();

  VideoDetailsView({super.key, required this.initialIndex});

  @override
  Widget build(BuildContext context) {
    final pageController = PageController(initialPage: initialIndex);

    return Scaffold(
      body: Stack(
        children: [
          Obx(
            () => PageView.builder(
              controller: pageController,
              scrollDirection: Axis.vertical,
              onPageChanged: (index) => controller.onPageChanged(index, controller.userVideos),
              itemCount: controller.userVideos.length,
              itemBuilder: (context, index) {
                final video = controller.userVideos[index];
                final vc = controller.videoControllers[index];

                return VideoPlayerItem(
                  videoController: vc,
                  video: video,
                  listController: controller, // <-- Profile controller inject
                );
              },
            ),
          ),
          Positioned(
            top: 30,
            left: 10,
            child: IconButton(icon: const Icon(Icons.arrow_back_outlined), onPressed: () => Get.back()),
          ),
        ],
      ),
    );
  }
}
