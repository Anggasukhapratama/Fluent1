import 'package:fluent/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Pastikan import GetX

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  Widget menuItem(String title, IconData icon, Color color) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: color,
          radius: 30,
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: () {
            if (title == "Latihan") {
              // Navigasi ke halaman Detection menggunakan GetX
              Get.toNamed(Routes.DETECTION);
            }
          },
          child: Text(title, style: const TextStyle(fontSize: 12)),
        ),
      ],
    );
  }

  Widget latihanBox(String title, double rating, Color color) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(Icons.play_circle_fill, size: 30),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, size: 16, color: Colors.orange),
              const SizedBox(width: 4),
              Text(rating.toString(), style: const TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget riwayatLatihanBox() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "Riwayat Latihan",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 8),
          Text("• Public Speaking - 16 April 2025"),
          Text("• Mock Interview - 15 April 2025"),
          Text("• Latihan Ekspresi - 13 April 2025"),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Home Page",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Selamat datang kembali 👋",
                style: TextStyle(fontSize: 18),
              ),
              const Text(
                "Level: Beginner",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),

              // MENU ICON WRAP
              Wrap(
                spacing: 20,
                runSpacing: 20,
                alignment: WrapAlignment.start,
                children: [
                  // Only show the Latihan button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: menuItem("Latihan", Icons.camera_alt, Colors.orange),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              const Text(
                "Rekomendasi Latihan",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    latihanBox("Latihan Public Speaking", 8.5, Colors.cyan),
                    const SizedBox(width: 12),
                    latihanBox("Mock Interview", 9.0, Colors.orange),
                    const SizedBox(width: 12),
                    latihanBox("Latihan", 7.8, Colors.purple),
                  ],
                ),
              ),

              // RIWAYAT
              riwayatLatihanBox(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.play_arrow),
            label: 'Aktivitas',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Level'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Akun'),
        ],
      ),
    );
  }
}
