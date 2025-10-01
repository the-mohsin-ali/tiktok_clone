import 'package:get/get.dart';
import 'package:tiktok_clone/bindings/app_bindings.dart';
import 'package:tiktok_clone/constants/routes/routes_names.dart';
import 'package:tiktok_clone/view/SplashScreen.dart';
import 'package:tiktok_clone/view/auth/login_view.dart';
import 'package:tiktok_clone/view/auth/signup.dart';
import 'package:tiktok_clone/view/bottom_nav.dart/bottom_nav.dart';
// import 'package:tiktok_clone/view/bottom_nav.dart/bottom_nav_controller.dart';

class AppRoutes {
  static List<GetPage> routes = [
    GetPage(
      name: RoutesNames.splash,
      page: () => const Splashscreen(),
      transition: Transition.fade,
      transitionDuration: Duration(milliseconds: 250),
    ),

    GetPage(
      name: RoutesNames.signup,
      page: () => Signup(),
      transition: Transition.fade,
      transitionDuration: Duration(milliseconds: 250),
    ),

    GetPage(
      name: RoutesNames.login,
      page: () => LoginView(),
      transition: Transition.fade,
      transitionDuration: Duration(milliseconds: 250),
    ),

    GetPage(
      name: RoutesNames.home,
      binding: AppBindings(),
      page: () => BottomNav(),
      transition: Transition.fade,
      transitionDuration: Duration(milliseconds: 250),
    ),

    // GetPage(
    //   name: RoutesNames.searchedProfile,
    //   page: () => SearchedProfile(uid: '',),
    //   binding: BindingsBuilder(() {
    //     Get.put(InboxController());
    //   }),
    // ),
  ];
}
