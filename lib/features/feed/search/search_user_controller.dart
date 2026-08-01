import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tiktok_clone/models/user_model.dart';

class SearchUserController extends GetxController {
  TextEditingController textEditingController = TextEditingController();
  RxList<UserModel> searchResults = <UserModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit(){
    super.onInit();
    textEditingController.addListener(_onSearchChanged);
  }

  void _onSearchChanged(){
    final query = textEditingController.text.trim();
    if (query.isNotEmpty) {
      searchUser(query);
    }else{
      searchResults.clear();
    }
  }

  void searchUser(String query) async {

    isLoading.value = true;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('userName', isGreaterThanOrEqualTo: query)
        .where('userName', isLessThan: query + '\uf8ff')
        .get();

    final results = snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
    searchResults.assignAll(results);

    isLoading.value = false;
  }

  void clearFields(){
    textEditingController.clear();
    searchResults.clear();
  }


}
