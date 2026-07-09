import 'package:pusher_client/pusher_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class WebSocketService {
  PusherClient? _pusher;
  final String _baseUrl = const String.fromEnvironment('FLUTTER_API_BASE_URL',
      defaultValue: 'http://127.0.0.1:8000/api');
  final String _appKey = const String.fromEnvironment('REVERB_APP_KEY',
      defaultValue: 'reverb_key');
  final String _host = const String.fromEnvironment('REVERB_HOST',
      defaultValue: '127.0.0.1');
  final String _port = const String.fromEnvironment('REVERB_PORT',
      defaultValue: '8080');

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);

    PusherOptions options = PusherOptions(
      host: _host,
      wsPort: int.parse(_port),
      encrypted: false,
      auth: PusherAuth(
        '$_baseUrl/broadcasting/auth',
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
      // pusher_client auto-reconnects with exponential backoff up to this cap.
      maxReconnectionAttempts: 100,
      maxReconnectGapInSeconds: 15,
    );

    _pusher = PusherClient(_appKey, options, autoConnect: true);

    _pusher?.connect();
  }

  PusherClient? get client => _pusher;
}
