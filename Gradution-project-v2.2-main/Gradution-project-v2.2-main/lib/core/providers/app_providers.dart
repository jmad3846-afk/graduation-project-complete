import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ems_op_room/core/localization/app_localization.dart';

// Theme Provider
final themeProvider = StateNotifierProvider<ThemeNotifier, bool>((ref) {
  return ThemeNotifier();
});

// Language Provider
final languageProvider = StateNotifierProvider<LanguageNotifier, AppLanguage>((ref) {
  return LanguageNotifier();
});

class LanguageNotifier extends StateNotifier<AppLanguage> {
  LanguageNotifier() : super(AppLanguage.english);

  void setLanguage(AppLanguage language) {
    state = language;
  }
}

class ThemeNotifier extends StateNotifier<bool> {
  ThemeNotifier() : super(false);

  void toggleTheme() {
    state = !state;
  }

  void setTheme(bool isDark) {
    state = isDark;
  }
}

// Navigation Provider
final navigationProvider = StateProvider<int>((ref) => 0);

// Loading Provider
final loadingProvider = StateProvider<bool>((ref) => false);

// Error Provider
final errorProvider = StateProvider<String?>((ref) => null);

// ---------------------------------------------------------------------------
// Missions / Tasks state (shared between Lidar and Radio screens)
// ---------------------------------------------------------------------------

/// قائمة المهام المنتظرة في شاشة Lidar
final waitingTasksProvider =
    StateNotifierProvider<WaitingTasksNotifier, List<Map<String, dynamic>>>(
  (ref) => WaitingTasksNotifier(),
);

/// قائمة المهام النشطة في شاشة Lidar
final activeTasksProvider =
    StateNotifierProvider<ActiveTasksNotifier, List<Map<String, String>>>(
  (ref) => ActiveTasksNotifier(),
);

/// المهام التي يجب أن تظهر في شاشة الراديو بعد تحريك المركز من Lidar
final radioMissionsProvider =
    StateNotifierProvider<RadioMissionsNotifier, List<Map<String, dynamic>>>(
  (ref) => RadioMissionsNotifier(),
);

class WaitingTasksNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  WaitingTasksNotifier()
      : super([
          {
            'id': '#1001',
            'type': 'حادث سير',
            'location': 'المزرعة',
            'time': 'منذ 5 د',
            'priority': Colors.red,
          },
          {
            'id': '#1002',
            'type': 'احتشاء عضلة قلبية',
            'location': 'حي السلام',
            'time': 'منذ 15 د',
            'priority': Colors.red,
          },
          {
            'id': '#1003',
            'type': 'حريق محدود',
            'location': 'الصناعة',
            'time': 'منذ 25 د',
            'priority': Colors.orange,
          },
          {
            'id': '#1004',
            'type': 'إصابة عمل',
            'location': 'المهاجرين',
            'time': 'منذ 30 د',
            'priority': Colors.orange,
          },
          {
            'id': '#1005',
            'type': 'إغماء',
            'location': 'سوق البالة',
            'time': 'منذ 40 د',
            'priority': Colors.blue,
          },
          {
            'id': '#1006',
            'type': 'حادث دهس',
            'location': 'شارع 29 أيار',
            'time': 'منذ 50 د',
            'priority': Colors.red,
          },
          {
            'id': '#1007',
            'type': 'نوبة صرع',
            'location': 'ضاحية قدسيا دوار العلم',
            'time': 'منذ 60 د',
            'priority': Colors.blue,
          },
        ]);

  void removeTask(String id) {
    state = state.where((t) => t['id'] != id).toList();
  }
}

class ActiveTasksNotifier extends StateNotifier<List<Map<String, String>>> {
  ActiveTasksNotifier()
      : super([
          {
            'id': '#0555',
            'center': 'Center 100',
            'teamLeader': 'مازن علي',
            'caseType': 'حادث سير',
            'departure': 'المزة',
            'destination': 'مشفى المهايني',
            'status': 'في المنزل',
            'time': '12:30',
          },
          {
            'id': '#0554',
            'center': 'Center 115',
            'teamLeader': 'فهد يوسف',
            'caseType': 'احتشاء عضلة قلبية',
            'departure': 'حي السلام',
            'destination': 'مشفى العربي',
            'status': 'الى المستشفى',
            'time': '12:20',
          },
          {
            'id': '#0553',
            'center': 'Center 100',
            'teamLeader': 'ناصر سامي',
            'caseType': 'حريق محدود',
            'departure': 'المستودع 3',
            'destination': 'عيادة متخصصة',
            'status': 'الى المنزل',
            'time': '12:35',
          },
          {
            'id': '#0552',
            'center': 'Center 120',
            'teamLeader': 'هالة كمال',
            'caseType': 'إصابة عمل',
            'departure': 'منطقة صناعية A',
            'destination': 'مشفى الأمل',
            'status': 'مركز وصول',
            'time': '12:10',
          },
          {
            'id': '#0551',
            'center': 'Center 115',
            'teamLeader': 'ياسر خالد',
            'caseType': 'إغماء',
            'departure': 'سوق البالة',
            'destination': 'قاعدة',
            'status': 'عودة',
            'time': '12:00',
          },
        ]);

  /// إضافة مهمة جديدة قادمة من قائمة الانتظار بعد اختيار مركز جديد
  void addFromWaiting(Map<String, dynamic> waitingTask, String centerCode) {
    final newTask = <String, String>{
      'id': waitingTask['id']?.toString() ?? '',
      'center': 'Center $centerCode',
      'teamLeader': 'غير محدد',
      'caseType': waitingTask['type']?.toString() ?? '',
      'departure': waitingTask['location']?.toString() ?? '',
      'destination': 'غير محدد',
      'status': 'قيد المعالجة',
      'time': waitingTask['time']?.toString() ?? '',
    };
    state = [...state, newTask];
  }
}

class RadioMissionsNotifier
    extends StateNotifier<List<Map<String, dynamic>>> {
  RadioMissionsNotifier() : super(const []);

  /// إنشاء مهمة لواجهة الراديو من مهمة Lidar المنتظرة
  void addFromWaiting(Map<String, dynamic> waitingTask, String centerCode) {
    final priority = waitingTask['priority'] as Color?;
    String status;
    if (priority == Colors.red) {
      status = 'Red';
    } else if (priority == Colors.orange) {
      status = 'Yellow';
    } else {
      status = 'Green';
    }

    final mission = <String, dynamic>{
      'id': waitingTask['id']?.toString() ?? '',
      'name':
          '${waitingTask['type'] ?? ''} - ${waitingTask['location'] ?? ''}',
      'status': status,
      'center': centerCode,
      'code': '',
      'teamLeader': '',
      'toPatientTime': '',
      'atPatientTime': '',
      'toHospitalTime': '',
      'atHospitalTime': '',
      'toCenterTime': '',
      'atCenterTime': '',
      'hospital': '',
      'reasonForNoTransfer': '',
      'transferStatus': 'لم يتم النقل',
    };

    state = [...state, mission];
  }
}
