import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:tiktok_clone/constants/routes/routes_names.dart';
import 'package:tiktok_clone/constants/utils/utils.dart';
import 'package:tiktok_clone/models/user_model.dart';
import 'package:tiktok_clone/services/shared_prefs.dart';

class AuthController extends GetxController {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController usernameController = TextEditingController();

  var isLoading = false.obs;
  final isFormFilled = false.obs;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final Rx<ImageProvider> pickedImage = Rx<ImageProvider>(AssetImage('images/default_profile.jpg'));
  final Rx<File?> profileImageFile = Rx<File?>(null);

  @override
  void onInit() {
    super.onInit();
    print('mohsin');
    emailController.addListener(_checkSignupFormStatus);
    passwordController.addListener(_checkSignupFormStatus);
    usernameController.addListener(_checkSignupFormStatus);
    emailController.addListener(_checkLoginFormStatus);
    passwordController.addListener(_checkLoginFormStatus);
  }

  void clearFields() {
    emailController.clear();
    passwordController.clear();
    usernameController.clear();
    pickedImage.value = AssetImage('images/default_profile.jpg');
    profileImageFile.value = null;
    isFormFilled.value = false;
    print('Fields cleared');
  }

  void _checkSignupFormStatus() {
    final filled =
        emailController.text.isNotEmpty && passwordController.text.isNotEmpty && usernameController.text.isNotEmpty;
    isFormFilled.value = filled;
    print('Signup Form filled status: $filled');
  }

  void _checkLoginFormStatus() {
    final filled = emailController.text.isNotEmpty && passwordController.text.isNotEmpty;
    isFormFilled.value = filled;
    print('Signup Form filled status: $filled');
  }

  Future<void> pickProfileImage() async {
    try {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (picked != null) {
        final file = File(picked.path);
        pickedImage.value = FileImage(file);
        profileImageFile.value = file;
        print('Image picked: ${file.path}');
      } else {
        print('No image selected.');
      }
    } catch (e) {
      Utils.snackBar('Error', 'Failed to pick image: $e');
      print('Error picking image: $e');
    }
  }

  Future<String> uploadProfileImage(File file, String uid) async {
    try {
      if (!await file.exists()) {
        throw Exception('Selected image file does not exist.');
      }

      const cloudName = 'dihv9cnmf';
      const presetName = 'prof_picture';

      final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/upload');
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = presetName
        ..files.add(await http.MultipartFile.fromPath('file', file.path));
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonMap = jsonDecode(responseData);
        final imageUrl = jsonMap['secure_url'];
        print('✅ Uploaded to Cloudinary: $imageUrl');
        return imageUrl;
      } else {
        final errorData = await response.stream.bytesToString();
        print('failed to upload image status code ${response.statusCode}');
        print('Error response: $errorData');
        throw Exception('Failed to upload image');
      }
    } catch (e) {
      print("Upload failed: $e");
      rethrow;
    }
  }

  Future<void> signUp() async {
    isLoading.value = true;

    try {
      // if (formKey.currentState!.validate()) {
      String email = emailController.text.trim();
      String password = passwordController.text.trim();
      String userName = usernameController.text.trim();

      UserCredential userCredential = await auth.createUserWithEmailAndPassword(email: email, password: password);

      // print("user id generated: ${userCredential.user?.uid}");

      if (userCredential.user != null) {
        final uid = userCredential.user!.uid;
        print('User registered successfully: $uid');
        String? imageUrl;
        print("printing the value for profileImageFile.value: ${profileImageFile.value}");
        if (profileImageFile.value != null) {
          try {
            imageUrl = await uploadProfileImage(profileImageFile.value!, uid);
          } catch (e) {
            Utils.snackBar('Error', 'Image upload failed: $e');
            print('Image upload error: $e');
            return;
          }
          // print("value in imageUrl is: $imageUrl");
        }

        UserModel userModel = UserModel(
          uid: userCredential.user!.uid,
          email: email,
          userName: userName,
          profilePhoto: imageUrl,
          followers: [],
          following: [],
          likes: 0,
        );

        await FirebaseFirestore.instance.collection('users').doc(uid).set(userModel.toMap());
        Utils.snackBar('Success', 'Account created successfully');
        clearFields();
        Get.offAllNamed('/login');
      }
      // } else {
      //   Utils.snackBar('Error', 'Form is not valid');
      //   print('Form is not valid');
      // }
    } catch (e) {
      Utils.snackBar('Error', 'Failed to sign up: $e');
      print('Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> login() async {
    isLoading.value = true;
    try {
      String email = emailController.text.trim();
      String password = passwordController.text.trim();
      UserCredential userCredential = await auth.signInWithEmailAndPassword(email: email, password: password);

      await saveDeviceToken();

      User? user = userCredential.user;
      print("user data at login : $user");
      if (user != null) {
        String uid = user.uid;

        DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();
        if (userDoc.exists) {
          print('value in userDoc: ${userDoc.data()}');

          UserModel user = UserModel.fromMap(userDoc.data()!);

          await SharedPrefs.saveUserData(user);

          final userData = await SharedPrefs.getUserFromPrefs();

          print('''User Data saved in login: 
            User ID: ${await SharedPrefs.getUserId()}
            Email: ${userData?.email}
            User Name: ${userData?.userName}
            User photo url: ${userData?.profilePhoto}
            User isLoggedIn: ${await SharedPrefs.getIsLoggedIn()}''');
        } else {
          print('User document does not exist');
          return;
        }
      }
      Get.offAllNamed(RoutesNames.home);
    } catch (e) {
      Utils.snackBar('Error', 'Failed to login');
      print('Login failed: $e');
      print('clearing shared preference data since login failed');
      await SharedPrefs.clearUserData();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveDeviceToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({'fcmToken': token});
    }

    // Listen for token refresh and update on change
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({'fcmToken': newToken});
    });
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;
      await auth.signOut();
      await SharedPrefs.clearUserData();
      Get.offAllNamed(RoutesNames.login);
    } catch (e) {
      print('Error: $e');
      Utils.snackBar('Error', 'Failed to logout: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future get isLoggedIn async => SharedPrefs.getIsLoggedIn();

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    usernameController.dispose();
    super.onClose();
  }
}
