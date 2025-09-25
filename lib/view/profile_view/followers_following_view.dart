import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tiktok_clone/constants/color/app_color.dart';
import 'package:tiktok_clone/constants/utils/rounded_button.dart';
import 'package:tiktok_clone/models/follow_user_model.dart';
import 'package:tiktok_clone/models/user_model.dart';
import 'followers_following_controller.dart';

class FollowersFollowingView extends StatelessWidget {
  final String targetUid;
  final int initialTab; // 0 = Following, 1 = Followers

  const FollowersFollowingView({super.key, required this.targetUid, required this.initialTab});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FollowersFollowingController(targetUid: targetUid));

    controller.tabIndex.value = initialTab;

    final tabController = PageController(initialPage: initialTab, keepPage: true);

    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text(
            controller.tabIndex.value == 0 ? "Following" : "Followers",
            style: TextStyle(fontFamily: 'TikTokSansExpanded', fontWeight: FontWeight.w400),
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 🔎 Search bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: controller.searchController,
              // onChanged: (val) => controller.searchQuery.value = val,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Search...",
                border: InputBorder.none,
                // OutlineInputBorder(
                //   borderRadius: BorderRadius.circular(12),
                // ),
              ),
            ),
          ),

          // Tabs
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _tabButton("Following", 0, controller, tabController, context),
                _tabButton("Followers", 1, controller, tabController, context),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Swipable PageView
          Expanded(
            child: PageView(
              controller: tabController,
              onPageChanged: (index) => controller.tabIndex.value = index,
              children: [
                Obx(() => _buildList(controller.filteredFollowing, controller, isFollowers: false)),
                Obx(() => _buildList(controller.filteredFollowers, controller, isFollowers: true)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Tab button
  Widget _tabButton(
    String title,
    int index,
    FollowersFollowingController controller,
    PageController pageController,
    BuildContext context,
  ) {
    final isSelected = controller.tabIndex.value == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final selectedColor = isDark ? Colors.white : Colors.black;
    final unselectedColor = Colors.grey;

    return GestureDetector(
      onTap: () {
        controller.tabIndex.value = index;
        pageController.jumpToPage(index);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'TikTokSansExpanded',
              fontWeight: FontWeight.w500,
              fontSize: 15,
              color: isSelected ? selectedColor : unselectedColor,
            ),
          ),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            height: 2,
            width: isSelected ? 60 : 0,
            color: isSelected ? selectedColor : Colors.transparent,
          ),
        ],
      ),
    );
  }

  // 🔹 List builder
  Widget _buildList(List<FollowUserModel> users, FollowersFollowingController controller, {required bool isFollowers}) {
    if (users.isEmpty) {
      return const Center(child: Text("No users found"));
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 8.h),
      itemCount: users.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (_, index) {
        if (index == users.length - 1) {
          if (isFollowers) {
            controller.fetchFollowersPage();
          } else {
            controller.fetchFollowingPage();
          }
        }

        final user = users[index];
        final isFollowing = controller.alreadyFollowing.contains(user.uid);

        return ListTile(
          leading: CircleAvatar(
            radius: 20.r,
            backgroundImage: user.profilePhoto.isNotEmpty
                ? NetworkImage(user.profilePhoto)
                : const AssetImage('assets/images/default_profile.jpg') as ImageProvider,
          ),
          title: Text(user.userName),
          trailing: user.uid == controller.targetUid
              ? null // apne aap ko follow/unfollow button na dikhao
              :
                //  ElevatedButton(
                //     style: ElevatedButton.styleFrom(backgroundColor: isFollowing ? Colors.grey : Colors.blue),
                //     onPressed: () async {
                //       // 🔑 toggle follow
                //       await controller.toggleFollow(
                //         // UserModel banani hogi, minimal data se
                //         // FollowUserModel → UserModel me wrap karna
                //         // for now, minimal dummy UserModel
                //         // kyunki toggleFollow UserModel expect karta hai
                //         user.toUserModel(),
                //       );
                //     },
                //     child: Text(isFollowing ? "Following" : "Follow"),
                //   )
                Followbutton(
                  titelColor: AppColor.secondaryColor,
                  title: isFollowing ? "Following" : "Follow",
                  color: isFollowing ? AppColor.buttonInactiveColor : AppColor.buttonActiveColor,
                  onTap: () async {
                    await controller.toggleFollow(user.toUserModel());
                  },
                  height: 25.h,
                  width: 90.w,
                ),
        );
      },
    );
  }
}

extension on FollowUserModel {
  // Helper: FollowUserModel → UserModel (sirf required fields)
  toUserModel() {
    return UserModel(
      uid: uid,
      email: '',
      userName: userName,
      profilePhoto: profilePhoto,
      followers: [],
      following: [],
      likes: 0,
    );
  }
}
