import 'package:get/get.dart';
import 'package:tiktok_clone/constants/routes/routes_names.dart';
import 'package:tiktok_clone/view/SplashScreen.dart';
import 'package:tiktok_clone/view/auth/login_screen.dart';
import 'package:tiktok_clone/view/auth/signup.dart';

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
      page: () => const LoginView(),
      transition: Transition.fade,
      transitionDuration: Duration(milliseconds: 250),
    ),

  ];
}