import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/api_service.dart';

class RegisterController extends GetxController {
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final occupationController = TextEditingController();

  // Mendeklarasikan selectedGender sebagai RxString
  var selectedGender = 'Laki-laki'.obs; // Pilihan default

  final ApiService _apiService = ApiService();

  Future<void> register() async {
    final email = emailController.text.trim();
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();
    final gender = selectedGender.value; // Ambil nilai yang dipilih
    final occupation = occupationController.text.trim();

    if (email.isEmpty ||
        username.isEmpty ||
        password.isEmpty ||
        gender.isEmpty ||
        occupation.isEmpty) {
      Get.snackbar("Error", "Semua field wajib diisi");
      return;
    }

    final result = await _apiService.register(
      email,
      username,
      password,
      gender,
      occupation,
    );

    Get.snackbar(result['status'], result['message']);
    if (result['status'] == 'success') {
      Get.toNamed('/login');
    }
  }
}
