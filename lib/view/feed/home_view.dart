import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tiktok_clone/view/feed/home_controller.dart';
import 'package:tiktok_clone/view/feed/videoPlayer_item.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    
    return Obx((){
      final videos = controller.videos;
      if(videos.isEmpty){

      }
      return Theme(
        data: ThemeData.dark(),
        child: Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                onPressed: () {
                  controller.logout();
                },
                icon: Icon(Icons.logout),
              ),
            ],
          ),
          body: videos.isEmpty
          ? Center(child: CircularProgressIndicator(),)
          : PageView.builder(
            scrollDirection: Axis.vertical,
            itemCount: videos.length,
            itemBuilder: (context, index){
              final video = videos[index];

              return Stack(
                children: [
                  VideoplayerItem(videoUrl: video.videoUrl,)
                  
                ],
              );
            } 
          ),
        ),
      );
    }
    );
  }
}
