import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://192.168.56.212:5000', // Ganti sesuai IP PC kamu
      connectTimeout: Duration(seconds: 10), // Naikkan timeout agar tidak error
      receiveTimeout: Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  // Register user
  Future<Map<String, dynamic>> register(
    String username,
    String password,
  ) async {
    try {
      final response = await _dio.post(
        '/register',
        data: {'username': username, 'password': password},
      );
      return response.data;
    } catch (e) {
      return {"status": "fail", "message": "Register error: $e"};
    }
  }

  // Login user
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _dio.post(
        '/login',
        data: {'username': username, 'password': password},
      );
      return response.data;
    } catch (e) {
      return {"status": "fail", "message": "Login error: $e"};
    }
  }
}
