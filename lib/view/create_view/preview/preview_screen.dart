import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tiktok_clone/constants/utils/utils.dart';
import 'package:tiktok_clone/view/bottom_nav.dart/bottom_nav_controller.dart';
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
  PreviewScreenController controller = Get.put(PreviewScreenController());
  BottomNavController navController = Get.put(BottomNavController());

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false, title: const Text('Preview')),
      body: SafeArea(
        child: Center(
          child: _videoController.value.isInitialized
              ? Stack(
                  children: [
                    AspectRatio(aspectRatio: _videoController.value.aspectRatio, child: VideoPlayer(_videoController)),
                    Positioned(
                      bottom: 20.h,
                      left: 20.w,
                      child: FloatingActionButton(
                        heroTag: 'dismiss',
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Icon(Icons.close),
                      ),
                    ),
                    Obx(
                      () => controller.isUploading.value
                          ? Positioned.fill(
                              child: Container(
                                color: Colors.black45,
                                child: const Center(child: CircularProgressIndicator()),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),

                    Positioned(
                      bottom: 20.h,
                      right: 20.w,
                      child: FloatingActionButton(
                        onPressed: () async {
                          bool success = await controller.uploadAndSave(widget.videoPath);
                          if (success) {
                            if (mounted && _videoController.value.isInitialized) {
                              _videoController.pause();
                              _videoController.dispose();
                            }
                            navigator?.pop();
                            navController.changeTabIndex(1);
                          } else {
                            Utils.snackBar('Error', 'error uploading and saving video');
                          }
                        },
                        heroTag: 'confirm',
                        child: Icon(Icons.check),
                      ),
                    ),
                  ],
                )
              : Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}
