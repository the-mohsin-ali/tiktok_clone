import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoplayerItem extends StatefulWidget {
  final String videoUrl;
  const VideoplayerItem({super.key, required this.videoUrl});

  @override
  State<VideoplayerItem> createState() => _VideoplayerItemState();
}

class _VideoplayerItemState extends State<VideoplayerItem> {

  late VideoPlayerController _videoPlayerController;

  @override
  void initState(){
    super.initState();
    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
    ..initialize().then((_){
      setState(() {});
      _videoPlayerController.play();
      _videoPlayerController.setLooping(true);
    });
  }

  @override
  void dispose(){
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _videoPlayerController.value.isInitialized
    ? SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _videoPlayerController.value.size.width,
          height: _videoPlayerController.value.size.height,
          child: VideoPlayer(_videoPlayerController),
        ),
      ),
    )
    : Center(child: CircularProgressIndicator(),);
  }
}