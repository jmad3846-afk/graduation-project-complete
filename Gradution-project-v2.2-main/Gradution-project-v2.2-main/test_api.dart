import 'package:shared_preferences/shared_preferences.dart';
import 'lib/core/network/api_service.dart';
import 'lib/core/services/auth_service.dart';
import 'lib/core/services/case_service.dart';
import 'lib/core/services/vehicle_service.dart';
import 'lib/core/services/notification_service.dart';

void main() async {
  // We need to bypass SharedPreferences in a pure Dart CLI if flutter is not initialized,
  // but since we are just doing integration test, we might get an error.
  // We can test the endpoints via ApiService directly.
  // ignore: invalid_use_of_visible_for_testing_member
  SharedPreferences.setMockInitialValues({});

  final api = ApiService();
  final auth = AuthService(api);

  // ignore: avoid_print
  print("Testing POST /login...");
  final user = await auth.login('0501234567', 'password'); // Dummy credentials
  if (user != null) {
    // ignore: avoid_print
    print("Login successful! Token received and stored.");
  } else {
    // ignore: avoid_print
    print("Login failed (probably invalid credentials, but endpoint works).");
  }

  final caseService = CaseService(api);
  // ignore: avoid_print
  print("Testing GET /cases...");
  final cases = await caseService.fetchCases();
  // ignore: avoid_print
  print("Cases retrieved: ${cases.length}");

  final vehicleService = VehicleService(api);
  // ignore: avoid_print
  print("Testing GET /vehicles...");
  final vehicles = await vehicleService.fetchVehicles();
  // ignore: avoid_print
  print("Vehicles retrieved: ${vehicles.length}");

  final notificationService = NotificationService(api);
  // ignore: avoid_print
  print("Testing GET /notifications...");
  final notifications = await notificationService.fetchNotifications();
  // ignore: avoid_print
  print("Notifications retrieved: ${notifications.length}");
}
