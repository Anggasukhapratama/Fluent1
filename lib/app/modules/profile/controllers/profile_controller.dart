import 'package:fluent/app/data/services/api_service.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileController extends GetxController {
  final ApiService apiService = ApiService();
  final RxBool isLoading = false.obs;
  final RxString username = ''.obs;
  final RxString email = ''.obs;
  final RxString gender = ''.obs;
  final RxString occupation = ''.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
  }

  Future<void> loadUserProfile() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Get user data from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final savedUsername = prefs.getString('username') ?? '';
      final savedEmail = prefs.getString('email') ?? '';
      final savedGender = prefs.getString('gender') ?? '';
      final savedOccupation = prefs.getString('occupation') ?? '';

      // If we have complete data in shared preferences, use it
      if (savedUsername.isNotEmpty && savedEmail.isNotEmpty) {
        username.value = savedUsername;
        email.value = savedEmail;
        gender.value = savedGender;
        occupation.value = savedOccupation;
      } else {
        // Otherwise, try to fetch from API (if needed)
        // Note: Your current API doesn't have a profile endpoint, but you could add one
        // For now, we'll just use the shared preferences data
      }
    } catch (e) {
      errorMessage.value = 'Failed to load profile: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;
      await ApiService.clearTokens();
      Get.offAllNamed('/login'); // Navigate to login screen after logout
    } catch (e) {
      errorMessage.value = 'Logout failed: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  // You can add more methods here for updating profile if your API supports it
}
