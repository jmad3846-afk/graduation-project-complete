import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/center_model.dart';
import 'service_providers.dart';

// Holds the center an admin has chosen to view in the Center dashboard.
// null means "no center selected" (center_manager never needs this — the
// backend defaults to their own center_id automatically).
final selectedCenterIdProvider = StateProvider<int?>((ref) => null);

final centersListProvider = FutureProvider<List<CenterModel>>((ref) async {
  return ref.read(centerServiceProvider).fetchCenters();
});
