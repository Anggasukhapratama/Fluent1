import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluent/app/data/services/api_service.dart';
import 'package:fluent/app/routes/app_pages.dart';

class LoginController extends GetxController {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  final ApiService _apiService = ApiService();

  void login() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      Get.snackbar("Error", "Username dan Password wajib diisi");
      return;
    }

    final result = await _apiService.login(username, password);
    if (result['status'] == 'success') {
      Get.offAllNamed(Routes.HOME);
    } else {
      Get.snackbar("Login Gagal", result['message']);
    }
  }
}
