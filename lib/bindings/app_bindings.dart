import 'package:get/get.dart';
import 'package:tiktok_clone/global.dart';
import 'package:tiktok_clone/services/notification_service.dart';
import 'package:tiktok_clone/features/auth/auth_controller.dart';
import 'package:tiktok_clone/features/bottom_nav.dart/bottom_nav_controller.dart';
import 'package:tiktok_clone/features/create_view/preview/preview_screen_controller.dart';
import 'package:tiktok_clone/features/feed/comments/comments_controller.dart';
import 'package:tiktok_clone/features/feed/home_controller.dart';
import 'package:tiktok_clone/features/feed/search/search_user_controller.dart';
import 'package:tiktok_clone/features/inbox_view/inbox_controller.dart';
import 'package:tiktok_clone/features/profile_view/profile_view_controller.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(BottomNavController());
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
    Get.lazyPut<SearchUserController>(() => SearchUserController(), fenix: true);
    Get.lazyPut<ProfileViewController>(() => ProfileViewController(), fenix: true);
    Get.lazyPut<PreviewScreenController>(() => PreviewScreenController(), fenix: true);
    Get.lazyPut<CommentsController>(() => CommentsController(), fenix: true);
    Get.lazyPut<InboxController>(() => InboxController(), fenix: true);
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);

    Get.put(NotificationService(flutterLocalNotificationsPlugin)).init();
  }
}
