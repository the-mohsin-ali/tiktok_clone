import 'package:get/get.dart';
import 'package:tiktok_clone/view/auth/auth_controller.dart';
import 'package:tiktok_clone/view/bottom_nav.dart/bottom_nav_controller.dart';
import 'package:tiktok_clone/view/create_view/preview/preview_screen_controller.dart';
import 'package:tiktok_clone/view/feed/comments/comments_controller.dart';
import 'package:tiktok_clone/view/feed/home_controller.dart';
import 'package:tiktok_clone/view/feed/search/search_user_controller.dart';
import 'package:tiktok_clone/view/inbox_view/inbox_controller.dart';
import 'package:tiktok_clone/view/profile_view/profile_view_controller.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(BottomNavController());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<SearchUserController>(() => SearchUserController());
    // Get.lazyPut<FriendScreenController>(()=>FriendsScreenController());
    Get.lazyPut<ProfileViewController>(() => ProfileViewController());
    Get.lazyPut<PreviewScreenController>(() => PreviewScreenController());
    Get.lazyPut<CommentsController>(() => CommentsController());
    // Get.lazyPut<SearchUserController>(() => SearchUserController());
    // Get.lazyPut<SearchedProfileController>(()=> SearchedProfileController());
    // Get.lazyPut<InboxController>(() => InboxController(), );
    Get.put(InboxController(), permanent: true);
    Get.put(AuthController());
  }
}
