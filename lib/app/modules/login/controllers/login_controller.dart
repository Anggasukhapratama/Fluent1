import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluent/app/data/services/api_service.dart';
import 'package:fluent/app/routes/app_pages.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final isLoading = false.obs;
  final remainingTime = 0.obs;
  final isBlocked = false.obs;
  Timer? _timer;
  final showPassword = false.obs;

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void startTimer(int seconds) {
    isBlocked.value = true;
    remainingTime.value = seconds;

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (remainingTime.value > 0) {
        remainingTime.value--;
      } else {
        isBlocked.value = false;
        timer.cancel();
      }
    });
  }

  void login() async {
    if (isBlocked.value) {
      Get.snackbar(
        "Perhatian",
        "Anda harus menunggu ${remainingTime.value} detik",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar("Perhatian", "Email dan password harus diisi");
      return;
    }

    if (!GetUtils.isEmail(email)) {
      Get.snackbar("Perhatian", "Format email tidak valid");
      return;
    }

    isLoading.value = true;
    final result = await ApiService().login(email, password);
    isLoading.value = false;

    if (result['status'] == 'success') {
      Get.offAllNamed(Routes.HOME);
    } else {
      if (result['blocked'] == true) {
        startTimer(result['remaining_seconds'] ?? 30);
      }

      Get.snackbar(
        "Login Gagal",
        result['message'],
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 3),
      );
    }
  }
}
