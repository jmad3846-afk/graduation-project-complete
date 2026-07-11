import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/case_model.dart';
import '../models/vehicle_model.dart';
import '../models/my_schedule_model.dart';
import '../models/shift_assignment_model.dart';
import '../models/shift_poll_model.dart';
import '../models/shift_request_model.dart';
import '../models/notification_model.dart';
import '../models/center_model.dart';
import 'service_providers.dart';

final caseListProvider = FutureProvider<List<CaseModel>>((ref) async {
  return await ref.read(caseServiceProvider).fetchCases();
});

final vehicleListProvider = FutureProvider<List<VehicleModel>>((ref) async {
  return await ref.read(vehicleServiceProvider).fetchVehicles();
});

final currentPollProvider = FutureProvider<ShiftPollModel?>((ref) async {
  return await ref.read(shiftServiceProvider).fetchCurrentPoll();
});

final myScheduleProvider = FutureProvider<List<ShiftAssignmentModel>>((ref) async {
  return await ref.read(shiftServiceProvider).fetchMySchedule();
});

final myScheduleWithCompensationProvider = FutureProvider<MyScheduleModel>((ref) async {
  return await ref.read(shiftServiceProvider).fetchMyScheduleWithCompensation();
});

final shiftRequestListProvider = FutureProvider<List<ShiftRequestModel>>((ref) async {
  return await ref.read(shiftServiceProvider).fetchShiftRequests();
});

final notificationListProvider = FutureProvider<List<NotificationModel>>((ref) async {
  return await ref.read(notificationServiceProvider).fetchNotifications();
});

final centersProvider = FutureProvider<List<CenterModel>>((ref) async {
  return await ref.read(centerServiceProvider).fetchCenters();
});
