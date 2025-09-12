import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:tiktok_clone/constants/utils/utils.dart';
import 'package:tiktok_clone/interfaces/video_list_controller.dart';
import 'package:tiktok_clone/models/system_message.dart';
import 'package:tiktok_clone/models/user_model.dart';
import 'package:tiktok_clone/models/video_model.dart';
import 'package:tiktok_clone/view/inbox_view/inbox_controller.dart';

class SearchedProfileController extends GetxController implements VideoListController {
  final String uid;
  final Rxn<UserModel> user = Rxn<UserModel>();
  final RxBool isFollowing = false.obs;
  RxInt totalLikes = 0.obs;
  RxList<VideoModel> userVideos = <VideoModel>[].obs;
  final RxList<SystemMessage> system_message = <SystemMessage>[].obs;

  SearchedProfileController(this.uid);

  late final String currentUserUid;

  @override
  void onInit() {
    super.onInit();
    currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    fetchUser();
    // checkIfFollowing(user.value?.uid);
  }

  bool get isCurrentUser => uid == currentUserUid;

  void checkIfFollowing(String posterUid) {
    final currentUid = FirebaseAuth.instance.currentUser!.uid;
    isFollowing.value = user.value?.followers.contains(currentUid) ?? false;
  }

  void fetchUser() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (snapshot.exists) {
      user.value = UserModel.fromMap(snapshot.data()!);
      final currentUid = FirebaseAuth.instance.currentUser!.uid;
      isFollowing.value = user.value!.followers.contains(currentUid);

      final videoSnapshot = await FirebaseFirestore.instance.collection('videos').where('uid', isEqualTo: uid).get();
      userVideos.value = videoSnapshot.docs.map((d) => VideoModel.fromJson(d.data(), d.id)).toList();
      totalLikes.value = user.value!.likes;
    }
  }

  void toggleFollow() async {
    final currentUid = FirebaseAuth.instance.currentUser!.uid;
    final ref = FirebaseFirestore.instance.collection('users').doc(uid);

    if (isCurrentUser) return;

    if (isFollowing.value) {
      try {
        await ref.update({
          'followers': FieldValue.arrayRemove([currentUid]),
        });
        isFollowing.value = false;

        if (Get.isRegistered<InboxController>()) {
          Get.find<InboxController>().removeFollowPromptForUser(uid);
        }

        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid) // 👈 the user you are unfollowing
            .collection('system_messages')
            .doc(currentUid) // 👈 your own UID (you were the one who followed them)
            .delete();
      } catch (e) {
        print("Unable to unfollow: $e");
        Utils.snackBar("Error", "Unable to unfollow");
      }
    } else {
      try {
        await ref.update({
          'followers': FieldValue.arrayUnion([currentUid]),
        });
        isFollowing.value = true;

        if (user.value != null) {
          final inboxController = Get.find<InboxController>();

          if (!inboxController.hasFollowPrompt(user.value!.uid)) {
            inboxController.addFollowPrompt(isReverse: false, user: user.value!);
          }

          _sendReversePromptToFollowedUserInbox();
        }
      } catch (e) {
        print("Unable to follow: $e");
        Utils.snackBar("Error", "Unable to follow");
      }
    }

    fetchUser(); // refresh data
  }

  void _sendReversePromptToFollowedUserInbox() async {
    final currentUserUid = FirebaseAuth.instance.currentUser!.uid;

    final currentUserSnapshot = await FirebaseFirestore.instance.collection('users').doc(currentUserUid).get();

    if (!currentUserSnapshot.exists) return;

    final currentUser = UserModel.fromMap(currentUserSnapshot.data()!);

    final followedUserId = uid; // The user you’re viewing

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
  void addLike(VideoModel video) async {
    final currentUid = FirebaseAuth.instance.currentUser!.uid;
    final isLiked = video.likedBy.contains(currentUid);

    int index = userVideos.indexWhere((v) => v.videoId == video.videoId);
    if (index != -1) {
      final updatedLikedBy = List<String>.from(video.likedBy);
      int updatedLikeCount = video.likeCount;
      if (isLiked) {
        updatedLikedBy.remove(currentUid);
        updatedLikeCount--;
      } else {
        updatedLikedBy.add(currentUid);
        updatedLikeCount++;
      }
      userVideos[index] = video.copyWith(likedBy: updatedLikedBy, likeCount: updatedLikeCount);
      userVideos.refresh();

      final videoRef = FirebaseFirestore.instance.collection('videos').doc(video.videoId);
      await videoRef.update({
        'likedBy': isLiked ? FieldValue.arrayRemove([currentUid]) : FieldValue.arrayUnion([currentUid]),
        'likeCount': updatedLikeCount,
      });
    }
  }
}
