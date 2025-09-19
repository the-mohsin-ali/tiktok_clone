import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart' as dio;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tiktok_clone/models/chat_model.dart';
import 'package:tiktok_clone/models/enumns.dart';
import 'package:tiktok_clone/models/message_model.dart';
import 'package:tiktok_clone/models/user_model.dart';
import 'package:tiktok_clone/view/inbox_view/chat/media_preview_screen.dart';
import 'package:tuple/tuple.dart';

class ChatController extends GetxController {
  String chatId;
  final String currentUserId;

  ChatController({required this.chatId, required this.currentUserId});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Current chat and messages
  Rxn<ChatModel> currentChat = Rxn<ChatModel>();
  RxList<MessageModel> messages = <MessageModel>[].obs;

  var isInitialLoading = true.obs;

  // User cache for sender info
  RxMap<String, UserModel> userCache = <String, UserModel>{}.obs;

  final ScrollController scrollController = ScrollController();
  RxBool showScrollToBottomBtn = false.obs;

  StreamSubscription? _messageSubscription;

  // Pagination helpers
  DocumentSnapshot? oldestMessageDoc;
  bool hasMore = true;
  bool isLoadingMore = false;
  final int pageSize = 10;

  @override
  void onInit() {
    super.onInit();
    print('ChatController onInit called()');
    loadChat(chatId);
    setupScrollListener();
    // loadOlderMessages(initial: true);
  }

  @override
  void onClose() {
    _messageSubscription?.cancel();
    scrollController.dispose();
    super.onClose();
  }

  void setupScrollListener() {
    scrollController.addListener(() {
      if (!scrollController.hasClients) return;

      final current = scrollController.offset;

      // ✅ FAB: jab neeche se 100px upar scroll kare to button show ho
      final max = scrollController.position.maxScrollExtent;
      showScrollToBottomBtn.value = (max - current) > 100;

      // ✅ older messages load jab bilkul top (offset ~0) par pohonch jao
      if (scrollController.position.userScrollDirection == ScrollDirection.forward &&
          scrollController.position.pixels <= 100 &&
          hasMore &&
          !isLoadingMore) {
        loadOlderMessages();
      }
    });
  }

  Future<void> updateController(String newChatId) async {
    // if(chatId == newChatId){
    //   print('Chat Already Loaded');
    //   return;
    // }

    chatId = newChatId;
    currentChat.value = null;
    messages.clear();
    userCache.clear();
    oldestMessageDoc = null;
    hasMore = true;

    print('ChatController updateController called');
    loadChat(chatId);
  }

