import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tiktok_clone/constants/widgets/notification_permission_dialog.dart';
import 'package:tiktok_clone/features/feed/search/searched_profile.dart';

class NotificationService extends GetxService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  NotificationService(this.flutterLocalNotificationsPlugin);

  Future<NotificationService> init() async {
    print("NotificationService.init() called");
    _initFCMListeners();
    return this;
  }

  static Future<void> requestNotificationPermission() async {

    final status = await Permission.notification.status;

    if(status.isGranted) return;

    if(status.isPermanentlyDenied){
      print("Notification Status Permanently denied");
      showNotificationPermissionDialog();
      return;
    }

    if (status.isDenied) {
      final result = await Permission.notification.request();
      if (result.isGranted) {
        print("✅ Notification permission granted");
      } else {
        print("❌ Notification permission denied");
      }
    }
  }

  void _initFCMListeners() {
    // Foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("📩 Foreground Message: ${message.notification?.title}");

      // final chatId = message.data['chatId'] ?? "";
      // final senderId = message.data['senderId'] ?? "";

      final userId = message.data['userId'];

      if(userId != null && userId.isNotEmpty){
        _showLocalNotification(title: message.notification?.title ?? "New Message", body: message.notification?.body ?? "", payload: userId);
      }

      // if (!_isCurrentChatOpen(chatId)) {
      //   _showLocalNotification(
      //     title: message.notification?.title ?? "New Message",
      //     body: message.notification?.body ?? "",
      //     payload: senderId,
      //   );
      // } else {
      //   print("[NotificationService] skippingnotification, user already inside the chat");
      // }
    });

    // When user taps notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // final chatId = message.data['chatId'];
      // final senderId = message.data['senderId'];

      final userId = message.data["userId"];

      if(userId != null && userId.isNotEmpty){
        Get.to(()=> SearchedProfile(uid: userId));
      }

      // if (chatId != null && senderId != null) {
      //   final currentUserId = FirebaseAuth.instance.currentUser!.uid;
      //   if (Get.isRegistered<ChatController>()) {
      //     final controller = Get.find<ChatController>();
      //     controller.updateController(chatId);
      //   } else {
      //     Get.put(ChatController(chatId: chatId, currentUserId: currentUserId));
      //   }
      //   Get.to(() => ChatScreen(otherUserId: senderId));
      // }
    });
  }

  Future<void> _showLocalNotification({required String title, required String body, required String payload}) async {
    const androidDetails = AndroidNotificationDetails(
      'chat_channel',
      'Chat Notifications',
      channelDescription: 'Notifications for new chat messages',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      id:  DateTime.now().millisecond,
      title:  title,
      body: body,
      notificationDetails: notificationDetails,
      payload: payload,
    );
  }

  // bool _isCurrentChatOpen(String chatId) {
  //   if (Get.isRegistered<ChatController>()) {
  //     final controller = Get.find<ChatController>();

  //     // Agar same chat open hai → skip notification
  //     if (controller.chatId == chatId) {
  //       print("[NotificationService] Same chat ($chatId) is open → skipping notification");
  //       return true;
  //     } else {
  //       print("[NotificationService] Another chat (${controller.chatId}) open → showing notification");
  //     }
  //   }
  //   return false;
  // }
}
