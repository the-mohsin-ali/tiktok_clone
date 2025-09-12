import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:tiktok_clone/models/system_message.dart';
import 'package:tiktok_clone/models/user_model.dart';

class InboxController extends GetxController {
  final RxList<SystemMessage> system_message = <SystemMessage>[].obs;

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  
  // Stream subscription to manage the listener
  StreamSubscription<QuerySnapshot>? _systemMessageSubscription;

  @override
  void onInit() {
    super.onInit();
    _listenToSystemMessages();
  }

  @override
  void onClose() {
    // Cancel the subscription when controller is disposed
    _systemMessageSubscription?.cancel();
    super.onClose();
  }

  // 🔥 Real-time listener for system messages
  void _listenToSystemMessages() {
    final currentUserId = _auth.currentUser?.uid;
    
    if (currentUserId == null) return;

    _systemMessageSubscription = _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('system_messages')
        .orderBy('time', descending: true)
        .snapshots()
        .listen(
      (snapshot) {
        system_message.value = snapshot.docs
            .map((doc) => SystemMessage.fromJson(doc.data()))
            .toList();
      },
      onError: (error) {
        print("Error listening to system messages: $error");
      },
    );
  }

  // 🔥 Updated method - no longer needs to manually add to local list
  void addFollowPrompt({required bool isReverse, required UserModel user}) async {
    final currentUserId = _auth.currentUser!.uid;

    final message = isReverse
        ? "${user.userName} started following you. Say hi!"
        : "You followed ${user.userName}. Say hi!";

    final prompt = SystemMessage(
      userId: user.uid,
      userName: user.userName,
      userPhotoUrl: user.profilePhoto ?? '',
      message: message,
      time: DateTime.now(),
    );

    try {
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('system_messages')
          .doc(user.uid)
          .set(prompt.toJson());

      print("Added system_message for ${user.uid}");
      
      // No need to manually update the list - the stream listener will handle it
    } catch (e) {
      print("Error adding follow prompt: $e");
    }
  }

  // 🔥 Updated method - no longer needs to manually remove from local list
  Future<void> removeFollowPromptForUser(String userId) async {
    final currentUserId = _auth.currentUser!.uid;

    try {
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('system_messages')
          .doc(userId)
          .delete();

      print("Removed system_message for $userId");
      
      // No need to manually update the list - the stream listener will handle it
    } catch (e) {
      print("Error removing follow prompt: $e");
    }
  }

  bool hasFollowPrompt(String userId) {
    return system_message.any((msg) => msg.userId == userId);
  }

  // 🔥 Optional: Method to refresh the listener if needed
  void refreshListener() {
    _systemMessageSubscription?.cancel();
    _listenToSystemMessages();
  }
}