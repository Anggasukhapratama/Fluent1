import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/register_controller.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
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
              onPressed: controller.register,
              child: const Text("Register"),
            ),
            TextButton(
              onPressed: () => Get.back(),
              child: const Text("Sudah punya akun? Login"),
            ),
          ],
        ),
      ),
    );
  }
}
