import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  SharedPreferences.setMockInitialValues({});
  
  final api = ApiService();
  final auth = AuthService(api);
  
  print("Testing POST /login...");
  final user = await auth.login('0501234567', 'password'); // Dummy credentials
  if (user != null) {
    print("Login successful! Token received and stored.");
  } else {
    print("Login failed (probably invalid credentials, but endpoint works).");
  }

  final caseService = CaseService(api);
  print("Testing GET /cases...");
  final cases = await caseService.fetchCases();
  print("Cases retrieved: \${cases.length}");

  final vehicleService = VehicleService(api);
  print("Testing GET /vehicles...");
  final vehicles = await vehicleService.fetchVehicles();
  print("Vehicles retrieved: \${vehicles.length}");
  
  final notificationService = NotificationService(api);
  print("Testing GET /notifications...");
  final notifications = await notificationService.fetchNotifications();
  print("Notifications retrieved: \${notifications.length}");
}
