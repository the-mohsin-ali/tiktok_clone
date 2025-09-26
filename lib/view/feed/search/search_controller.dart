import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:tiktok_clone/constants/utils/utils.dart';
import 'package:tiktok_clone/interfaces/video_list_controller.dart';
import 'package:tiktok_clone/models/follow_user_model.dart';
import 'package:tiktok_clone/models/user_model.dart';
import 'package:tiktok_clone/models/video_model.dart';
import 'package:tiktok_clone/view/inbox_view/inbox_controller.dart';

class SearchController extends GetxController implements VideoListController {
  final RxList<UserModel> users = <UserModel>[].obs;
  final RxList<VideoModel> videos = <VideoModel>[].obs;
  final RxBool isLoading = false.obs;

  Future<void> search(String query) async {
    if (query.trim().isEmpty) return;

    isLoading.value = true;

    // 🔎 Search Users
    final usersSnap = await FirebaseFirestore.instance
        .collection('users')
        .where('userName', isGreaterThanOrEqualTo: query)
        .where('userName', isLessThanOrEqualTo: query + '\uf8ff')
        .get();

    users.assignAll(usersSnap.docs.map((d) => UserModel.fromMap(d.data())));

    // 🔎 Search Videos (title OR username OR keywords)
    final videosSnap = await FirebaseFirestore.instance
        .collection('videos')
        .where(
          Filter.or(
            Filter('keywords', arrayContains: query.toLowerCase()),
            Filter.and(
              Filter('videoTitle', isGreaterThanOrEqualTo: query),
              Filter('videoTitle', isLessThanOrEqualTo: query + '\uf8ff'),
            ),
            Filter.and(
              Filter('userName', isGreaterThanOrEqualTo: query),
              Filter('userName', isLessThanOrEqualTo: query + '\uf8ff'),
            ),
          ),
        )
        .get();

    videos.assignAll(videosSnap.docs.map((d) => VideoModel.fromDocument(d)).toList());

    isLoading.value = false;
  }

