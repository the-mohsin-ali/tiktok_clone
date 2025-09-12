import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:tiktok_clone/constants/utils/utils.dart';
import 'package:tiktok_clone/models/comments_model.dart';
import 'package:tiktok_clone/services/shared_prefs.dart';

class CommentsController extends GetxController {
  RxString? profileUrl = ''.obs;
  RxString userName = ''.obs;
  TextEditingController commentController = TextEditingController();
  final FocusNode commentFocusNode = FocusNode();
  final isFormFilled = false.obs;

  RxList<CommentsModel> comments = <CommentsModel>[].obs;
  StreamSubscription? _commentsSub;
  // late final Stream<List<CommentsModel>> commentsStream;

  final Rxn<CommentsModel> replyingTo = Rxn<CommentsModel>();

  @override
  void onInit() {
    super.onInit();
    _getProfile();
    commentController.addListener(_checkCommentFormStatus);
  }

  @override
  void onClose() {
    _commentsSub?.cancel();
    commentFocusNode.dispose();
    super.onClose();
  }

  void initComments(String videoId) {
    // commentsStream = getCommentsForVideo(videoId);
    _commentsSub?.cancel();
    _commentsSub = getCommentsForVideo(videoId).listen((data) {
      comments.assignAll(data);
    });
  }

  void clearFields() {
    commentController.clear();
    isFormFilled.value = false;
  }

  void _checkCommentFormStatus() {
    final text = commentController.text.trim();
    if (replyingTo.value != null) {
      final mention = "@${replyingTo.value!.userName}";
      isFormFilled.value =
          commentController.text.trim().startsWith(mention) && commentController.text.trim().length > mention.length;
    } else {
      isFormFilled.value = commentController.text.trim().isNotEmpty;
    }

    print('Comment Form filled status: ${isFormFilled.value}');
  }

  Future<void> _getProfile() async {
    // final url = await SharedPrefs.getProfileUrl() ?? '';
    // profileUrl?.value = url ;
    // final name = await SharedPrefs.getUserName();
    // userName.value = name;
    final userData = await SharedPrefs.getUserFromPrefs();
    if (userData != null) {
      profileUrl?.value = userData.profilePhoto!;
      userName.value = userData.userName;
    }
    print("Loaded profile URL & userName in getProfileurl method: ${profileUrl?.value} && ${userName.value}");
    print("Loaded userName in getProfileUrl method: ${userName.value}");
  }

  Stream<List<CommentsModel>> getCommentsForVideo(String videoId) {
    return FirebaseFirestore.instance
        .collection('videos')
        .doc(videoId)
        .collection('comments')
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((snapshots) {
          return snapshots.docs.map((doc) {
            return CommentsModel.fromJson(doc.data(), doc.id);
          }).toList();
        });
  }

  Future<void> addComment(String videoId) async {
    final comment = CommentsModel(
      commentId: '',
      avatarUrl: profileUrl?.value,
      userName: userName.value,
      comment: commentController.text,
      uploadedAt: DateTime.now(),
      likedBy: [],
    );
    final commentsRef = FirebaseFirestore.instance.collection('videos').doc(videoId).collection('comments');

    final videoRef = FirebaseFirestore.instance.collection('videos').doc(videoId);
    try {
      final newDoc = await commentsRef.add(comment.toJson());
      await newDoc.update({'commentId': newDoc.id});

      // final querySnapshot = await commentsRef.get();
      // final commentCount = querySnapshot.docs.length;

      await videoRef.update({'commentCount': FieldValue.increment(1)});

      clearFields();
    } catch (e) {
      Utils.snackBar('Error', 'Error posting comment');
      print('Error posting comment: $e');
    }
  }

  void startReplyTo(CommentsModel comment) {
    replyingTo.value = comment;
    commentController.text = "@${comment.userName} ";
    commentController.selection = TextSelection.fromPosition(TextPosition(offset: commentController.text.length));
    commentFocusNode.requestFocus();
  }

  void cancelReply() {
    replyingTo.value = null;
    commentController.clear();
    commentFocusNode.unfocus();
  }

