import 'package:get/get.dart';

class SplashController extends GetxController {
  void goToIntro() {
    Future.delayed(const Duration(seconds: 1), () {
      Get.offAllNamed('/intro');
    });
  }
}