  final Map<String, Timer> _debounceTimers = {};
  @override
  Future<void> addLike(VideoModel video) async {
    final videoId = video.videoId;

    final currentUid = FirebaseAuth.instance.currentUser!.uid;
    final isLiked = video.likedBy.contains(currentUid);

    int index = videos.indexWhere((v) => v.videoId == videoId);
    if (index != -1) {
      final updatedLikedBy = List<String>.from(video.likedBy);
      int updatedLikeCount = video.likeCount;
      if (isLiked) {
        updatedLikedBy.remove(currentUid);
        updatedLikeCount -= 1;
      } else {
        updatedLikedBy.add(currentUid);
        updatedLikeCount += 1;
      }
      videos[index] = video.copyWith(likedBy: updatedLikedBy, likeCount: updatedLikeCount);
      videos.refresh(); // Force UI update
    }

    _debounceTimers[videoId]?.cancel();

    _debounceTimers[videoId] = Timer(const Duration(milliseconds: 500), () async {
      final docRef = FirebaseFirestore.instance.collection('videos').doc(video.videoId);
      final userRef = FirebaseFirestore.instance.collection('users').doc(video.uid);
      try {
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          final videoSnapshot = await transaction.get(docRef);
          final userSnapshot = await transaction.get(userRef);

          if (!videoSnapshot.exists || !userSnapshot.exists) {
            throw Exception('Document does not exists');
          }

          final currentLikes = userSnapshot.data()?['likes'] ?? 0;

          transaction.update(docRef, {
            'likedBy': isLiked ? FieldValue.arrayRemove([currentUid]) : FieldValue.arrayUnion([currentUid]),
            'likeCount': isLiked ? video.likeCount - 1 : video.likeCount + 1,
          });

          if (isLiked && currentLikes <= 0) {
          } else {
            transaction.update(userRef, {'likes': FieldValue.increment(isLiked ? -1 : 1)});
          }
        });
      } catch (e) {
        print('Error toggling like: $e');
        Utils.snackBar('Error', 'Failed to toggle like');
      } finally {
        _debounceTimers.remove(videoId);
      }
    });
  }

  @override
  Future<void> followUser(String posterUid, String videoId) async {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final currentUid = currentUser.uid;

    if (posterUid == currentUid) return; // apne aap ko follow nahi karna

    final currentUserDoc = FirebaseFirestore.instance.collection('users').doc(currentUid);
    final targetUserDoc = FirebaseFirestore.instance.collection('users').doc(posterUid);

    try {
      // current user data fetch karo
      final currentUserSnap = await currentUserDoc.get();
      if (!currentUserSnap.exists) return;

      final currentUserData = currentUserSnap.data()!;
      final currentFollowUser = FollowUserModel(
        uid: currentUserData['uid'],
        profilePhoto: currentUserData['profilePhoto'] ?? '',
        userName: currentUserData['userName'] ?? '',
      );

      // check if already following
      final followerDoc = await targetUserDoc.collection('followers').doc(currentUid).get();
      final isAlreadyFollowing = followerDoc.exists;

      if (isAlreadyFollowing) {
        // 🔹 UNFOLLOW
        await targetUserDoc.collection('followers').doc(currentUid).delete();
        await currentUserDoc.collection('following').doc(posterUid).delete();

        // Update local video state
        final index = videos.indexWhere((v) => v.videoId == videoId);
        if (index != -1) {
          videos[index] = videos[index].copyWith(isFollowingThisPoster: false);
          videos.refresh();
        }

        if (Get.isRegistered<InboxController>()) {
          Get.find<InboxController>().removeFollowPromptForUser(posterUid);
        }

        await targetUserDoc.collection('system_messages').doc(currentUid).delete();

        Utils.snackBar("Unfollowed", "You unfollowed this user");
      } else {
        // 🔹 FOLLOW
        await targetUserDoc.collection('followers').doc(currentUid).set(currentFollowUser.toMap());

        await currentUserDoc
            .collection('following')
            .doc(posterUid)
            .set(
              FollowUserModel(
                uid: posterUid,
                profilePhoto: '', // we'll fill it below
                userName: '', // we'll fill it below
              ).toMap(),
            );

        // fetch target user data to fill properly
        final targetSnap = await targetUserDoc.get();
        if (targetSnap.exists) {
          final targetUser = UserModel.fromMap(targetSnap.data()!);

          await currentUserDoc.collection('following').doc(posterUid).update({
            'profilePhoto': targetUser.profilePhoto ?? '',
            'userName': targetUser.userName,
          });

          // Update local video state
          final index = videos.indexWhere((v) => v.videoId == videoId);
          if (index != -1) {
            videos[index] = videos[index].copyWith(isFollowingThisPoster: true);
            videos.refresh();
          }

          // Inbox prompt handling
          if (Get.isRegistered<InboxController>()) {
            final inboxController = Get.find<InboxController>();
            if (!inboxController.hasFollowPrompt(targetUser.uid)) {
              inboxController.addFollowPrompt(isReverse: false, user: targetUser);
            }
          }

          // reverse prompt bhejna
          await _sendReversePromptToFollowedUserInbox();
        }

        Utils.snackBar("Followed", "You are now following this user");
      }
    } catch (e) {
      print("Error following user: $e");
      Utils.snackBar("Error", "Failed to update follow state");
    }
  }

  @override
  // TODO: implement userVideos
  RxList<VideoModel> get userVideos => videos;

  Future<void> _sendReversePromptToFollowedUserInbox() async {
    final currentUserUid = FirebaseAuth.instance.currentUser!.uid;

    final currentUserSnapshot = await FirebaseFirestore.instance.collection('users').doc(currentUserUid).get();

    if (!currentUserSnapshot.exists) return;

    final currentUser = UserModel.fromMap(currentUserSnapshot.data()!);

    if (Get.isRegistered<InboxController>()) {
      Get.find<InboxController>().addFollowPrompt(isReverse: true, user: currentUser);
    }
  }
}
