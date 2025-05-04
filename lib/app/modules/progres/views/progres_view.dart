import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fluent/app/modules/progres/controllers/progres_controller.dart';

class ProgresView extends GetView<ProgresController> {
  const ProgresView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Progres Saya',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, size: 20),
            onPressed: controller.refreshData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD84040)),
            ),
          );
        }
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryCard(),
              const SizedBox(height: 24),
              _buildTimeframeSelector(),
              const SizedBox(height: 24),
              _buildProgressChart(),
              const SizedBox(height: 24),
              _buildSectionHeader('Metrik Kemampuan'),
              const SizedBox(height: 16),
              _buildSkillMetricsGrid(),
              const SizedBox(height: 24),
              _buildSectionHeader('Area Perbaikan'),
              const SizedBox(height: 16),
              _buildImprovementAreasList(),
              const SizedBox(height: 48),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: const Color(0xFFD84040).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sesi Terakhir',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                Obx(
                  () => Text(
                    controller.getLastSessionDate(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryItem('Total Sesi', '${controller.totalSessions}'),
                _buildSummaryItem(
                  'Rata-rata',
                  '${controller.averageScore.toStringAsFixed(1)}/100',
                ),
                Obx(
                  () => _buildSummaryItem(
                    'Terakhir',
                    controller.lastSessionData['overall_score'] != null
                        ? '${controller.lastSessionData['overall_score'].toStringAsFixed(1)}/100'
                        : '-',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value) {
    return Column(
      children: [
        Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
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

  Widget _buildTimeframeSelector() {
    return Obx(
      () => Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: SegmentedButton<String>(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.resolveWith<Color>((
                              Set<MaterialState> states,
                            ) {
                              if (states.contains(MaterialState.selected)) {
                                return const Color(0xFFD84040).withOpacity(0.2);
                              }
                              return Colors.transparent;
                            }),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                      ),
                      segments:
                          controller.timeframes
                              .map(
                                (timeframe) => ButtonSegment<String>(
                                  value: timeframe,
                                  label: Text(
                                    timeframe,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color:
                                          controller.selectedTimeframe.value ==
                                                  timeframe
                                              ? const Color(0xFFD84040)
                                              : Colors.grey[700],
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                      selected: {controller.selectedTimeframe.value},
                      onSelectionChanged: (Set<String> newSelection) {
                        controller.changeTimeframe(newSelection.first);
                      },
                      showSelectedIcon: false,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressChart() {
    return Obx(
      () => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                controller.chartTitle.value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 200,
                child:
                    controller.currentProgressData.isEmpty
                        ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                LucideIcons.barChart2,
                                size: 40,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Belum ada data progres",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                        : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: controller.currentProgressData.length,
                          itemBuilder: (context, index) {
                            final item = controller.currentProgressData[index];
                            final score = item['score'] as double;
                            return Container(
                              width: 60,
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    height:
                                        (score /
                                            controller.maxChartValue.value) *
                                        150,
                                    width: 30,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFD84040),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Center(
                                      child: Text(
                                        score.toStringAsFixed(1),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    item['date'],
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkillMetricsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.6,
      ),
      itemCount: controller.skillMetrics.length,
      itemBuilder: (context, index) {
        final entry = controller.skillMetrics.entries.elementAt(index);
        return _buildSkillMetricCard(title: entry.key, value: entry.value);
      },
    );
  }

  Widget _buildSkillMetricCard({required String title, required double value}) {
    String displayTitle = title.replaceAll('_', ' ').capitalizeFirst!;
    IconData icon;
    Color color;
    switch (title) {
      case 'expression':
        icon = LucideIcons.smile;
        color = Colors.orange;
        break;
      case 'narrative':
        icon = LucideIcons.text;
        color = Colors.green;
        break;
      case 'clarity':
        icon = LucideIcons.volume2;
        color = Colors.blue;
        break;
      case 'confidence':
        icon = LucideIcons.zap;
        color = Colors.purple;
        break;
      case 'filler_words':
        icon = LucideIcons.volumeX;
        color = const Color(0xFFD84040);
        break;
      default:
        icon = LucideIcons.star;
        color = Colors.amber;
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.2), width: 1),
      ),
      color: color.withOpacity(0.05),
      child: SizedBox(
        height: 80,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      displayTitle,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: color,
                      ),
                    ),
                    Text(
                      title == 'filler_words'
                          ? '${value.toStringAsFixed(1)}/menit'
                          : '${value.toStringAsFixed(1)}/100',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImprovementAreasList() {
    return Obx(
      () => ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.improvementAreas.length,
        itemBuilder: (context, index) {
          return _buildImprovementCard(controller.improvementAreas[index]);
        },
      ),
    );
  }

  Widget _buildImprovementCard(Map<String, dynamic> area) {
    final colors = [
      const Color(0xFFD84040),
      Colors.blue,
      Colors.green,
      Colors.purple,
    ];
    final color =
        colors[controller.improvementAreas.indexOf(area) % colors.length];
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.2), width: 1),
      ),
      color: color.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(LucideIcons.alertCircle, size: 18, color: color),
                ),
                const SizedBox(width: 12),
                Text(
                  area['area'],
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              area['description'],
              style: const TextStyle(
                color: Colors.black54,
                height: 1.5,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: area['progress'],
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(color.withOpacity(0.8)),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(LucideIcons.lightbulb, size: 16, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Saran: ${area['suggestion']}',
                    style: const TextStyle(color: Colors.black54, fontSize: 12),
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