  Future<void> addReply(String videoId, String parentCommentId) async {
    final currentUser = await SharedPrefs.getUserFromPrefs();
    if (currentUser == null) return;

    String replyText = commentController.text.trim();
    final mention = "@${replyingTo.value?.userName ?? ''}";

    // Remove the mention if it's at the start
    if (replyText.startsWith(mention)) {
      replyText = replyText.substring(mention.length).trim();
    }

    // Don't allow empty replies
    if (replyText.isEmpty) {
      Utils.snackBar("Error", "Reply cannot be empty.");
      return;
    }

    print("value in replytext: $replyText");

    final reply = CommentsModel(
      commentId: '',
      avatarUrl: currentUser.profilePhoto,
      userName: currentUser.userName,
      comment: replyText,
      uploadedAt: DateTime.now(),
      likedBy: [],
      isReply: true,
      parentCommentId: parentCommentId,
    );

    final videoRef = FirebaseFirestore.instance.collection('videos').doc(videoId);

    try {
      final newDoc = await FirebaseFirestore.instance
          .collection('videos')
          .doc(videoId)
          .collection('comments')
          .add(reply.toJson());
      newDoc.update({'commentId': newDoc.id});

      await videoRef.update({'commentCount': FieldValue.increment(1)});
      clearFields();
    } catch (e) {
      Utils.snackBar('Error', 'Failed to post reply');
      print("Reply error: $e");
    }
  }

  Stream<List<CommentsModel>> getReplies(String videoId, String parentId) {
    return FirebaseFirestore.instance
        .collection('videos')
        .doc(videoId)
        .collection('comments')
        .where('isReply', isEqualTo: true)
        .where('parentCommentId', isEqualTo: parentId)
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((snapshots) {
          return snapshots.docs.map((doc) {
            return CommentsModel.fromJson(doc.data(), doc.id);
          }).toList();
        });
  }

  final Map<String, Timer> _debounceTimers = {};

  Future<void> likeComment(String videoId, String commentId) async {
    final currentUid = SharedPrefs.cachedUid;

    final index = comments.indexWhere((c) => c.commentId == commentId);
    if (index == -1) return;

    final comment = comments[index];
    final isLiked = comment.likedBy.contains(currentUid);

    final updatedLikedBy = List<String>.from(comment.likedBy);
    if (isLiked) {
      updatedLikedBy.remove(currentUid);
    } else {
      updatedLikedBy.add(currentUid!);
    }

    comments[index] = comment.copyWith(likedBy: updatedLikedBy);

    _debounceTimers[commentId]?.cancel();

    _debounceTimers[commentId] = Timer(const Duration(milliseconds: 500), () async {
      final commentRef = FirebaseFirestore.instance
          .collection('videos')
          .doc(videoId)
          .collection('comments')
          .doc(commentId);
      try {
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          final commentSnapshot = await transaction.get(commentRef);
          if (!commentSnapshot.exists) {
            print('Document doesnt exist');
            return;
          }
          final data = commentSnapshot.data()!;
          final List<dynamic> likedBy = List.from(data['likedBy'] ?? []);
          final isLiked = likedBy.contains(currentUid);

          final updatedLikedBy = isLiked ? FieldValue.arrayRemove([currentUid]) : FieldValue.arrayUnion([currentUid]);

          transaction.update(commentRef, {'likedBy': updatedLikedBy});
        });
      } catch (e) {
        Utils.snackBar("Error", 'Error liking comment');
        print("Error liking commnet: $e");
      } finally {
        _debounceTimers.remove(commentId);
      }
    });
  }

  Future<void> deleteComment(String videoId, String commentId) async {
    final commentRef = FirebaseFirestore.instance.collection('videos').doc(videoId).collection('comments');

    final videoRef = FirebaseFirestore.instance.collection('videos').doc(videoId);

    try {
      // Delete the parent comment
      await commentRef.doc(commentId).delete();

      int deleteCount = 1; // Start with 1 (the parent)

      // Also delete all replies
      final repliesSnapshot = await commentRef.where('parentCommentId', isEqualTo: commentId).get();

      for (final doc in repliesSnapshot.docs) {
        await doc.reference.delete();
        deleteCount++;
      }

      // Decrement commentCount by total deleted
      await videoRef.update({'commentCount': FieldValue.increment(-deleteCount)});
    } catch (e) {
      Utils.snackBar("Error", "Error deleting comment");
      print('Error deleting comment: $e');
    }
  }
}
