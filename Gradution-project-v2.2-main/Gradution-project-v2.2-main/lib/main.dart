import 'package:ems_op_room/core/app_themes.dart';
import 'package:ems_op_room/core/localization/app_localization.dart';
import 'package:ems_op_room/core/navigation/app_router.dart';
import 'package:ems_op_room/core/providers/app_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(
    const ProviderScope(
      child: EMSOpRoom(),
    ),
  );
}

class EMSOpRoom extends ConsumerWidget {
  const EMSOpRoom({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);
    final language = ref.watch(languageProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'EMS Op Room',
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('ar', ''),
      ],
      locale: Locale(language.code),
      builder: (context, child) {
        return AppLocalizationScope(
          localizations: AppLocalizations(language),
          child: child!,
        );
      },
      routerConfig: appRouter,
    );
  }
}
