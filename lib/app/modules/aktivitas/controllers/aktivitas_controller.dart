import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AktivitasController extends GetxController {
  final List<Map<String, dynamic>> activities = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadLastActivities();
  }

  Future<void> loadLastActivities() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedActivities = prefs
        .getStringList('last_activities')
        ?.join(',');

    if (savedActivities == null || savedActivities.isEmpty) return;

    try {
      final decoded = jsonDecode('[${savedActivities}]') as List;

      List<Map<String, dynamic>> activityList =
          decoded.map((item) {
            item = item as Map<String, dynamic>;
            return {
              'name': item['name'] ?? 'Aktivitas',
              'date': item['date'] ?? DateTime.now().toIso8601String(),
              'icon_name': item['icon_name'] ?? 'activity',
              'color_hex': item['color_hex'] ?? '#D84040',
            };
          }).toList();

      activities.clear();
      activities.addAll(activityList);
    } catch (e) {
      print("Gagal memuat riwayat aktivitas: $e");
    }
  }
}
