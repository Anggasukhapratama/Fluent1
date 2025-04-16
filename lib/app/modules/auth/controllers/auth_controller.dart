import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/api_service.dart';
import '../../home/views/home_view.dart';

class AuthController extends GetxController {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final api = ApiService();

  Future<void> register() async {
    final res = await api.register(
      usernameController.text,
      passwordController.text,
    );
    Get.snackbar(res['status'], res['message']);
    if (res['status'] == 'success') {
      Get.toNamed('/login');
    }
  }

  Future<void> login() async {
    final res = await api.login(
      usernameController.text,
      passwordController.text,
    );
    Get.snackbar(res['status'], res['message']);
    if (res['status'] == 'success') {
      Get.offAllNamed('/home');
    }
  }
}
