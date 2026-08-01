import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:tiktok_clone/bindings/app_bindings.dart';
import 'package:tiktok_clone/constants/routes/app_routes.dart';
import 'package:tiktok_clone/firebase_options.dart';
import 'package:tiktok_clone/global.dart';
import 'package:tiktok_clone/services/shared_prefs.dart';
import 'package:tiktok_clone/services/splash_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tiktok_clone/features/feed/search/searched_profile.dart';

import 'constants/routes/routes_names.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("BackGroundMessage: ${message.messageId}");
}


final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await SharedPrefs.initPrefs();


  final bool isLoggedIn = await SharedPrefs.getIsLoggedIn() ?? false;
  final currentUser = FirebaseAuth.instance.currentUser;
  final initialRoute = (isLoggedIn && currentUser != null)
      ? RoutesNames.home
      : RoutesNames.login;

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  const AndroidInitializationSettings androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initSettings = InitializationSettings(android: androidInit);

  await flutterLocalNotificationsPlugin.initialize(
    settings: initSettings,
    onDidReceiveNotificationResponse: (response) {
      final userId = response.payload;
      if (userId != null && userId.isNotEmpty) {
        Get.to(() => SearchedProfile(uid: userId));
      }
    },
  );

  final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  String? notificationUserId;

  if (initialMessage != null) {
    notificationUserId = initialMessage.data['userId'];
  }

  runApp(MyApp(initialRoute: initialRoute, notificationUserId: notificationUserId));
}

class MyApp extends StatelessWidget {
  final String? notificationUserId;
  final String initialRoute;

  const MyApp({super.key, this.notificationUserId, required this.initialRoute});

  @override
  Widget build(BuildContext context) {

    WidgetsBinding.instance.addPostFrameCallback((_) => FlutterNativeSplash.remove());

    return ScreenUtilInit(
      builder: (context, child) => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Tiktok Clone',
        navigatorObservers: [routeObserver],
        initialBinding: AppBindings(),
        theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
        darkTheme: ThemeData.dark(),
        themeMode: ThemeMode.light,
        getPages: AppRoutes.routes,
        // home: Splashscreen(notificationUserId: notificationUserId),
        initialRoute: initialRoute,
        routingCallback: (routing) {
          if (routing?.current == RoutesNames.home && notificationUserId != null) {
            SplashService.handleNotificationDeepLink(notificationUserId!);
          }
        },
      ),
    );
  }
}