  // Load chat by ID (and its messages)
  Future<void> loadChat(String chatId) async {
    try {
      isInitialLoading.value = true;

      print("[loadChat] loadChat called");

      final chatSnap = await _firestore.collection('chats').doc(chatId).get();

      if (!chatSnap.exists) {
        currentChat.value = null;
        messages.clear();
        return;
      }

      currentChat.value = ChatModel.fromJson(chatSnap.data()!, chatSnap.id);

      await preloadUsers(currentChat.value!.participants);

      // 🔹 First fetch: initial 20 messages (oldest → newest)
      final snap = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('createdAt', descending: true)
          .limit(pageSize)
          .get();

      if (snap.docs.isNotEmpty) {
        oldestMessageDoc = snap.docs.last;

        final initialMessages = snap.docs
            .map((doc) => MessageModel.fromJson(doc.data(), doc.id))
            .toList()
            .reversed
            .toList(); // oldest → newest

        print("[loadChat] before assigning messages list: ${messages.length}");

        messages.assignAll(initialMessages);

        print("[loadChat] after assigning messages list: ${messages.length}");

        // if we got less than pageSize, means no more data
        if (snap.docs.length < pageSize) {
          hasMore = false;
        }

        // scroll to bottom on first load
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (scrollController.hasClients) {
            scrollController.jumpTo(scrollController.position.maxScrollExtent);
          }
        });
      }
      // Only start listener, no initial pagination
      listenToLatestMessages(chatId);
    } catch (e) {
      print('error: $e');
    } finally {
      isInitialLoading.value = false;
    }
  }

  // Listen to messages in real time
  void listenToLatestMessages(String chatId) {
    _messageSubscription?.cancel();

    _messageSubscription = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .limit(1) // only listen for *new* incoming messages
        .snapshots()
        .listen((snapshot) {
          for (final doc in snapshot.docs) {
            final msg = MessageModel.fromJson(doc.data(), doc.id);
            if (!messages.any((m) => m.id == msg.id)) {
              messages.add(msg);
            }
          }
          // auto-scroll to bottom if needed
          if (scrollController.hasClients &&
              scrollController.position.pixels >= scrollController.position.maxScrollExtent - 50) {
            Future.delayed(const Duration(milliseconds: 50), () {
              scrollController.jumpTo(scrollController.position.maxScrollExtent);
            });
          }
        });
  }

  Future<void> loadOlderMessages() async {
    print("[loadOlderMessages] loadOlderMessages() called");

    if (isLoadingMore || !hasMore) return;

    isLoadingMore = true;

    Query query = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .limit(pageSize);

    if (oldestMessageDoc != null) {
      query = query.startAfterDocument(oldestMessageDoc!);
    }

    final snapShot = await query.get();

    if (snapShot.docs.isNotEmpty) {
      oldestMessageDoc = snapShot.docs.last;
      final olderMessages = snapShot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return MessageModel.fromJson(data, doc.id);
          })
          .toList()
          .reversed
          .toList();

      print("[loadOlderMessages] before insert ${messages.length}");

      for (final msg in olderMessages) {
        if (!messages.any((m) => m.id == msg.id)) {
          messages.insert(0, msg);
        }
      }

      // // Insert at the beginning but flip them so order remains oldest → newest
      // messages.insertAll(0, olderMessages.reversed);

      print("[loadOlderMessages] after insert ${messages.length}");

      // if we got less than pageSize, means no more data
      if (snapShot.docs.length < pageSize) {
        hasMore = false;
      }
    } else {
      hasMore = false;
    }

    isLoadingMore = false;
  }

  // Preload participants into userCache
  Future<void> preloadUsers(List<String> userIds) async {
    final users = await _firestore.collection('users').where('uid', whereIn: userIds).get();

    for (var doc in users.docs) {
      final user = UserModel.fromMap(doc.data());
      userCache[user.uid] = user;
    }
  }

  Future<void> handleMediaAttachment({required String type, required String otherUserId, String? chatId}) async {
    File? selectedFile;
    final picker = ImagePicker();

    // 1. Pick media
    switch (type) {
      case 'camera_image':
        final picked = await picker.pickImage(source: ImageSource.camera);
        if (picked != null) selectedFile = File(picked.path);
        break;
      case 'camera_video':
        final picked = await picker.pickVideo(source: ImageSource.camera);
        if (picked != null) selectedFile = File(picked.path);
        break;
      case 'gallery':
        final picked = await picker.pickMedia(); // gallery (image or video)
        if (picked != null) selectedFile = File(picked.path);
        break;
    }

    if (selectedFile == null) return;

    // 2. Show preview before uploading
    final bool? confirmed = await Get.to(() => MediaPreviewScreen(file: selectedFile!));
    if (confirmed != true) return;

    // 3. Upload and send
    await _uploadAndSendMedia(file: selectedFile, otherUserId: otherUserId, existingChatId: chatId);
  }

  Future<void> _uploadAndSendMedia({required File file, required String otherUserId, String? existingChatId}) async {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    // Create or use existing chat
    final result = await createOrGetDirectChat(currentUserId, otherUserId);
    final chatId = result.item1;
    final isNew = result.item2;

    if (isNew || existingChatId == null) {
      await updateController(chatId);
    }

    // Upload to Cloudinary
    final mediaUrl = await _uploadToCloudinary(file);

    final MessageType messageType = file.path.endsWith('.mp4') || file.path.endsWith('.mov')
        ? MessageType.video
        : MessageType.image;

    // Send message
    await sendMessage(chatId: chatId, senderId: currentUserId, text: '', type: messageType, mediaUrl: mediaUrl);
  }

  Future<String> _uploadToCloudinary(File file) async {
    final cloudName = 'dlvhzlppm';
    final uploadPreset = 'chat_files';

    final url = 'https://api.cloudinary.com/v1_1/$cloudName/auto/upload';

    final formData = dio.FormData.fromMap({
      'file': await dio.MultipartFile.fromFile(file.path),
      'upload_preset': uploadPreset,
    });

    final response = await dio.Dio().post(url, data: formData);

    if (response.statusCode == 200) {
      return response.data['secure_url'];
    } else {
      throw Exception('Cloudinary upload failed');
    }
  }

  // Send a message
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
    MessageType type = MessageType.text,
    String? mediaUrl,
  }) async {
    final messageRef = _firestore.collection('chats').doc(chatId).collection('messages').doc();

    final message = MessageModel(
      id: messageRef.id,
      senderId: senderId,
      text: text,
      mediaUrl: mediaUrl,
      createdAt: DateTime.now(),
      readBy: [senderId],
      messageType: type,
    );

    await messageRef.set(message.toJson(useServerTimestamp: true));

    try {
      await _firestore.collection('chats').doc(chatId).update({
        'lastMessage': text.isNotEmpty ? text : (type == MessageType.image ? 'Photo' : 'Video'),
        'lastMessageBy': senderId,
        'lastMessageAt': FieldValue.serverTimestamp(),
      });
      // ensure scroll goes to bottom after sending
      Future.delayed(const Duration(milliseconds: 100), () {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      print('⚠️ Failed to update lastMessage: $e');
    }
  }

  // Create new 1-to-1 chat (if doesn't exist)

  Future<Tuple2<String, bool>> createOrGetDirectChat(String uid1, String uid2) async {
    final ids = [uid1, uid2]..sort();
    final chatId = ids.join('_');
    final doc = await _firestore.collection('chats').doc(chatId).get();
    final isNew = !doc.exists;

    if (isNew) {
      await _firestore.collection('chats').doc(chatId).set({
        'type': 'direct',
        'participants': ids,
        'lastMessage': '',
        'lastMessageBy': '',
        'lastMessageAt': FieldValue.serverTimestamp(),
      });
    }

    return Tuple2(chatId, isNew);
  }

  // Create a group chat
  Future<String> createGroupChat({
    required String groupName,
    required List<String> participants,
    String? groupPhoto,
  }) async {
    final docRef = _firestore.collection('chats').doc();

    await docRef.set({
      'type': 'group',
      'participants': participants,
      'groupName': groupName,
      'groupPhoto': groupPhoto,
      'lastMessage': '',
      'lastMessageBy': '',
      'lastMessageAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }
}
