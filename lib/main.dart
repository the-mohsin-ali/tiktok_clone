import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tiktok_clone/bindings/app_bindings.dart';
import 'package:tiktok_clone/constants/routes/app_routes.dart';
import 'package:tiktok_clone/firebase_options.dart';
import 'package:tiktok_clone/global.dart';
import 'package:tiktok_clone/services/shared_prefs.dart';
import 'package:tiktok_clone/view/SplashScreen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tiktok_clone/view/feed/search/searched_profile.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("BackGroundMessage: ${message.messageId}");
}

Future<void> requestNotificationPermission() async {
  // Android 13+ (TIRAMISU / API 33) ke liye
  if (await Permission.notification.isDenied) {
    final status = await Permission.notification.request();
    if (status.isGranted) {
      print("✅ Notification permission granted");
    } else {
      print("❌ Notification permission denied");
    }
  }
}

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await requestNotificationPermission();

  await SharedPrefs.initPrefs();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  const AndroidInitializationSettings androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initSettings = InitializationSettings(android: androidInit);

  await flutterLocalNotificationsPlugin.initialize(
    initSettings,
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

  runApp(MyApp(notificationUserId: notificationUserId));
}

class MyApp extends StatelessWidget {
  final String? notificationUserId;

  const MyApp({super.key, this.notificationUserId});

  @override
  Widget build(BuildContext context) {
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
        home: Splashscreen(notificationUserId: notificationUserId),
      ),
    );
  }
}
