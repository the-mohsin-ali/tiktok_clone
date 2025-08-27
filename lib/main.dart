import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tiktok_clone/constants/routes/app_routes.dart';
import 'package:tiktok_clone/firebase_options.dart';
import 'package:tiktok_clone/view/SplashScreen.dart';
import 'package:tiktok_clone/view/auth/auth_controller.dart';
import 'package:tiktok_clone/view/feed/home_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthController());
    Get.put(HomeController());
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Get.put(AuthController());
  // Get.put(HomeController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      
      builder: (context, child)=> GetMaterialApp(
        title: 'Flutter Demo',
        initialBinding: InitialBinding(),
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        darkTheme: ThemeData.dark(),
        themeMode: ThemeMode.light,
        getPages: AppRoutes.routes,
        home: Splashscreen(),
      ),
    );
  }
}
