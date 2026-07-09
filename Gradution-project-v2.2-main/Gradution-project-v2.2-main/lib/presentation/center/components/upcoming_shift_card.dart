import 'package:flutter/material.dart';

class UpcomingShiftCard extends StatelessWidget {
  const UpcomingShiftCard({super.key});

  static const List<String> team = ['أحمد فهد', 'سارة ناصر', 'فريق دعم (أ)'];
  static const String time = '22:00';

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🗓️ المناوبة القادمة ($time)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const Divider(),
            ...team.map(
                  (name) => Row(
                children: [
                  const Icon(Icons.person, size: 18, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(name),
                ],
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم تسجيل دخول المناوبين بنجاح')),
                );
              },
              icon: const Icon(Icons.login),
              label: const Text('تسجيل دخول المناوبة'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 40),
                backgroundColor: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
