import 'package:flutter/material.dart';
import 'vehicle_status_card.dart';

class CenterMainContent extends StatelessWidget {
  const CenterMainContent({super.key});

  static const List<Map<String, dynamic>> centerVehicles = [
    {
      'id': '104',
      'type': 'AMB-A',
      'status': 'في مهمة (أحمر)',
      'driver': 'خالد محمد',
      'eta': '15 دقيقة'
    },
    {
      'id': '102',
      'type': 'AMB-B',
      'status': 'متاح في المركز',
      'driver': 'يوسف علي',
      'eta': 'متاح'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'مركبات المركز 140 العاملة على الأرض',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Divider(),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: centerVehicles.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            mainAxisSpacing: 16,
            childAspectRatio: 3.5,
          ),
          itemBuilder: (context, index) {
            return VehicleStatusCard(vehicle: centerVehicles[index]);
          },
        ),
        const SizedBox(height: 30),
        Text(
          'تتبع حي للمركبات',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Divider(),
        Container(
          height: 400,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.blueGrey.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text(
            'خريطة تظهر موقع المركبة 104 (في مهمة) و 102 (في المركز)',
            style: TextStyle(color: Colors.blueGrey),
          ),
        ),
      ],
    );
  }
}
