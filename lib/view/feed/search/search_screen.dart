import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tiktok_clone/view/feed/search/search_user_controller.dart';
import 'package:tiktok_clone/view/feed/search/searched_profile.dart';

class SearchScreen extends StatelessWidget {
  SearchScreen({super.key});

  SearchUserController controller = Get.put(SearchUserController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: controller.textEditingController,
          decoration: InputDecoration(border: InputBorder.none, hintText: 'Search Users...'),
        ),
      ),
      body: Obx(() {
        final results = controller.searchResults;
        if (results.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final user = results[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: user.profilePhoto != null
                    ? NetworkImage(user.profilePhoto!)
                    : const AssetImage('assets/images/default_profile.jpg') as ImageProvider,
              ),
              title: Text(user.userName),
              onTap: () => Get.to(() => SearchedProfile(uid: user.uid)),
            );
          },
        );
      }),
    );
  }
}
