import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:fluent/app/modules/aktivitas/controllers/aktivitas_controller.dart';
import 'package:fluent/app/modules/home/controllers/home_controller.dart';

class AktivitasView extends StatelessWidget {
  const AktivitasView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AktivitasController());
    final homeController = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: Colors.grey[700]),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Aktivitas Terakhir',
          style: TextStyle(
            color: Color(0xFFD84040),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          if (controller.activities.isEmpty) {
            return const Center(child: Text('Belum ada riwayat aktivitas'));
          }

          return ListView.builder(
            itemCount: controller.activities.length,
            itemBuilder: (context, index) {
              final activity = controller.activities[index];
              IconData icon = _getIconFromName(activity['icon_name']);
              Color color = _getColorFromHex(activity['color_hex']);

              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: color.withOpacity(0.2), width: 1),
                ),
                color: color.withOpacity(0.05),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color),
                  ),
                  title: Text(activity['name']),
                  subtitle: Text(_formatDate(DateTime.parse(activity['date']))),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  IconData _getIconFromName(String iconName) {
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

  Color _getColorFromHex(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceAll('#', '0xff')));
    } catch (_) {
      return const Color(0xFFD84040);
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final formattedTime =
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    final bulan = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    if (date.isAfter(today)) {
      return 'Hari Ini, $formattedTime';
    } else if (date.isAfter(yesterday)) {
      return 'Kemarin, $formattedTime';
    } else {
      return '${date.day} ${bulan[date.month - 1]}, $formattedTime';
    }
  }
}
