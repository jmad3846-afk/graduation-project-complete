import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'service_providers.dart';
import 'center_selection_provider.dart';
import 'center_shift_provider.dart';
import '../constants/app_constants.dart';

class AuthState {
  final UserModel? user;
  final bool isLoading;

  AuthState({this.user, this.isLoading = false});

  AuthState copyWith({UserModel? user, bool? isLoading}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;

  AuthNotifier(this.ref) : super(AuthState()) {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);
    if (token != null) {
      final user = await ref.read(authServiceProvider).getCurrentUser();
      if (user != null) {
        state = state.copyWith(user: user);
        ref.read(wsProvider).init();
      }
    }
  }

  Future<bool> login(String id, String password) async {
    state = state.copyWith(isLoading: true);
    final user = await ref.read(authServiceProvider).login(id, password);
    if (user != null) {
      state = state.copyWith(user: user, isLoading: false);
      ref.read(wsProvider).init();
      return true;
    }
    state = state.copyWith(isLoading: false);
    return false;
  }
  
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    state = AuthState();
    ref.invalidate(selectedCenterIdProvider);
    ref.invalidate(centerShiftProvider);
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});
