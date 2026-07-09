
import '../models/notification_model.dart';
import '../network/api_service.dart';

class NotificationService {
  final ApiService _apiService;

  NotificationService(this._apiService);

  Future<List<NotificationModel>> fetchNotifications() async {
    try {
      final response = await _apiService.client.get('/notifications');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => NotificationModel.fromJson(json)).toList();
      }
    } catch (e) {
      print('Fetch notifications error: $e');
    }
    return [];
  }
}
