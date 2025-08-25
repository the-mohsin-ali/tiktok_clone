import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tiktok_clone/view/feed/home_controller.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [IconButton(onPressed: (){ 
          controller.logout();
        }, icon: Icon(Icons.logout))],
      ),
      body: Center(child: Text('Home Screen')));
  }
}
