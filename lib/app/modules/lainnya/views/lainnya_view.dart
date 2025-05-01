import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/lainnya_controller.dart';

class LainnyaView extends GetView<LainnyaController> {
  const LainnyaView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LainnyaView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'LainnyaView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
