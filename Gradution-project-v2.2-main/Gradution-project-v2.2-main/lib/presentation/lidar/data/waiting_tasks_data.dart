import 'package:flutter/material.dart';

const Color errorColor = Colors.red;
const Color warningColor = Colors.orange;
const Color infoColor = Colors.blue;

final List<Map<String, dynamic>> waitingTasksData = [
  {'id': '#1001', 'type': 'حادث سير', 'location': 'المزرعة', 'time': 'منذ 5 د', 'priority': errorColor},
  {'id': '#1002', 'type': 'احتشاء عضلة قلبية', 'location': 'حي السلام', 'time': 'منذ 15 د', 'priority': errorColor},
  {'id': '#1003', 'type': 'حريق محدود', 'location': 'الصناعة', 'time': 'منذ 25 د', 'priority': warningColor},
  {'id': '#1004', 'type': 'إصابة عمل', 'location': 'المهاجرين', 'time': 'منذ 30 د', 'priority': warningColor},
  {'id': '#1005', 'type': 'إغماء', 'location': 'سوق البالة', 'time': 'منذ 40 د', 'priority': infoColor},
  {'id': '#1006', 'type': 'حادث دهس', 'location': 'شارع 29 أيار', 'time': 'منذ 50 د', 'priority': errorColor},
  {'id': '#1007', 'type': 'نوبة صرع', 'location': 'ضاحية قدسيا دوار العلم', 'time': 'منذ 60 د', 'priority': infoColor},
];
