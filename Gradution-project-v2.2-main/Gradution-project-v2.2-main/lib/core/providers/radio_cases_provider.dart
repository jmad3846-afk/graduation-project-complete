import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'service_providers.dart';

const _activeStatuses = {'assigned', 'in_progress', 'at_hospital'};

/// Cases currently routed to the Radio interface: those a center has been
/// assigned to but that haven't been finished/archived yet. Fetches the
/// backend's CaseResource shape directly rather than going through the
/// thin CaseModel, since Radio needs movement_log/center/caller detail.
final radioCasesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final cases = await ref.read(caseServiceProvider).fetchCasesRaw();
  return cases.where((c) => _activeStatuses.contains(c['status'])).toList();
});

/// Maps a backend triage_code ('red'/'yellow'/'green', possibly null) to
/// the HeaderBar's capitalized keys, defaulting unknowns to green so a
/// case is never silently dropped from the count.
String triageCodeToStatusKey(String? triageCode) {
  switch (triageCode) {
    case 'red':
      return 'Red';
    case 'yellow':
      return 'Yellow';
    case 'green':
      return 'Green';
    default:
      return 'Green';
  }
}
