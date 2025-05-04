import 'dart:async';
import 'package:get/get.dart';
import 'package:fluent/app/data/services/api_service.dart';
import 'package:intl/intl.dart';

class ProgresController extends GetxController {
  final ApiService apiService = ApiService();
  final RxBool isLoading = false.obs;
  final RxString selectedTimeframe = 'Minggu ini'.obs;
  final List<String> timeframes = [
    'Minggu ini',
    'Bulan ini',
    '3 Bulan',
    '6 Bulan',
  ];
  final RxString selectedChartData = 'Kemampuan'.obs;
  final List<String> chartDataOptions = ['Kemampuan', 'Kecepatan', 'Ekspresi'];

  final RxList<Map<String, dynamic>> currentProgressData =
      <Map<String, dynamic>>[].obs;
  final RxDouble maxChartValue = 100.0.obs;
  final RxString chartTitle = 'Perkembangan Kemampuan'.obs;

  final RxMap<String, double> skillMetrics =
      <String, double>{
        'expression': 0.0,
        'narrative': 0.0,
        'clarity': 0.0,
        'confidence': 0.0,
        'filler_words': 0.0,
      }.obs;

  final RxList<Map<String, dynamic>> improvementAreas =
      <Map<String, dynamic>>[].obs;
  final RxMap<String, dynamic> lastSessionData = <String, dynamic>{}.obs;
  final RxInt totalSessions = 0.obs;
  final RxDouble averageScore = 0.0.obs;

  Timer? _autoRefreshTimer;

  @override
  void onInit() async {
    super.onInit();
    await loadProgressData();
    startAutoRefresh();
  }

  @override
  void onClose() {
    _autoRefreshTimer?.cancel();
    super.onClose();
  }

  Future<void> loadProgressData() async {
    try {
      isLoading.value = true;
      final response = await apiService.getProgressData();

      if (response['status'] == 'success' && response['data'] != null) {
        final progressData = response['data'];

        // Handle last session data
        lastSessionData.value = {
          'timestamp': _parseTimestamp(
            progressData['last_session']?['timestamp'],
          ),
          'overall_score':
              (progressData['last_session']?['overall_score'] as num?)
                  ?.toDouble() ??
              0.0,
        };

        // Handle metrics
        final metrics = progressData['metrics'] ?? {};
        skillMetrics.value = {
          'expression': (metrics['expression'] as num?)?.toDouble() ?? 0.0,
          'narrative': (metrics['narrative'] as num?)?.toDouble() ?? 0.0,
          'clarity': (metrics['clarity'] as num?)?.toDouble() ?? 0.0,
          'confidence': (metrics['confidence'] as num?)?.toDouble() ?? 0.0,
          'filler_words': (metrics['filler_words'] as num?)?.toDouble() ?? 0.0,
        };

        // Handle history data
        currentProgressData.assignAll(
          (progressData['history'] as List? ?? []).map((session) {
            return {
              'date': _formatDate(_parseTimestamp(session['timestamp'])),
              'score': (session['overall_score'] as num?)?.toDouble() ?? 0.0,
            };
          }).toList(),
        );

        // Handle improvement areas
        improvementAreas.assignAll(
          (progressData['weaknesses'] as List? ?? []).map((weakness) {
            return {
              'area': weakness['area'] ?? '',
              'description': weakness['description'] ?? '',
              'progress': (weakness['progress'] as num?)?.toDouble() ?? 0.0,
              'suggestion': weakness['suggestion'] ?? '',
            };
          }).toList(),
        );

        totalSessions.value = progressData['total_sessions'] ?? 0;
        averageScore.value =
            (progressData['average_score'] as num?)?.toDouble() ?? 0.0;

        _calculateMaxChartValue();
      } else {
        Get.snackbar('Error', response['message'] ?? 'Gagal memuat data');
      }
    } catch (e, stack) {
      print('Error in loadProgressData: $e\n$stack');
      Get.snackbar('Error', 'Terjadi kesalahan: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  DateTime? _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) return null;
    try {
      if (timestamp is DateTime) return timestamp;
      if (timestamp is String) {
        return DateTime.tryParse(timestamp) ??
            DateFormat("yyyy-MM-ddTHH:mm:ssZ").parse(timestamp);
      }
      if (timestamp is int) {
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      }
      return null;
    } catch (e) {
      print('Error parsing timestamp $timestamp: $e');
      return null;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    try {
      return DateFormat('dd/MM').format(date.toLocal());
    } catch (e) {
      print('Error formatting date: $e');
      return '-';
    }
  }

  String getLastSessionDate() {
    try {
      final timestamp = lastSessionData['timestamp'];
      if (timestamp == null) return '-';

      final date = _parseTimestamp(timestamp);
      if (date == null) return '-';

      return DateFormat('dd MMM yyyy, HH:mm').format(date.toLocal());
    } catch (e) {
      print('Error in getLastSessionDate: $e');
      return '-';
    }
  }

  void _calculateMaxChartValue() {
    if (currentProgressData.isEmpty) {
      maxChartValue.value = 100.0;
      return;
    }

    final max = currentProgressData.fold(0.0, (prev, item) {
      final value = item['score'] as double;
      return value > prev ? value : prev;
    });

    maxChartValue.value = (max * 1.2).clamp(50, 100).toDouble();
  }

  void changeTimeframe(String timeframe) {
    selectedTimeframe.value = timeframe;
    loadProgressData();
  }

  void changeChartData(String dataType) {
    selectedChartData.value = dataType;
    chartTitle.value = 'Perkembangan $dataType';
  }

  void refreshData() {
    loadProgressData();
  }

  void startAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      if (!isLoading.value) refreshData();
    });
  }
}
