import 'package:flutter/widgets.dart';

enum AppLanguage {
  english,
  arabic;

  String get code => this == AppLanguage.english ? 'en' : 'ar';

  bool get isArabic => this == AppLanguage.arabic;

  String get label => this == AppLanguage.english ? 'English' : 'العربية';
}

class AppLocalizations {
  final AppLanguage language;

  const AppLocalizations(this.language);

  bool get isArabic => language.isArabic;
  bool get isEnglish => language == AppLanguage.english;
  TextDirection get textDirection =>
      isArabic ? TextDirection.rtl : TextDirection.ltr;

  static AppLocalizations of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<AppLocalizationScope>();
    return scope?.localizations ??
        const AppLocalizations(AppLanguage.english);
  }

  String tr(String key) => _localizedValues[language.code]?[key] ?? key;

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appTitle': 'EMS Op Room',
      'settings': 'Settings',
      'darkMode': 'Dark Mode',
      'lightMode': 'Light Mode',
      'displayModeHint': 'Tap to switch between display modes',
      'notificationsSettings': 'Notification Settings',
      'logout': 'Logout',
      'language': 'Language',
      'languageDescription': 'Choose the application display language',
      'english': 'English',
      'arabic': 'Arabic',
      'login': 'LOGIN',
      'systemLogin': 'SYSTEM LOGIN',
      'userId': 'User ID',
      'password': 'Password',
      'dashboard': 'Dashboard',
      'overview': 'Overview',
      'liveOperationsSummary': 'Live Operations Summary',
      'liveUpdate': 'Live Update',
      'activeMissions': 'Active Missions',
      'fieldTeams': 'Field Teams',
      'availableTeams': 'Available Teams',
      'ongoingAlerts': 'Ongoing Alerts',
      'operationalSummaryHint':
          'Quick indicators to assess readiness and response in real time',
      'applyFilter': 'Apply Filter',
      'reset': 'Reset',
      'languageUpdated': 'Language updated successfully',
    },
    'ar': {
      'appTitle': 'غرفة عمليات الإسعاف',
      'settings': 'الإعدادات',
      'darkMode': 'الوضع الداكن',
      'lightMode': 'الوضع الفاتح',
      'displayModeHint': 'اضغط للتبديل بين أنماط العرض',
      'notificationsSettings': 'إعدادات الإشعارات',
      'logout': 'تسجيل الخروج',
      'language': 'اللغة',
      'languageDescription': 'اختر لغة عرض التطبيق',
      'english': 'الإنكليزية',
      'arabic': 'العربية',
      'login': 'تسجيل الدخول',
      'systemLogin': 'تسجيل الدخول للنظام',
      'userId': 'معرف المستخدم',
      'password': 'كلمة المرور',
      'dashboard': 'لوحة التحكم',
      'overview': 'نظرة عامة',
      'liveOperationsSummary': 'ملخص تشغيلي مباشر',
      'liveUpdate': 'تحديث حي',
      'activeMissions': 'المهام النشطة',
      'fieldTeams': 'الفرق الميدانية',
      'availableTeams': 'الفرق المتاحة',
      'ongoingAlerts': 'البلاغات الجارية',
      'operationalSummaryHint':
          'مؤشرات سريعة تساعد الإدارة على تقييم الجاهزية والاستجابة',
      'applyFilter': 'تطبيق الفلتر',
      'reset': 'إعادة ضبط',
      'languageUpdated': 'تم تحديث اللغة بنجاح',
    },
  };
}

class AppLocalizationScope extends InheritedWidget {
  final AppLocalizations localizations;

  const AppLocalizationScope({
    super.key,
    required this.localizations,
    required super.child,
  });

  @override
  bool updateShouldNotify(covariant AppLocalizationScope oldWidget) {
    return oldWidget.localizations.language != localizations.language;
  }
}

extension AppLocalizationExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
