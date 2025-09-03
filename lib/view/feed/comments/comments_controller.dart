import 'package:get/get.dart';
import 'package:tiktok_clone/services/shared_prefs.dart';

class CommentsController extends GetxController{
  RxString profileUrl = ''.obs;

  @override
  void onInit(){
    super.onInit();
    getProfileUrl();
  }

  Future<void> getProfileUrl() async {
    final url = await SharedPrefs.getProfileUrl() ?? '';
    profileUrl.value = url ;
    print("Loaded profile URL in getProfileurl method: ${profileUrl.value}");
  }

}