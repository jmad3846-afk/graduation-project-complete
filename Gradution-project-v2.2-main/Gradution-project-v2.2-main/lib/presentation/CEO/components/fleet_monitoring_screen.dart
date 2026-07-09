// ignore_for_file: deprecated_member_use, avoid_print

import 'package:flutter/material.dart';

class FleetMonitoringPage extends StatelessWidget {
  const FleetMonitoringPage({super.key});

  final List<Map<String, String>> activeVehicles = const [
    {'carId': 'AMB-01', 'driver': 'يوسف خالد', 'status': 'في الطريق إلى المريض', 'color': 'Red'},
    {'carId': 'AMB-05', 'driver': 'علي محمود', 'status': 'في الطريق إلى المشفى', 'color': 'Yellow'},
    {'carId': 'AMB-12', 'driver': 'فهد ناصر', 'status': 'في الطريق إلى المركز', 'color': 'Green'},
    {'carId': 'AMB-09', 'driver': 'نورة سعيد', 'status': 'متاح (استعداد)', 'color': 'Blue'},
    {'carId': 'AMB-20', 'driver': 'خالد محمد', 'status': 'غير متاح (صيانة)', 'color': 'Grey'},
  ];

  Color _getStatusColor(String status) {
    if (status.contains('المريض')) return Colors.red;
    if (status.contains('المشفى')) return Colors.amber;
    if (status.contains('المركز')) return Colors.green;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('مراقبة الأسطول'),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: Column(
          children: [
            // منطقة الخريطة (الجزء العلوي)
            Expanded(
              flex: 1,
              child: Container(
                color: Colors.grey.shade200,
                alignment: Alignment.center,
                child: const Text(
                  'منطقة عرض الخريطة وتتبع المركبات ',
                  style: TextStyle(fontSize: 18, color: Colors.black54),
                ),
              ),
            ),
            const Divider(height: 1, color: Colors.grey),
            // قائمة المركبات العاملة (الجزء السفلي)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'المركبات العاملة (${activeVehicles.length})',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                textDirection: TextDirection.rtl,
              ),
            ),
            Expanded(
              flex: 1,
              child: ListView.builder(
                itemCount: activeVehicles.length,
                itemBuilder: (context, index) {
                  final car = activeVehicles[index];
                  final statusColor = _getStatusColor(car['status']!);

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    elevation: 1,
                    child: ListTile(
                      leading: Icon(Icons.local_shipping, color: statusColor),
                      title: Text(
                        '${car['carId']} - ${car['driver']}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'الحالة: ${car['status']}',
                        style: TextStyle(color: statusColor.withOpacity(0.8)),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          car['color']![0], // الترميز اللوني (حرف واحد)
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      onTap: () {
                        // منطق عرض تفاصيل المركبة على الخريطة
                        print('عرض تفاصيل ${car['carId']}');
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}