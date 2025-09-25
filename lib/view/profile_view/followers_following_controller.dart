import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tiktok_clone/constants/utils/utils.dart';
import 'package:tiktok_clone/models/follow_user_model.dart';
import 'package:tiktok_clone/models/system_message.dart';
import 'package:tiktok_clone/models/user_model.dart';
import 'package:tiktok_clone/view/inbox_view/inbox_controller.dart';

class FollowersFollowingController extends GetxController {
  final String targetUid; // jis user ki profile dekhni hai
  FollowersFollowingController({required this.targetUid});

  /// 0 = Following, 1 = Followers
  RxInt tabIndex = 0.obs;

  /// search text
  // RxString searchQuery = ''.obs;

  static const int pageSize = 20;
  DocumentSnapshot? _lastFollowingDoc;
  DocumentSnapshot? _lastFollowerDoc;

  bool _isFetchingFollowers = false;
  bool _isFetchingFollowing = false;

  /// debouncer
  Timer? _debounce;
  final TextEditingController searchController = TextEditingController();

  /// lists
  RxList<FollowUserModel> followers = <FollowUserModel>[].obs;
  RxList<FollowUserModel> following = <FollowUserModel>[].obs;

  /// filtered lists
  RxList<FollowUserModel> filteredFollowers = <FollowUserModel>[].obs;
  RxList<FollowUserModel> filteredFollowing = <FollowUserModel>[].obs;

  RxSet<String> alreadyFollowing = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    // _listenFollowers();
    // _listenFollowing();
    fetchFollowersPage(reset: true);
    fetchFollowingPage(reset: true);
    listenToMyFollowing();

    /// jab searchQuery change ho to filter apply karo
    // ever(searchQuery, (_) => _onSearchChanged(searchQuery.value));

