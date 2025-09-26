import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tiktok_clone/view/feed/search/search_controller.dart';
import 'package:tiktok_clone/view/feed/search/searched_profile.dart';
import 'package:tiktok_clone/view/profile_view/video_grid_item.dart';
import 'package:tiktok_clone/view/feed/search/search_controller.dart' as my_search;

class SearchResultsScreen extends StatelessWidget {
  final String query;
  final my_search.SearchController controller = Get.put(my_search.SearchController());

  SearchResultsScreen({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    controller.search(query);

    print('[SearchResultsScreen] Users profile length: ${controller.users.length}');
    print('[SearchResultsScreen] Videos length: ${controller.videos.length}');

    return Scaffold(
      appBar: AppBar(title: Text("Results for \"$query\"")),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Users Section
              if (controller.users.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text("Users", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.users.length,
                  itemBuilder: (context, index) {
                    final user = controller.users[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: user.profilePhoto != null && user.profilePhoto!.isNotEmpty
                            ? NetworkImage(user.profilePhoto!)
                            : const AssetImage('assets/images/default_profile.jpg') as ImageProvider,
                      ),
                      title: Text(user.userName),
                      onTap: () => Get.to(() => SearchedProfile(uid: user.uid)),
                    );
                  },
                ),
              ],

              // 🔹 Videos Section
              if (controller.videos.isNotEmpty) ...[
                Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    "Videos",
                    style: TextStyle(fontFamily: 'TikTokSansExpanded', fontSize: 18.sp, fontWeight: FontWeight.bold),
                  ),
                ),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.videos.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 9 / 16,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemBuilder: (context, index) {
                    final video = controller.videos[index];
                    return VideoGridItem(videoUrl: video.videoUrl, index: index, controller: controller);
                  },
                ),
              ],
            ],
          ),
        );
      }),
    );
  }
}
