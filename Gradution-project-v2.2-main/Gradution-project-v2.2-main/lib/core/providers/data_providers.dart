import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/case_model.dart';
import '../models/vehicle_model.dart';
import '../models/shift_model.dart';
import '../models/notification_model.dart';
import 'service_providers.dart';

final caseListProvider = FutureProvider<List<CaseModel>>((ref) async {
  return await ref.read(caseServiceProvider).fetchCases();
});

final vehicleListProvider = FutureProvider<List<VehicleModel>>((ref) async {
  return await ref.read(vehicleServiceProvider).fetchVehicles();
});

final shiftListProvider = FutureProvider<List<ShiftModel>>((ref) async {
  return await ref.read(shiftServiceProvider).fetchAll();
});

final notificationListProvider = FutureProvider<List<NotificationModel>>((ref) async {
  return await ref.read(notificationServiceProvider).fetchNotifications();
});
