import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HomeController extends GetxController {
  final user = ''.obs;
  final consecutiveDays = 0.obs;
  final lastActivities = <Map<String, dynamic>>[].obs;
  final hasShownWelcomeMessage = false.obs; // ← Tambahkan baris ini

  @override
  void onInit() async {
    super.onInit();
    await loadUserData();
    await loadConsecutiveDays();
    await loadLastActivities();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    user.value = prefs.getString('username') ?? 'User';
  }

  Future<void> loadConsecutiveDays() async {
    final prefs = await SharedPreferences.getInstance();
    final lastLoginStr = prefs.getString('last_login');
    final today = DateTime.now();

    if (prefs.getBool('logged_in_today') ?? false) {
      consecutiveDays.value = prefs.getInt('consecutive_days') ?? 0;
      return;
    }

    if (lastLoginStr == null) {
      // Jika belum ada data login sebelumnya
      consecutiveDays.value = 1;
      await prefs.setBool('logged_in_today', true);
      await prefs.setString('last_login', today.toString());
      await prefs.setInt('consecutive_days', 1);
      return;
    }

    final lastLogin = DateTime.parse(lastLoginStr);

    final difference = today.difference(lastLogin).inDays;

    if (difference == 1) {
      consecutiveDays.value = (prefs.getInt('consecutive_days') ?? 0) + 1;
    } else {
      consecutiveDays.value = 1;
    }

    await prefs.setBool('logged_in_today', true);
    await prefs.setString('last_login', today.toString());
    await prefs.setInt('consecutive_days', consecutiveDays.value);
  }

  Future<void> addActivity(String activityName) async {
    final newActivity = {
      'name': activityName,
      'date': DateTime.now().toIso8601String(),
      'icon_name': _getIconName(activityName),
      'color_hex': _getColorHex(activityName),
    };

    lastActivities.insert(0, newActivity); // Simpan nama icon & warna hex

    final prefs = await SharedPreferences.getInstance();
    final limitedActivities = lastActivities.take(5).toList();

    // Simpan aktivitas sebagai list string JSON
    await prefs.setStringList(
      'last_activities',
      limitedActivities.map((act) => jsonEncode(act)).toList(),
    );
  }

  Future<void> loadLastActivities() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? savedActivities = prefs.getStringList(
      'last_activities',
    );

    if (savedActivities == null || savedActivities.isEmpty) {
      lastActivities.clear(); // Tidak ada data lama
      return;
    }

    final List<Map<String, dynamic>> activities = [];

    for (var jsonStr in savedActivities) {
      try {
        final Map<String, dynamic> item = jsonDecode(jsonStr);

        String iconName = item['icon_name'] ?? 'activity';
        String hexColor = item['color_hex'] ?? '#D84040';

        activities.add({
          'name': item['name'],
          'date': item['date'],
          'icon_name': iconName,
          'color_hex': hexColor,
        });
      } catch (e) {
        // Lewati jika parsing gagal
        print("Gagal decode aktivitas: $e");
        continue;
      }
    }

    lastActivities.assignAll(activities);
  }

  String _getIconName(String activityName) {
    switch (activityName) {
      case 'Route Detection':
        return 'router';
      case 'Public Speaking':
        return 'mic2';
      case 'Ekspresi':
        return 'smile';
      default:
        return 'activity';
    }
  }

  IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'router':
        return LucideIcons.router;
      case 'mic2':
        return LucideIcons.mic2;
      case 'smile':
        return LucideIcons.smile;
      default:
        return LucideIcons.activity;
    }
  }

  Color _getColor(String activityName) {
    switch (activityName) {
      case 'Route Detection':
        return Colors.blue;
      case 'Public Speaking':
        return Colors.green;
      case 'Ekspresi':
        return Colors.orange;
      default:
        return const Color(0xFFD84040);
    }
  }

  String _getColorHex(String activityName) {
    return _getColor(activityName).value.toRadixString(16).padLeft(8, '0');
  }
}
