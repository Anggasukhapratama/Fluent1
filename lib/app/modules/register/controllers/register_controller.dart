import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluent/app/data/services/api_service.dart';
import 'package:fluent/app/routes/app_pages.dart';

class RegisterController extends GetxController {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  final ApiService _apiService = ApiService();

  void register() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      Get.snackbar("Error", "Username dan Password wajib diisi");
      return;
    }

    final result = await _apiService.register(username, password);
    if (result['status'] == 'success') {
      Get.snackbar("Berhasil", "Registrasi berhasil");
      Get.offAllNamed(Routes.LOGIN);
    } else {
      Get.snackbar("Registrasi Gagal", result['message']);
    }
  }
}
