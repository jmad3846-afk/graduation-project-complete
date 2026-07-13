// lib/core/providers/case_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'service_providers.dart';
final caseProvider = StateNotifierProvider<CaseNotifier, CaseState>((ref) {
  return CaseNotifier(ref);
});

class CaseState {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const CaseState({this.isLoading = false, this.errorMessage, this.successMessage});

  CaseState copyWith({bool? isLoading, String? errorMessage, String? successMessage}) {
    return CaseState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

class CaseNotifier extends StateNotifier<CaseState> {
  final Ref _ref;
  CaseNotifier(this._ref) : super(const CaseState());

  Future<void> submitCase({required Map<String, dynamic> payload}) async {
    state = state.copyWith(isLoading: true, errorMessage: null, successMessage: null);
    try {
      final response = await _ref.read(apiProvider).client.post('/cases', data: payload);
      if (response.statusCode == 201) {
        state = state.copyWith(isLoading: false, successMessage: 'Case submitted successfully');
      } else {
        state = state.copyWith(isLoading: false, errorMessage: 'Failed to submit case: ${response.statusCode}');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}
