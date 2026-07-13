import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/api_service.dart';
import '../services/citizen_auth_service.dart';

final apiProvider = Provider<ApiService>((ref) => ApiService());
final citizenAuthServiceProvider =
    Provider<CitizenAuthService>((ref) => CitizenAuthService(ref.read(apiProvider)));
