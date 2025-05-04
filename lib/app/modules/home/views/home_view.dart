import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:fluent/app/modules/home/controllers/home_controller.dart';
import 'package:fluent/app/routes/app_pages.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());

    // Tampilkan pop up hanya sekali saat halaman dimuat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!controller.hasShownWelcomeMessage.value) {
        Get.defaultDialog(
          title: "Selamat Datang!",
          middleText:
              "Siap latihan hari ini? Mari kita tingkatkan kemampuan bicaramu.",
          textConfirm: "OK",
          onConfirm: Get.back,
          confirmTextColor: Colors.white,
          buttonColor: const Color(0xFFD84040),
        );

        controller.hasShownWelcomeMessage.value = true;
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '🤖 FLUENT',
          style: TextStyle(
            color: Color(0xFFD84040),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(LucideIcons.bell, color: Colors.grey[700]),
            onPressed:
                () =>
                    Get.snackbar('Notifikasi', 'Fitur notifikasi akan datang!'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGreetingSection(controller),
            const SizedBox(height: 24),
            _buildStatsSection(controller),
            const SizedBox(height: 24),
            _buildSectionHeader('Mulai Latihan Cepat'),
            const SizedBox(height: 12),
            _buildQuickActionsGrid(controller),
            const SizedBox(height: 24),
            _buildSectionHeader('Aktivitas Terakhir'),
            const SizedBox(height: 12),
            _buildLatestActivities(controller),
            const SizedBox(height: 24),
            _buildSectionHeader('Rekomendasi Untukmu'),
            const SizedBox(height: 12),
            _buildPracticeRecommendations(),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Get.toNamed(Routes.AKTIVITAS);
          }
          if (index == 2) {
            Get.toNamed(Routes.PROGRES);
          }
          if (index == 3) {
            Get.toNamed(Routes.PROFILE);
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFD84040),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(LucideIcons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.mic2),
            label: 'Aktivitas',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.trendingUp),
            label: 'Progres',
          ),
          BottomNavigationBarItem(icon: Icon(LucideIcons.user), label: 'Akun'),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildGreetingSection(HomeController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(
          () => Text(
            'Hi, ${controller.user.value}! 👋',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Siap latihan hari ini?',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildStatsSection(HomeController controller) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFD84040), width: 1),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem(
                  icon: LucideIcons.award,
                  value: '76.5',
                  label: 'Rata-rata',
                  color: Colors.amber,
                ),
                _buildStatItemWithObx(
                  controller: controller,
                  icon: LucideIcons.flame,
                  label: 'Hari Berturut',
                  color: const Color(0xFFD84040),
                ),
                _buildStatItem(
                  icon: LucideIcons.star,
                  value: '15',
                  label: 'Token',
                  color: Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: 0.765,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFD84040),
              ),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text('Perkembangan Kamu'), Text('76.5/100')],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildStatItemWithObx({
    required HomeController controller,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Obx(
          () => Text(
            '${controller.consecutiveDays.value}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildQuickActionsGrid(HomeController controller) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: [
        _buildQuickActionCard(
          controller: controller,
          activityName: 'Narasi',
          icon: LucideIcons.bookOpen,
          title: 'Narasi',
          color: Colors.purple,
          onTap: () => Get.toNamed(Routes.DETECTION),
        ),
        _buildQuickActionCard(
          controller: controller,
          activityName: 'Wawancara',
          icon: LucideIcons.users,
          title: 'Wawancara',
          color: Colors.green,
          onTap: () => Get.toNamed(Routes.HRD_SIMULATION),
        ),
        _buildQuickActionCard(
          controller: controller,
          activityName: 'Ekspresi',
          icon: LucideIcons.smile,
          title: 'Ekspresi',
          color: Colors.orange,
          onTap: () {},
        ),
        _buildQuickActionCard(
          controller: controller,
          activityName: 'Lainnya',
          icon: LucideIcons.plus,
          title: 'Lainnya',
          color: const Color(0xFFD84040),
          onTap: () => Get.toNamed(Routes.LAINNYA),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required HomeController controller,
    required String activityName,
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.2), width: 1),
      ),
      color: color.withOpacity(0.05),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          await controller.addActivity(activityName);
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLatestActivities(HomeController controller) {
    return Obx(() {
      if (controller.lastActivities.isEmpty) {
        return const Text("Belum ada aktivitas terakhir");
      }

      return SizedBox(
        height: 200,
        child: ListView.builder(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          itemCount: controller.lastActivities.length,
          itemBuilder: (context, index) {
            final activity = controller.lastActivities[index];
            return _buildActivityItem(
              icon: _getIconFromName(activity['icon_name']),
              title: activity['name'],
              date: _formatDate(DateTime.parse(activity['date'])),
              color: _getColorFromHex(activity['color_hex']),
            );
          },
        ),
      );
    });
  }

  IconData _getIconFromName(String iconName) {
    switch (iconName) {
      case 'book-open':
        return LucideIcons.bookOpen;
      case 'users':
        return LucideIcons.users;
      case 'smile':
        return LucideIcons.smile;
      default:
        return LucideIcons.activity;
    }
  }

  Color _getColorFromHex(String hex) {
    try {
      return Color(int.parse(hex.replaceAll('#', '0xFF')));
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

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String date,
    required Color color,
  }) {
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
        title: Text(title),
        subtitle: Text(date),
      ),
    );
  }

  Widget _buildPracticeRecommendations() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.lightbulb, color: Colors.amber),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Berdasarkan analisis terakhir:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Kamu perlu meningkatkan kecepatan bicara dan mengurangi filler words',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  label: const Text('Narasi'),
                  backgroundColor: const Color(0xFFD84040).withOpacity(0.1),
                  labelStyle: const TextStyle(color: Color(0xFFD84040)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: const Color(0xFFD84040).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                ),
                Chip(
                  label: const Text('Wawancara'),
                  backgroundColor: const Color(0xFFD84040).withOpacity(0.1),
                  labelStyle: const TextStyle(color: Color(0xFFD84040)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: const Color(0xFFD84040).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
