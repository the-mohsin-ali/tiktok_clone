import 'package:tiktok_clone/models/comments_model.dart';

class ThreadedComment {
  final CommentsModel comment;
  final List<ThreadedComment> replies;

  ThreadedComment({
    required this.comment,
    this.replies = const [],
  });
}
