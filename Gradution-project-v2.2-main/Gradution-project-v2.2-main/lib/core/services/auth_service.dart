import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../network/api_service.dart';
import '../constants/app_constants.dart';

class AuthService {
  final ApiService _apiService;

  AuthService(this._apiService);

  Future<UserModel?> login(String id, String password) async {
    try {
      final response = await _apiService.client.post('/login', data: {
        'phone': id,
        'password': password,
      });

      if (response.statusCode == 200) {
        final token = response.data['access_token'];
        final user = UserModel.fromJson(response.data['user']);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.tokenKey, token);

        return user;
      }
    } catch (e) {
      debugPrint('Login error: $e');
    }
    return null;
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      final response = await _apiService.client.get('/user');
      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data);
      }
    } catch (e) {
      debugPrint('Get user error: $e');
    }
    return null;
  }
}
