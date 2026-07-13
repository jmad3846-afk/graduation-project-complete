import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final Dio _dio;

  ApiService()
      : _dio = Dio(BaseOptions(
          baseUrl: const String.fromEnvironment('FLUTTER_API_BASE_URL',
              defaultValue: 'http://127.0.0.1:8000/api'),
          headers: {'Accept': 'application/json'},
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 90),
          sendTimeout: const Duration(seconds: 30),
        )) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString(AppConstants.tokenKey);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }

  Dio get client => _dio;
}
