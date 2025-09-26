import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tiktok_clone/constants/color/app_color.dart';
import 'package:tiktok_clone/view/create_view/preview/preview_screen_controller.dart';
import 'package:video_player/video_player.dart';

class PreviewVideoScreen extends StatefulWidget {
  final String videoPath;
  const PreviewVideoScreen({super.key, required this.videoPath});

  @override
  State<PreviewVideoScreen> createState() => _PreviewVideoScreenState();
}

class _PreviewVideoScreenState extends State<PreviewVideoScreen> {
  late VideoPlayerController _videoController;
  final PreviewScreenController controller = Get.put(PreviewScreenController());

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _keywordsController = TextEditingController();

  final FocusNode _titleFocus = FocusNode();
  final FocusNode _keywordsFocus = FocusNode();

  RxString expandedField = "".obs; // "title" | "keywords" | ""

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        setState(() {});
        _videoController.play();
        _videoController.setLooping(true);
      });
  }

  @override
  void dispose() {
    _videoController.dispose();
    _titleController.dispose();
    _keywordsController.dispose();
    _titleFocus.dispose();
    _keywordsFocus.dispose();
    super.dispose();
  }

  Widget buildExpandableButton({
    required String label,
    required String fieldKey,
    required TextEditingController controller,  
    required FocusNode focusNode,
  }) {
    return Obx(() {
      final isExpanded = expandedField.value == fieldKey;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: isExpanded ? 220.w : 48.w,
            height: 48.h,
            margin: EdgeInsets.symmetric(vertical: 8.h),
            decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(30)),
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (isExpanded) {
                      // collapse
                      expandedField.value = "";
                      focusNode.unfocus();
                    } else {
                      // open this, close others
                      expandedField.value = fieldKey;
                      focusNode.requestFocus();
                    }
                  },
                  child: const Icon(Icons.edit, color: Colors.white),
                ),
                if (isExpanded) ...[
                  SizedBox(width: 8.w),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      autofocus: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: label,
                        border: InputBorder.none,
                        hintStyle: const TextStyle(color: Colors.white54),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // ↓ static text below input
          if (controller.text.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 4.h, right: 8.w),
              child: Text(
                controller.text,
                style: TextStyle(color: Colors.white70, fontSize: 12.sp),
              ),
            ),
        ],
      );
    });
  }

  void _collapseInputs() {
    expandedField.value = "";
    _titleFocus.unfocus();
    _keywordsFocus.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _collapseInputs, // outside tap
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Video
            _videoController.value.isInitialized
                ? Center(
                    child: AspectRatio(
                      aspectRatio: _videoController.value.aspectRatio,
                      child: VideoPlayer(_videoController),
                    ),
                  )
                : const Center(child: CircularProgressIndicator()),

            // Expandable inputs on right side
            Positioned(
              right: 16.w,
              top: 150.h,
              child: Column(
                children: [
                  buildExpandableButton(
                    label: "Add title",
                    fieldKey: "title",
                    controller: _titleController,
                    focusNode: _titleFocus,
                  ),
                  const Text(
                    "Title",
                    style: TextStyle(
                      fontFamily: 'TikTokSansExpanded',
                      fontWeight: FontWeight.w400,
                      color: AppColor.secondaryColor,
                    ),
                  ),
                  buildExpandableButton(
                    label: "Add keywords",
                    fieldKey: "keywords",
                    controller: _keywordsController,
                    focusNode: _keywordsFocus,
                  ),
                  const Text(
                    "Keywords",
                    style: TextStyle(
                      fontFamily: 'TikTokSansExpanded',
                      fontWeight: FontWeight.w400,
                      color: AppColor.secondaryColor,
                    ),
                  ),
                ],
              ),
            ),

            // confirm / close FABs
            Positioned(
              bottom: 20.h,
              left: 20.w,
              child: FloatingActionButton(
                heroTag: 'dismiss',
                onPressed: () => Navigator.pop(context),
                child: const Icon(Icons.close),
              ),
            ),
            Positioned(
              bottom: 20.h,
              right: 20.w,
              child: FloatingActionButton(
                heroTag: 'confirm',
                onPressed: () async {
                  bool success = await controller.uploadAndSave(
                    filePath: widget.videoPath,
                    title: _titleController.text.trim().isEmpty ? null : _titleController.text.trim(),
                    keywords: _keywordsController.text.trim().isEmpty
                        ? <String>[]
                        : _keywordsController.text.split(',').map((e) => e.trim()).toList(),
                  );
                  if (success) {
                    _videoController.pause();
                    Navigator.pop(context);
                  }
                },
                child: const Icon(Icons.check),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
