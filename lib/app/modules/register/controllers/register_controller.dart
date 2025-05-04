import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/api_service.dart';

class RegisterController extends GetxController {
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final occupationController = TextEditingController();

  final selectedGender = 'Laki-laki'.obs;
  final showPassword = false.obs;
  final isLoading = false.obs;

  final ApiService _apiService = ApiService();

  Future<void> register() async {
    final email = emailController.text.trim();
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();
    final gender = selectedGender.value;
    final occupation = occupationController.text.trim();

    if (email.isEmpty ||
        username.isEmpty ||
        password.isEmpty ||
        occupation.isEmpty) {
      Get.snackbar(
        "Perhatian",
        "Semua field wajib diisi",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (!GetUtils.isEmail(email)) {
      Get.snackbar(
        "Perhatian",
        "Format email tidak valid",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (password.length < 8) {
      Get.snackbar(
        "Perhatian",
        "Password minimal 8 karakter",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    try {
      final result = await _apiService.register(
        email,
        username,
        password,
        gender,
        occupation,
      );

      Get.snackbar(
        result['status'] == 'success' ? "Sukses" : "Gagal",
        result['message'],
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor:
            result['status'] == 'success' ? Colors.green : Colors.red,
        colorText: Colors.white,
      );

      if (result['status'] == 'success') {
        await Future.delayed(const Duration(seconds: 2));
        Get.offAllNamed('/login');
      }
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    occupationController.dispose();
    super.onClose();
  }
}
