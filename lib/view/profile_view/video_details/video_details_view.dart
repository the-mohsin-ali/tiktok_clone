import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:tiktok_clone/constants/color/app_color.dart';
import 'package:tiktok_clone/view/feed/video_player_item.dart';
import 'package:tiktok_clone/view/profile_view/profile_view_controller.dart';

class VideoDetailsView extends StatelessWidget {
  final int initialIndex;
  VideoDetailsView({super.key, required this.initialIndex});

  ProfileViewController controller = Get.find<ProfileViewController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: Get.back, icon: Icon(Icons.arrow_back)),
      ),
      backgroundColor: AppColor.primaryColor,
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        controller: PageController(initialPage: initialIndex),
        itemCount: controller.userVideos.length,
        itemBuilder: (context, index) {
          final video = controller.userVideos[index];
          return Stack(
            children: [
              VideoplayerItem(videoUrl: video.videoUrl),
              SizedBox(width: 16.h),

              Positioned(
                bottom: 50.h,
                right: 10.h,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundImage: video.profilePhoto != null && video.profilePhoto!.isNotEmpty
                          ? NetworkImage(video.profilePhoto!)
                          : AssetImage('assets/images/default_profile.jpg') as ImageProvider,
                    ),
                    SizedBox(height: 20.h),
                    InkWell(
                      onTap: () {
                        
                      },
                      child: SvgPicture.asset(
                        video.likedBy.contains('element')?
                        'assets/icons/like_icon_filled.svg':
                        'assets/icons/like_icon.svg',
                        width: 42,
                        height: 42,
                        colorFilter: ColorFilter.mode(AppColor.secondaryColor, BlendMode.srcIn),
                      ),
                    ),
                    Text(
                      '${video.likeCount}',
                      style: TextStyle(color: Colors.white, fontFamily: 'ProximaNova', fontWeight: FontWeight.normal),
                    ),
                    SizedBox(height: 8.h),
                    SvgPicture.asset(
                      'assets/icons/comment_icon.svg',
                      width: 42,
                      height: 42,
                      colorFilter: ColorFilter.mode(AppColor.secondaryColor, BlendMode.srcIn),
                    ),
                    Text(
                      '${video.commentCount}',
                      style: TextStyle(color: Colors.white, fontFamily: 'ProximaNova', fontWeight: FontWeight.normal),
                    ),
                    SizedBox(height: 8.h),
                    SvgPicture.asset(
                      'assets/icons/share_icon.svg',
                      width: 38,
                      height: 38,
                      colorFilter: ColorFilter.mode(AppColor.secondaryColor, BlendMode.srcIn),
                    ),
                    Text(
                      'Share',
                      style: TextStyle(color: Colors.white, fontFamily: 'ProximaNova', fontWeight: FontWeight.normal),
                    ),
                    SizedBox(height: 8.h),
                    SvgPicture.asset(
                      'assets/icons/more.svg',
                      // width: 38,
                      // height: 38,
                      width: 25.w,
                      colorFilter: ColorFilter.mode(AppColor.secondaryColor, BlendMode.srcIn),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
