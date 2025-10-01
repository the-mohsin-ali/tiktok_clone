import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tiktok_clone/constants/color/app_color.dart';
import 'package:tiktok_clone/view/feed/search/search_results_screen.dart';

// class SearchScreen extends StatelessWidget {
//   SearchScreen({super.key});

//   SearchUserController controller = Get.put(SearchUserController());

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColor.secondaryColor,
//       appBar: AppBar(
//         title: TextField(
//           controller: controller.textEditingController,
//           decoration: InputDecoration(border: InputBorder.none, hintText: 'Search Users...'),
//         ),
//       ),
//       body: Obx(() {
//         final results = controller.searchResults;
//         if (results.isEmpty) {
//           return Center(child: CircularProgressIndicator());
//         }
//         return ListView.builder(
//           itemCount: results.length,
//           itemBuilder: (context, index) {
//             final user = results[index];
//             return ListTile(
//               leading: CircleAvatar(
//                 backgroundImage: user.profilePhoto != null
//                     ? NetworkImage(user.profilePhoto!)
//                     : const AssetImage('assets/images/default_profile.jpg') as ImageProvider,
//               ),
//               title: Text(user.userName),
//               onTap: () => Get.to(() => SearchedProfile(uid: user.uid)),
//             );
//           },
//         );
//       }),
//     );
//   }
// }

class SearchScreen extends StatelessWidget {
  SearchScreen({super.key});

  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.secondaryColor,
      appBar: AppBar(
        backgroundColor: AppColor.secondaryColor,
        centerTitle: true,
        title: TextField(
          controller: searchController,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: 'Search users or videos...',
            filled: true,
            fillColor: AppColor.buttonInactiveColor,          
          ),
          onSubmitted: (query) {
            if (query.isNotEmpty) {
              Get.to(() => SearchResultsScreen(query: query));
            }
          },
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Text(
              "Search",
              style: TextStyle(
                fontFamily: 'TikTokSansExpanded',
                fontWeight: FontWeight.w400,
                fontSize: 15.sp,
                color: AppColor.buttonActiveColor,
              ),
            ),
          ),
        ],
      ),
      body: Center(child: Text("Search for user or videos")),
    );
  }
}
