import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/center_selection_provider.dart';

// Lets an admin choose which center's dashboard to view. center_manager
// never sees this — their center is fixed and the backend scopes their
// requests to it automatically.
class CenterPicker extends ConsumerWidget {
  const CenterPicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(authNotifierProvider).user?.role == 'admin';
    if (!isAdmin) return const SizedBox.shrink();

    final centersAsync = ref.watch(centersListProvider);
    final selectedCenterId = ref.watch(selectedCenterIdProvider);

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: centersAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => const Text('تعذر تحميل قائمة المراكز', style: TextStyle(color: Colors.grey)),
          data: (centers) {
            return DropdownButtonFormField<int>(
              initialValue: selectedCenterId,
              decoration: const InputDecoration(
                labelText: 'المركز',
                border: OutlineInputBorder(),
              ),
              hint: const Text('اختر مركزاً'),
              items: centers
                  .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                  .toList(),
              onChanged: (value) => ref.read(selectedCenterIdProvider.notifier).state = value,
            );
          },
        ),
      ),
    );
  }
}
