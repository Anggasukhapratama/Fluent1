import 'package:get/get.dart';

class IntroController extends GetxController {
  var currentPage = 0.obs;

  void setPage(int index) {
    currentPage.value = index;
  }
}
