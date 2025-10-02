import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tiktok_clone/constants/color/app_color.dart';
import 'package:tiktok_clone/models/threaded_comments.dart';
import 'package:tiktok_clone/models/video_model.dart';
import 'package:tiktok_clone/view/feed/comments/comment_item.dart';
import 'package:tiktok_clone/view/feed/comments/comments_controller.dart';

class CommentsBottomsheet extends StatefulWidget {
  final VideoModel video;
  final ScrollController? scrollController;

  const CommentsBottomsheet({super.key, required this.video, this.scrollController});

  @override
  State<CommentsBottomsheet> createState() => _CommentsBottomsheetState();
}

class _CommentsBottomsheetState extends State<CommentsBottomsheet> {
  late final CommentsController controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    controller = Get.find();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.initComments(widget.video.videoId);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _focusNode.unfocus(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxHeight = constraints.maxHeight;

          return Column(
            children: [
              // --- Drag Handle ---
              Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.symmetric(vertical: 8.h),
                decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(2)),
              ),

              // --- Comment Count ---
              Obx(() {
                final count = controller.threadedComments.length;
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.h),
                  child: Text(
                    '$count comments',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
                  ),
                );
              }),

              // --- Scrollable Comments Tree ---
              Expanded(
                // height: maxHeight - 140.h,
                child: Obx(() {
                  final threads = controller.threadedComments;
                  if (threads.isEmpty) {
                    return const Center(child: Text("No comments yet."));
                  }

                  return ListView.builder(
                    controller: widget.scrollController,
                    physics: const BouncingScrollPhysics(),
                    itemCount: threads.length,
                    itemBuilder: (context, index) {
                      return buildComment(threads[index], widget.video.videoId, depth: 0);
                    },
                  );
                }),
              ),

              // --- Reply Indicator ---
              ReplyWidget(controller: controller),

              // --- Bottom Text Field ---
              BottomTextField(controller: controller, videoId: widget.video.videoId, focusNode: _focusNode),
            ],
          );
        },
      ),
    );
  }

  /// Recursively build comment + its replies
  Widget buildComment(ThreadedComment thread, String videoId, {int depth = 0}) {
    final comment = thread.comment;

    const double indentPerLevel = 40.0;
    // visual clamp: depth 0 => 0, depth >=1 => one indent only
    final double leftForThis = depth >= 1 ? indentPerLevel : 0.0;
    // the replies and "view more" will all use replyIndent (same visual indent)
    final double replyIndent = indentPerLevel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- the comment row itself — absolute margin based on depth ---
        Container(
          margin: EdgeInsets.only(left: leftForThis, top: depth == 0 ? 8 : 4, bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (depth >= 2) ...[
                Builder(
                  builder: (_) {
                    final parentUserName = controller.findParentUserName(comment.parentCommentId);
                    if (parentUserName == null) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 40),
                      child: Text.rich(
                        TextSpan(
                          style: TextStyle(fontSize: 12.sp, color: Colors.grey), // Style for the non-bold text
                          children: <TextSpan>[
                            const TextSpan(text: 'in reply to '),
                            TextSpan(
                              text: parentUserName,
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade100),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(width: 8),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: CommentItem(
                        model: comment,
                        videoId: videoId,
                        onReply: () => controller.startReplyTo(comment),
                        onLike: () => controller.likeComment(videoId, comment.commentId),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // --- render children recursively (no extra wrapper padding) ---
        for (var replyThread in thread.replies) buildComment(replyThread, videoId, depth: depth + 1),

        // --- View More Replies button (aligned with replies) ---
        Obx(() {
          final hasMore = controller.hasMoreReplies[comment.commentId] ?? false;
          final loading = controller.isLoadingReplies[comment.commentId] ?? false;
          if (!hasMore) return const SizedBox.shrink();

          return Container(
            margin: EdgeInsets.only(left: replyIndent, bottom: 8),
            child: TextButton(
              onPressed: loading ? null : () => controller.fetchReplies(videoId, comment.commentId),
              child: loading
                  ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text("View more replies"),
            ),
          );
        }),
      ],
    );
  }
}

// Bottom text field remains same as before
class BottomTextField extends StatelessWidget {
  const BottomTextField({super.key, required this.controller, required this.videoId, required this.focusNode});

  final CommentsController controller;
  final String videoId;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
          child: Row(
            children: [
              Obx(() {
                final avatarUrl = controller.profileUrl?.value ?? '';
                return SizedBox(
                  width: 32.w,
                  height: 32.w,
                  child: CircleAvatar(
                    backgroundColor: AppColor.secondaryColor,
                    backgroundImage: avatarUrl.isNotEmpty
                        ? NetworkImage(avatarUrl)
                        : const AssetImage('assets/images/default_profile.jpg') as ImageProvider,
                  ),
                );
              }),
              SizedBox(width: 8.w),
              Expanded(
                child: TextField(
                  controller: controller.commentController,
                  focusNode: focusNode,
                  textInputAction: TextInputAction.send,
                  maxLines: null,
                  minLines: 1,
                  onSubmitted: (_) => _handleSubmit(),
                  decoration: InputDecoration(
                    hintText: 'Add Comment...',
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[200],
                    contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Obx(() {
                final isActive = controller.isFormFilled.value;
                return InkWell(
                  onTap: isActive ? _handleSubmit : null,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: EdgeInsets.all(4.w),
                    child: Image.asset(
                      'assets/icons/send_icon.png',
                      height: 25.h,
                      width: 25.w,
                      color: isActive ? AppColor.buttonActiveColor : AppColor.buttonInactiveColor,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSubmit() {
    final replyingTo = controller.replyingTo.value;
    if (replyingTo != null) {
      controller.addReply(videoId, replyingTo.commentId);
    } else {
      controller.addComment(videoId);
    }
    controller.cancelReply();
    focusNode.unfocus();
  }
}

// ReplyWidget remains the same
class ReplyWidget extends StatelessWidget {
  const ReplyWidget({super.key, required this.controller});

  final CommentsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final replyTo = controller.replyingTo.value;
      if (replyTo == null) return const SizedBox.shrink();

      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        margin: EdgeInsets.only(bottom: 8.h),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.grey.withAlpha(50)),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Replying to @${replyTo.userName}',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontStyle: FontStyle.italic,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColor.secondaryColor
                      : AppColor.primaryColor,
                ),
              ),
            ),
            GestureDetector(
              onTap: controller.cancelReply,
              child: Icon(Icons.close, size: 16.sp, color: Colors.grey),
            ),
          ],
        ),
      );
    });
  }
}
