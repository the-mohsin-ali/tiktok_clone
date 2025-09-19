import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

class FullscreenVideoViewer extends StatefulWidget {
  final String videoUrl;

  const FullscreenVideoViewer({Key? key, required this.videoUrl}) : super(key: key);

  @override
  State<FullscreenVideoViewer> createState() => _FullscreenVideoViewerState();
}

class _FullscreenVideoViewerState extends State<FullscreenVideoViewer> {
  late VideoPlayerController _controller;
  bool _isControlsVisible = true;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleControls() {
    setState(() {
      _isControlsVisible = !_isControlsVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: GestureDetector(
          onTap: _toggleControls,
          child: Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (_controller.value.isInitialized)
                  Center(
                    child: AspectRatio(aspectRatio: _controller.value.aspectRatio, child: VideoPlayer(_controller)),
                  )
                else
                  Center(child: CircularProgressIndicator(color: Colors.white)),

                // if (_isControlsVisible)
                //   Positioned(
                //     top: 40,
                //     left: 16,
                //     child: IconButton(
                //       icon: Icon(Icons.arrow_back, color: Colors.white),
                //       onPressed: () => Navigator.of(context).pop(),
                //     ),
                //   ),
                if (_isControlsVisible)
                  Positioned(
                    bottom: 40,
                    child: IconButton(
                      icon: Icon(
                        _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 36.h,
                      ),
                      onPressed: () {
                        setState(() {
                          _controller.value.isPlaying ? _controller.pause() : _controller.play();
                        });
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