    searchController.addListener(() {
      _onSearchChanged(searchController.text);
    });
  }

  Future<void> fetchFollowersPage({bool reset = false}) async {
    if (_isFetchingFollowers) return;
    _isFetchingFollowers = true;

    try {
      Query query = FirebaseFirestore.instance
          .collection('users')
          .doc(targetUid)
          .collection('followers')
          .orderBy(FieldPath.documentId) // important for pagination
          .limit(pageSize);

      if (!reset && _lastFollowerDoc != null) {
        query = query.startAfterDocument(_lastFollowerDoc!);
      }

      final snap = await query.get();

      if (reset) followers.clear();

      if (snap.docs.isNotEmpty) {
        _lastFollowerDoc = snap.docs.last;
        followers.addAll(
          snap.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>?;
            return FollowUserModel.fromMap({...?data, 'uid': doc.id});
          }).toList(),
        );
        filteredFollowers.value = followers;
      }
    } catch (e) {
      print("Error fetching followers: $e");
    } finally {
      _isFetchingFollowers = false;
    }
  }

  Future<void> fetchFollowingPage({bool reset = false}) async {
    if (_isFetchingFollowing) return;
    _isFetchingFollowing = true;

    try {
      Query query = FirebaseFirestore.instance
          .collection('users')
          .doc(targetUid)
          .collection('following')
          .orderBy(FieldPath.documentId)
          .limit(pageSize);

      if (!reset && _lastFollowingDoc != null) {
        query = query.startAfterDocument(_lastFollowingDoc!);
      }

      final snap = await query.get();

      if (reset) following.clear();

      if (snap.docs.isNotEmpty) {
        _lastFollowingDoc = snap.docs.last;
        following.addAll(
          snap.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>?;
            return FollowUserModel.fromMap({
              ...?data, // 👈 null-aware spread
              'uid': doc.id,
            });
          }).toList(),
        );
        filteredFollowing.value = following;
      }
    } catch (e) {
      print("Error fetching following: $e");
    } finally {
      _isFetchingFollowing = false;
    }
  }

  void listenToMyFollowing() async {
    final currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore.instance.collection('users').doc(currentUserUid).collection('following').snapshots().listen((
      snap,
    ) {
      alreadyFollowing.assignAll(snap.docs.map((d) => d.id));
    });
  }

  /// handle search with debounce
  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      if (query.isEmpty) {
        filteredFollowers.value = followers;
        filteredFollowing.value = following;
      } else {
        await searchFollowersFromDb(query);
        await searchFollowingFromDb(query);
      }
    });
  }

  /// filter logic

  Future<void> searchFollowersFromDb(String query) async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(targetUid)
          .collection('followers')
          .where('userName', isGreaterThanOrEqualTo: query)
          .where('userName', isLessThan: '$query\uf8ff')
          .limit(20)
          .get();

      filteredFollowers.value = snap.docs.map((doc) {
        return FollowUserModel.fromMap({...doc.data(), 'uid': doc.id});
      }).toList();
    } catch (e) {
      print("Error searching followers $e");
    }
  }

  Future<void> searchFollowingFromDb(String query) async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(targetUid)
          .collection('following')
          .where('userName', isGreaterThanOrEqualTo: query)
          .where('userName', isLessThan: '$query\uf8ff')
          .limit(20)
          .get();

      filteredFollowing.value = snap.docs.map((doc) {
        return FollowUserModel.fromMap({...doc.data(), 'uid': doc.id});
      }).toList();
    } catch (e) {
      print("Error searching following $e");
    }
  }

  Future<void> toggleFollow(UserModel targetUser) async {
    final currentUid = FirebaseAuth.instance.currentUser!.uid;
    final currentUserDoc = FirebaseFirestore.instance.collection('users').doc(currentUid);
    final targetUserDoc = FirebaseFirestore.instance.collection('users').doc(targetUser.uid);

    final currentUserSnap = await currentUserDoc.get();
    final currentUserData = currentUserSnap.data()!;

    final currentFollowUser = FollowUserModel(
      uid: currentUserData['uid'],
      profilePhoto: currentUserData['profilePhoto'] ?? '',
      userName: currentUserData['userName'] ?? '',
    );

    final isAlreadyFollowing = alreadyFollowing.contains(targetUser.uid);

    if (isAlreadyFollowing) {
      try {
        await targetUserDoc.collection('followers').doc(currentUid).delete();
        await currentUserDoc.collection('following').doc(targetUser.uid).delete();
        alreadyFollowing.remove(targetUser.uid);

        if (Get.isRegistered<InboxController>()) {
          Get.find<InboxController>().removeFollowPromptForUser(targetUser.uid);
        }

        await targetUserDoc.collection('system_messages').doc(currentUid).delete();
      } catch (e) {
        print("Unable to unfollow: $e");
        Utils.snackBar("Error", "Unable to unfollow");
      }
    } else {
      try {
        await targetUserDoc.collection('followers').doc(currentUid).set(currentFollowUser.toMap());

        await currentUserDoc
            .collection('following')
            .doc(targetUser.uid)
            .set(
              FollowUserModel(
                uid: targetUser.uid,
                profilePhoto: targetUser.profilePhoto ?? '',
                userName: targetUser.userName,
              ).toMap(),
            );

        alreadyFollowing.add(targetUser.uid);

        if (Get.isRegistered<InboxController>()) {
          final inboxController = Get.find<InboxController>();
          if (!inboxController.hasFollowPrompt(targetUser.uid)) {
            inboxController.addFollowPrompt(isReverse: false, user: targetUser);
          }
        }
      } catch (e) {
        print("Unable to follow: $e");
        Utils.snackBar("Error", "Unable to follow");
      }
    }
  }

  void _sendReversePromptToFollowedUserInbox() async {
    final currentUserUid = FirebaseAuth.instance.currentUser!.uid;

    final currentUserSnapshot = await FirebaseFirestore.instance.collection('users').doc(currentUserUid).get();

    if (!currentUserSnapshot.exists) return;

    final currentUser = UserModel.fromMap(currentUserSnapshot.data()!);

    final followedUserId = targetUid; // The user you’re viewing

    final prompt = SystemMessage(
      userId: currentUser.uid,
      userName: currentUser.userName,
      userPhotoUrl: currentUser.profilePhoto ?? '',
      message: "${currentUser.userName} started following you. Say hi!",
      time: DateTime.now(),
    );

    await FirebaseFirestore.instance
        .collection('users')
        .doc(followedUserId)
        .collection('system_messages')
        .doc(currentUser.uid)
        .set(prompt.toJson());
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }
}
