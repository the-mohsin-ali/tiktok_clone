import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:tiktok_clone/constants/utils/utils.dart';
import 'package:tiktok_clone/models/comments_model.dart';
import 'package:tiktok_clone/models/threaded_comments.dart';
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

  RxList<ThreadedComment> threadedComments = <ThreadedComment>[].obs;
  // Track "view more" states
  final RxMap<String, bool> isLoadingReplies = <String, bool>{}.obs;
  final RxMap<String, bool> hasMoreReplies = <String, bool>{}.obs;

  final Map<String, DocumentSnapshot> _lastReplyDoc = {};

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

  void initComments(String videoId) async {
    _lastReplyDoc.clear();

    // threadedComments.clear();

    // comments.clear();

    _commentsSub?.cancel();
    // _commentsSub = FirebaseFirestore.instance
    //     .collection('videos')
    //     .doc(videoId)
    //     .collection('comments')
    //     .orderBy('uploadedAt', descending: false)
    //     .snapshots()
    //     .map((snap) => snap.docs.map((doc) => CommentsModel.fromJson(doc.data(), doc.id)).toList())
    //     .map((allComments) => _buildThreads(allComments, null))
    //     .listen((data) {
    //       threadedComments.assignAll(data);
    //     });

    final snapshot = await FirebaseFirestore.instance
        .collection('videos')
        .doc(videoId)
        .collection('comments')
        .where('isReply', isEqualTo: false)
        .orderBy('uploadedAt', descending: true)
        .get();

    threadedComments.value = snapshot.docs.map((doc) {
      final comment = CommentsModel.fromJson(doc.data(), doc.id);
      return ThreadedComment(comment: comment, replies: []);
    }).toList();

    for (var t in threadedComments) {
      hasMoreReplies[t.comment.commentId] = true;
      isLoadingReplies[t.comment.commentId] = false;
    }
  }

  // List<ThreadedComment> _buildThreads(List<CommentsModel> allComments, String? parentId) {
  //   return allComments
  //       .where((c) => c.parentCommentId == parentId)
  //       .map((c) => ThreadedComment(comment: c, replies: _buildThreads(allComments, c.commentId)))
  //       .toList()
  //     ..sort((a, b) => a.comment.uploadedAt.compareTo(b.comment.uploadedAt));
  // }

  ThreadedComment? _findThread(List<ThreadedComment> list, String id) {
    for (var t in list) {
      if (t.comment.commentId == id) return t;
      final found = _findThread(t.replies, id);
      if (found != null) return found;
    }
    return null;
  }

  String? findParentUserName(String? parentId) {
    if (parentId == null) return null;

    ThreadedComment? parentThread = _findThread(threadedComments, parentId);
    return parentThread?.comment.userName;
  }

  Future<void> fetchReplies(String videoId, String parentId, {int limit = 3}) async {
    if (isLoadingReplies[parentId] == true) return;
    isLoadingReplies[parentId] = true;

    Query query = FirebaseFirestore.instance
        .collection('videos')
        .doc(videoId)
        .collection('comments')
        .where('parentCommentId', isEqualTo: parentId)
        .orderBy('uploadedAt', descending: false)
        .limit(limit);

    if (_lastReplyDoc.containsKey(parentId)) {
      query = query.startAfterDocument(_lastReplyDoc[parentId]!);
    }

    final snapshot = await query.get();
    print("Fetched ${snapshot.docs.length} replies for $parentId");

    if (snapshot.docs.isNotEmpty) {
      final replies = snapshot.docs
          .map((doc) => CommentsModel.fromJson(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      final parentThread = _findThread(threadedComments, parentId);
      if (parentThread != null) {
        parentThread.replies.addAll(
          replies.map((c) {
            // 🔑 Register reply state for nested "View more" support
            hasMoreReplies[c.commentId] = true;
            isLoadingReplies[c.commentId] = false;
            return ThreadedComment(comment: c, replies: []);
          }),
        );
        threadedComments.refresh();
      }

      _lastReplyDoc[parentId] = snapshot.docs.last;
      hasMoreReplies[parentId] = snapshot.docs.length == limit;
    } else {
      hasMoreReplies[parentId] = false;
    }

    isLoadingReplies[parentId] = false;
  }

  void clearFields() {
    commentController.clear();
    isFormFilled.value = false;
  }

  void _checkCommentFormStatus() {
    final text = commentController.text.trim();
    isFormFilled.value = text.isNotEmpty;

    print('Comment Form filled status: ${isFormFilled.value}');
  }

  Future<void> _getProfile() async {
    print("_getProfile() called");
    final userData = await SharedPrefs.getUserFromPrefs();
    if (userData != null) {
      profileUrl?.value = userData.profilePhoto ?? '';
      userName.value = userData.userName;
    }
    print("_getProfile() Loaded profile URL: ${profileUrl?.value}");
    print("_getProfile() Loaded userName in getProfileUrl method: ${userName.value}");
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
    commentController.selection = TextSelection.fromPosition(TextPosition(offset: commentController.text.length));
    commentFocusNode.requestFocus();
  }

  void cancelReply() {
    replyingTo.value = null;
    commentController.clear();
    commentFocusNode.unfocus();
  }

  Future<void> addReply(String videoId, String parentCommentId) async {
    String replyText = commentController.text.trim();

    if (replyText.isEmpty) {
      Utils.snackBar("Error", "Reply cannot be empty.");
      return;
    }

    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) return;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid).get();
    if (!userDoc.exists) {
      Utils.snackBar("Error", "User not found");
      return;
    }

    final userData = userDoc.data()!;
    final userName = userData['userName'] ?? "Unknown";
    final avatarUrl = userData['profilePhoto'] ?? "";

    final reply = CommentsModel(
      commentId: '',
      avatarUrl: avatarUrl,
      userName: userName,
      comment: replyText,
      uploadedAt: DateTime.now(),
      likedBy: [],
      isReply: true,
      parentCommentId: parentCommentId,
    );

    final videoRef = FirebaseFirestore.instance.collection('videos').doc(videoId);

    try {
      final newDoc = await videoRef.collection('comments').add(reply.toJson());
      await newDoc.update({'commentId': newDoc.id});
      await videoRef.update({'commentCount': FieldValue.increment(1)});

      clearFields();
      replyingTo.value = null;
    } catch (e) {
      Utils.snackBar('Error', 'Failed to post reply');
      print("Reply error: $e");
    }
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
