import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../network/api_service.dart';

class CitizenAuthService {
  final ApiService _api;
  CitizenAuthService(this._api);

  Future<void> login({required String phone, required String password}) async {
    final response = await _api.client.post('/citizen/login', data: {
      'phone': phone,
      'password': password,
    });
    final token = response.data['access_token'] as String;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey, token);
  }
}
