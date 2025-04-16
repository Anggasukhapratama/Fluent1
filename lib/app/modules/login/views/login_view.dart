import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: controller.usernameController,
              decoration: const InputDecoration(labelText: "Username"),
            ),
            TextField(
              controller: controller.passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: controller.login,
              child: const Text("Login"),
            ),
            TextButton(
              onPressed: () => Get.toNamed('/register'),
              child: const Text("Belum punya akun? Register"),
            ),
          ],
        ),
      ),
    );
  }
}
