import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/archive_model.dart';
import '../services/archive_service.dart';
import 'service_providers.dart';

final archiveServiceProvider = Provider<ArchiveService>((ref) => ArchiveService(ref.read(apiProvider)));

class ArchiveState {
  final List<ArchiveModel> archives;
  final bool isLoading;
  final String? error;
  final String? successMessage;

  const ArchiveState({
    this.archives = const [],
    this.isLoading = false,
    this.error,
    this.successMessage,
  });

  ArchiveState copyWith({
    List<ArchiveModel>? archives,
    bool? isLoading,
    String? error,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return ArchiveState(
      archives: archives ?? this.archives,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }
}

class ArchiveNotifier extends StateNotifier<ArchiveState> {
  final ArchiveService _service;

  ArchiveNotifier(this._service) : super(const ArchiveState());

  Future<void> loadAll() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final archives = await _service.fetchArchives();
      state = state.copyWith(isLoading: false, archives: archives);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'فشل تحميل الأرشيف: ${e.toString()}');
    }
  }

  Future<void> markPrinted(int archiveId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _service.markPrinted(archiveId);
      await loadAll();
      state = state.copyWith(isLoading: false, successMessage: 'تم تحديث حالة الطباعة');
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'فشل تحديث حالة الطباعة: ${e.toString()}');
    }
  }

  void clearMessages() {
    state = state.copyWith(clearError: true, clearSuccess: true);
  }
}

final archiveProvider = StateNotifierProvider<ArchiveNotifier, ArchiveState>((ref) {
  return ArchiveNotifier(ref.read(archiveServiceProvider));
});
