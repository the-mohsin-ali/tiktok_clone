import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tiktok_clone/constants/utils/utils.dart';
import 'package:tiktok_clone/models/user_model.dart';

class AuthController extends GetxController {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController usernameController = TextEditingController();

  var isLoading = false.obs;
  final isFormFilled = false.obs;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final Rx<ImageProvider> pickedImage = Rx<ImageProvider>(
    AssetImage('images/default_profile.jpg'),
  );
  final Rx<File?> profileImageFile = Rx<File?>(null);

  @override
  void onInit() {
    super.onInit();
    emailController.addListener(_checkFormStatus);
    passwordController.addListener(_checkFormStatus);
    usernameController.addListener(_checkFormStatus);
  }

  void _checkFormStatus() {
    final filled =
        emailController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        usernameController.text.isNotEmpty;
    isFormFilled.value = filled;
    print('Form filled status: $filled');
  }

  Future<void> pickProfileImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final file = File(picked.path);
      pickedImage.value = FileImage(file);
      profileImageFile.value = file;
      print('Image picked: ${file.path}');
    } else {
      print('No image selected.');
    }
  }

  Future<String> uploadProfileImage(File file, String uid) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('profile_images')
        .child('$uid.jpg');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<void> signUp() async {
    isLoading.value = true;

    try {
      if (formKey.currentState!.validate()) {
        String email = emailController.text.trim();
        String password = passwordController.text.trim();
        String userName = usernameController.text.trim();

        UserCredential userCredential = await auth
            .createUserWithEmailAndPassword(email: email, password: password);

        if (userCredential.user != null) {
          final uid = userCredential.user!.uid;
          print('User registered successfully: $uid');
          String? imageUrl;
          if(profileImageFile.value != null){
            imageUrl = await uploadProfileImage(
            profileImageFile.value!,
            uid,
          );
          }
          
          UserModel userModel = UserModel(
            uid: userCredential.user!.uid,
            email: email,
            userName: userName,
            profilePhoto: imageUrl,
          );
          
          await FirebaseFirestore.instance
                .collection('users')
                .doc(uid)
                .set(userModel.toMap());
            Utils.snackBar('Success', 'Account created successfully');
            Get.offAllNamed('/login');
        }
      } else {
        Utils.snackBar('Error', 'Form is not valid');
        print('Form is not valid');
      }
    } catch (e) {
      Utils.snackBar('Error', 'Failed to sign up: $e');
      print('Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    usernameController.dispose();
    super.onClose();
  }
}
