// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';


class ShiftExchangeScreen extends StatelessWidget {
  const ShiftExchangeScreen({super.key});

  final List<Map<String, dynamic>> exchangeRequests = const [
    {'id': 1, 'sender': 'محمد بارودي', 'whith': 'محمد غصن', 'shift': 'مسائية', 'center': 140, 'status': 'Pending'},
    {'id': 2, 'sender': 'إلياس القرا','whith': 'إعتذار ',  'shift': 'صباحية', 'center': 100, 'status': 'Pending'},
    {'id': 3, 'sender': 'سارة أحمد', 'whith': 'موسى حورية', 'shift': 'ليلة', 'center': 115, 'status': 'Pending'},
    {'id': 4, 'sender': 'سارة شلبي','whith': 'محمد محسن',  'shift': 'ليلة', 'center': 115, 'status': 'Pending'},
  ];


  void _handleAccept(BuildContext context, int id, String sender) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم قبول طلب التبديل من $sender', textDirection: TextDirection.rtl)));
  }

  void _handleReject(BuildContext context, int id, String sender) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم رفض طلب التبديل من $sender', textDirection: TextDirection.rtl)));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('طلبات تبديل المناوبات'),
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: exchangeRequests.length,
          itemBuilder: (context, index) {
            final request = exchangeRequests[index];
            final message = 'طلب تبديل من ${request['sender']} مناوبة ${request['shift']} مركز ${request['center']}مع ${request['whith']}';

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // صندوق الرسالة
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 4)],
                          ),
                          child: Text(
                            message,
                            style: const TextStyle(fontSize: 16),
                            textDirection: TextDirection.rtl,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // أزرار القبول والرفض
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              icon: const Icon(Icons.check, size: 18),
                              label: const Text('قبول'),
                              onPressed: () => _handleAccept(context, request['id'], request['sender']),
                              style: TextButton.styleFrom(foregroundColor: Colors.green),
                            ),
                            TextButton.icon(
                              icon: const Icon(Icons.close, size: 18),
                              label: const Text('رفض'),
                              onPressed: () => _handleReject(context, request['id'], request['sender']),
                              style: TextButton.styleFrom(foregroundColor: Colors.red),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}