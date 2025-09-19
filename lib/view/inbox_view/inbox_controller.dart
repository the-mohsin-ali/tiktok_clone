import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:tiktok_clone/models/chat_model.dart';
import 'package:tiktok_clone/models/enumns.dart';
import 'package:tiktok_clone/models/system_message.dart';
import 'package:tiktok_clone/models/user_model.dart';
import 'package:tiktok_clone/view/inbox_view/chat/chat_view.dart';
import 'package:tiktok_clone/view/inbox_view/chat/chat_view_controller.dart';

class InboxController extends GetxController {
  final RxList<SystemMessage> systemMessages = <SystemMessage>[].obs;
  final RxList<ChatModel> userChats = <ChatModel>[].obs;
  RxList<InboxItem> inboxItems = <InboxItem>[].obs;

  final _firestore = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  // Stream subscription to manage the listener
  StreamSubscription<QuerySnapshot>? _systemMessageSubscription;
  StreamSubscription<QuerySnapshot>? _chatMessageSubscription;

  @override
  void onInit() {
    super.onInit();
    _listenToSystemMessages();
    _listenToChatMessages();
  }

  @override
  void onClose() {
    // Cancel the subscription when controller is disposed
    _systemMessageSubscription?.cancel();
    _chatMessageSubscription?.cancel();
    print('[InboxController] subscriptions cancelled');
    super.onClose();
  }

  // 🔥 Real-time listener for system messages
  void _listenToSystemMessages() {
    final currentUserId = auth.currentUser?.uid;

    if (currentUserId == null) {
      print('[SystemMessage] No authenticated user found.');
      return;
    }

    print('[SystemMessage] Listening to system messages...');
    try {
      _systemMessageSubscription = _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('system_messages')
          .orderBy('time', descending: true)
          .snapshots()
          .listen(
            (snapshot) {
              systemMessages.value = snapshot.docs.map((doc) => SystemMessage.fromJson(doc.data())).toList();
              print('[SystemMessage] ${systemMessages.length} messages fetched.');
              _mergeInboxItems();
            },
            onError: (error) {
              print("Error listening to system messages: $error");
            },
          );
    } catch (e) {
      print('[SystemMessage] ❌ Exception: $e');
    }
  }

  void _listenToChatMessages() {
    final currentUserId = auth.currentUser?.uid;
    if (currentUserId == null) {
      print('[Chat] No authenticated user.');
      return;
    }
    try {
      _chatMessageSubscription = _firestore
          .collection('chats')
          .where('participants', arrayContains: currentUserId)
          .orderBy('lastMessageAt', descending: true)
          .snapshots()
          .listen((snapshot) {
            userChats.value = snapshot.docs.map((doc) {
              final data = doc.data();
              return ChatModel.fromJson(data, doc.id);
            }).toList();
            print('[Chat] ${userChats.length} chats fetched.');
            _mergeInboxItems();
          });
    } catch (e) {
      print('[Chat] ❌ Exception: $e');
    }
  }

  Future<void> openOrCreateChatWith(String otherUserId, String otherUserName, String otherUserProfile) async {
    final currentUserId = auth.currentUser!.uid;
    final chatId = _generateChatId(currentUserId, otherUserId);

    if (Get.isRegistered<ChatController>()) {
      final controller = Get.find<ChatController>();
      await controller.updateController(chatId);
    } else {
      Get.put(ChatController(chatId: chatId, currentUserId: currentUserId));
    }
    Get.to(() => ChatScreen(otherUserId: otherUserId, otherUserName: otherUserName, otherUserPhoto: otherUserProfile));
  }

  String _generateChatId(String uid1, String uid2) {
    final sorted = [uid1, uid2]..sort();
    return sorted.join('_');
  }

  // Combine system messages and chats into one list sorted by time descending

  void _mergeInboxItems() {
    final List<InboxItem> combined = [];
    final currentUid = auth.currentUser?.uid;
    if (currentUid == null) return;

    // ✅ Only add system messages with NO existing chat
    for (final sm in systemMessages) {
      final alreadyChatExists = userChats.any((chat) {
        return chat.type == ChatType.direct && chat.participants.contains(sm.userId);
      });

      if (!alreadyChatExists) {
        combined.add(InboxItem.systemMessage(sm));
      }
    }

    // ✅ Add all chat items
    combined.addAll(userChats.map((chat) => InboxItem.chat(chat)));

    // ✅ Sort all items by latest time
    combined.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    inboxItems.value = combined;
  }

  // 🔥 Updated method - no longer needs to manually add to local list
  void addFollowPrompt({required bool isReverse, required UserModel user}) async {
    final currentUserId = auth.currentUser!.uid;

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
    final currentUserId = auth.currentUser!.uid;

    try {
      await _firestore.collection('users').doc(currentUserId).collection('system_messages').doc(userId).delete();

      print("Removed system_message for $userId");

      // No need to manually update the list - the stream listener will handle it
    } catch (e) {
      print("Error removing follow prompt: $e");
    }
  }

  bool hasFollowPrompt(String userId) {
    return systemMessages.any((msg) => msg.userId == userId);
  }

  // 🔥 Optional: Method to refresh the listener if needed
  void refreshListener() {
    _systemMessageSubscription?.cancel();
    _listenToSystemMessages();
  }
}

class InboxItem {
  final SystemMessage? systemMessage;
  final ChatModel? chat;
  final DateTime timestamp;

  InboxItem.systemMessage(this.systemMessage) : chat = null, timestamp = systemMessage!.time;

  InboxItem.chat(this.chat)
    : systemMessage = null,
      timestamp = chat!.lastMessageAt ?? DateTime.fromMillisecondsSinceEpoch(0);
  bool get isSystemMessage => systemMessage != null;
  bool get isChat => chat != null;
}
