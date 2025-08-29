import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/state_manager.dart';
import 'package:tiktok_clone/view/profile_view/profile_view_controller.dart';
import 'package:tiktok_clone/view/profile_view/video_grid_item.dart';

class ProfileView extends StatelessWidget {
  ProfileView({super.key});

  final ProfileViewController controller = ProfileViewController();

  @override
  Widget build(BuildContext context) {
    return Obx((){
      if(controller.isLoading.value){
        return const Scaffold(
          body: Center(child: CircularProgressIndicator(),),
        );
      }

      final user = controller.user.value;
      final videos = controller.userVideos;

      return Scaffold(
        appBar: AppBar(
          title: Text(controller.userName.value, style: TextStyle(fontFamily: 'ProximaNova', fontWeight: FontWeight.bold),),
          centerTitle: true ,
          actions: [
            IconButton(onPressed: (){}, icon: Icon(Icons.logout))
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: user.profilePhoto != null && user.profilePhoto!.isNotEmpty
                    ? NetworkImage(user.profilePhoto!)
                    : const AssetImage('assets/images/default_profile.jpg') as ImageProvider,
                  ),
                  SizedBox(width: 24.w,),
                  Expanded(
                    child: Column(
                      children: [
                        _buildStat(user.followersCount, 'Followers'),
                        _buildStat(user.followingCount, 'Following'),
                        _buildStat(user.likes, 'Likes'),
                      ],
                    )
                  ),
                ],
              ),
            ),
            Text(
              user.userName,
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20.h,),
            Expanded(
  child: GridView.builder(
    padding: EdgeInsets.symmetric(horizontal: 8.w),
    itemCount: videos.length,
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
      childAspectRatio: 9 / 16,
      crossAxisSpacing: 4,
      mainAxisSpacing: 4,
    ),
    itemBuilder: (context, index) {
      final video = videos[index];
      return VideoGridItem(videoUrl: video.videoUrl);
    },
  ),
)

          ],
        ),
      );
      }
    );
  }

  Widget _buildStat(int count, String label){
    return Column(
      children: [
        Text('$count', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),),
        Text(label, style: TextStyle(fontSize: 12.sp),)
      ],
    );
  }
}