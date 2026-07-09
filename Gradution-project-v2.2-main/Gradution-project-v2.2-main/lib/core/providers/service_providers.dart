import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/api_service.dart';
import '../services/auth_service.dart';
import '../services/case_service.dart';
import '../services/vehicle_service.dart';
import '../services/shift_service.dart';
import '../services/notification_service.dart';
import '../services/websocket_service.dart';

final apiProvider = Provider<ApiService>((ref) => ApiService());
final authServiceProvider = Provider<AuthService>((ref) => AuthService(ref.read(apiProvider)));
final caseServiceProvider = Provider<CaseService>((ref) => CaseService(ref.read(apiProvider)));
final vehicleServiceProvider = Provider<VehicleService>((ref) => VehicleService(ref.read(apiProvider)));
final shiftServiceProvider = Provider<ShiftService>((ref) => ShiftService(ref.read(apiProvider)));
final notificationServiceProvider = Provider<NotificationService>((ref) => NotificationService(ref.read(apiProvider)));
final wsProvider = Provider<WebSocketService>((ref) => WebSocketService());
