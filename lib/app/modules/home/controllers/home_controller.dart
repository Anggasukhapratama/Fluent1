import 'package:get/get.dart';

class HomeController extends GetxController {
  // Tambahkan logika jika dibutuhkan
  final user = ''.obs;

  @override
  void onInit() {
    super.onInit();
    user.value = 'admin'; // Misal nama user dari session/localStorage
  }
}
