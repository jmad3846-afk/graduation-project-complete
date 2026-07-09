import 'package:flutter/material.dart';
import 'app_colors.dart';

class MissionTheme extends InheritedWidget {
  final AppThemeData theme;

  const MissionTheme({
    super.key,
    required this.theme,
    required super.child,
  });

  static AppThemeData of(BuildContext context) {
    final missionTheme =
        context.dependOnInheritedWidgetOfExactType<MissionTheme>();
    if (missionTheme == null) {
      return AppThemeData.light;
    }
    return missionTheme.theme;
  }

  @override
  bool updateShouldNotify(covariant MissionTheme oldWidget) {
    return oldWidget.theme != theme;
  }
}

class AppThemeData {
  final ThemeData materialTheme;
  final Color primaryTextColor;
  final Color secondaryTextColor;
  final Color inputFillColor;
  final Color backgroundColor;
  final Color cardColor;
  final Color scaffoldBackgroundColor;
  final Color dividerColor;
  final Color borderColor;
  final Color primaryColor;
  final Color appBarBackground;
  final Color appBarForeground;

  const AppThemeData({
    required this.materialTheme,
    required this.primaryTextColor,
    required this.secondaryTextColor,
    required this.inputFillColor,
    required this.backgroundColor,
    required this.cardColor,
    required this.scaffoldBackgroundColor,
    required this.dividerColor,
    required this.borderColor,
    required this.primaryColor,
    required this.appBarBackground,
    required this.appBarForeground,
  });

  static final AppThemeData light = AppThemeData(
    materialTheme: AppThemes.lightTheme,
    primaryTextColor: AppColors.lightPrimaryText,
    secondaryTextColor: AppColors.lightSecondaryText,
    inputFillColor: AppColors.lightInputFill,
    backgroundColor: AppColors.lightBackground,
    cardColor: AppColors.lightCard,
    scaffoldBackgroundColor: AppColors.lightScaffold,
    dividerColor: AppColors.lightDivider,
    borderColor: AppColors.lightBorder,
    primaryColor: AppColors.primaryBlue,
    appBarBackground: AppColors.white,
    appBarForeground: AppColors.lightPrimaryText,
  );

  static final AppThemeData dark = AppThemeData(
    materialTheme: AppThemes.darkTheme,
    primaryTextColor: AppColors.darkPrimaryText,
    secondaryTextColor: AppColors.darkSecondaryText,
    inputFillColor: AppColors.darkInputFill,
    backgroundColor: AppColors.darkBackground,
    cardColor: AppColors.darkCard,
    scaffoldBackgroundColor: AppColors.darkScaffold,
    dividerColor: AppColors.darkDivider,
    borderColor: AppColors.darkBorder,
    primaryColor: AppColors.primaryBlueLight,
    appBarBackground: AppColors.darkCard,
    appBarForeground: AppColors.darkPrimaryText,
  );
}

class AppThemes {
  static ThemeData get lightTheme => _buildTheme(Brightness.light);

  static ThemeData get darkTheme => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = isDark ? _darkScheme : _lightScheme;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final dividerColor =
        isDark ? AppColors.darkDivider : AppColors.lightDivider;
    final inputFill = isDark ? AppColors.darkInputFill : AppColors.lightInputFill;
    final primaryText =
        isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText;
    final secondaryText =
        isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;
    final scaffold =
        isDark ? AppColors.darkScaffold : AppColors.lightScaffold;
    final background =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final mutedSurface =
        isDark ? AppColors.darkSurfaceMuted : AppColors.lightSurfaceMuted;

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffold,
      cardColor: cardColor,
      dividerColor: dividerColor,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      fontFamily: null,
    );

    return base.copyWith(
      primaryColor: scheme.primary,
      shadowColor: AppColors.black.withValues(alpha: isDark ? 0.28 : 0.08),
      canvasColor: background,
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? AppColors.darkCard : AppColors.white,
        foregroundColor: primaryText,
        surfaceTintColor: AppColors.transparent,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: primaryText, size: 22),
        titleTextStyle: TextStyle(
          color: primaryText,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        surfaceTintColor: AppColors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: borderColor),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFill,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: TextStyle(
          color: secondaryText.withValues(alpha: 0.9),
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: TextStyle(
          color: secondaryText,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelStyle: TextStyle(
          color: scheme.primary,
          fontWeight: FontWeight.w600,
        ),
        prefixIconColor: secondaryText,
        suffixIconColor: secondaryText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: scheme.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.error, width: 1.4),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.error, width: 1.6),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          disabledBackgroundColor: AppColors.disabled.withValues(alpha: 0.3),
          disabledForegroundColor: AppColors.disabled,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            letterSpacing: 0.1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          side: BorderSide(color: borderColor),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: mutedSurface,
        selectedColor: scheme.primary.withValues(alpha: 0.14),
        secondarySelectedColor: scheme.primary.withValues(alpha: 0.14),
        disabledColor: AppColors.disabled.withValues(alpha: 0.18),
        side: BorderSide(color: borderColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        labelStyle: TextStyle(
          color: primaryText,
          fontWeight: FontWeight.w600,
        ),
        secondaryLabelStyle: TextStyle(
          color: scheme.primary,
          fontWeight: FontWeight.w700,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      dividerTheme: DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 1,
      ),
      listTileTheme: ListTileThemeData(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        iconColor: secondaryText,
        textColor: primaryText,
        tileColor: AppColors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      iconTheme: IconThemeData(color: primaryText, size: 22),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: cardColor,
        contentTextStyle: TextStyle(
          color: primaryText,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: borderColor),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: mutedSurface,
        circularTrackColor: mutedSurface,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cardColor,
        surfaceTintColor: AppColors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cardColor,
        surfaceTintColor: AppColors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
      textTheme: _textTheme(base.textTheme, primaryText, secondaryText),
    );
  }

  static TextTheme _textTheme(
    TextTheme base,
    Color primaryText,
    Color secondaryText,
  ) {
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        color: primaryText,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.2,
      ),
      displayMedium: base.displayMedium?.copyWith(
        color: primaryText,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
      ),
      headlineLarge: base.headlineLarge?.copyWith(
        color: primaryText,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.6,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        color: primaryText,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
      ),
      titleLarge: base.titleLarge?.copyWith(
        color: primaryText,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      ),
      titleMedium: base.titleMedium?.copyWith(
        color: primaryText,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: base.titleSmall?.copyWith(
        color: secondaryText,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        color: primaryText,
        height: 1.45,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        color: primaryText,
        height: 1.4,
      ),
      bodySmall: base.bodySmall?.copyWith(
        color: secondaryText,
        height: 1.35,
      ),
      labelLarge: base.labelLarge?.copyWith(
        color: primaryText,
        fontWeight: FontWeight.w700,
      ),
      labelMedium: base.labelMedium?.copyWith(
        color: secondaryText,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  static const ColorScheme _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primaryBlue,
    onPrimary: AppColors.white,
    secondary: AppColors.primaryCyan,
    onSecondary: AppColors.white,
    error: AppColors.error,
    onError: AppColors.white,
    surface: AppColors.lightCard,
    onSurface: AppColors.lightPrimaryText,
    tertiary: AppColors.accentTeal,
    onTertiary: AppColors.white,
    surfaceContainerHighest: AppColors.lightSurfaceMuted,
    onSurfaceVariant: AppColors.lightSecondaryText,
    outline: AppColors.lightBorder,
    outlineVariant: AppColors.lightDivider,
    shadow: AppColors.black,
    scrim: AppColors.black,
    inverseSurface: Color(0xFF162231),
    onInverseSurface: AppColors.white,
    inversePrimary: AppColors.primaryBlueLight,
  );

  static const ColorScheme _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.primaryBlueLight,
    onPrimary: AppColors.black,
    secondary: AppColors.primaryCyan,
    onSecondary: AppColors.black,
    error: AppColors.error,
    onError: AppColors.white,
    surface: AppColors.darkCard,
    onSurface: AppColors.darkPrimaryText,
    tertiary: AppColors.accentTeal,
    onTertiary: AppColors.black,
    surfaceContainerHighest: AppColors.darkSurfaceMuted,
    onSurfaceVariant: AppColors.darkSecondaryText,
    outline: AppColors.darkBorder,
    outlineVariant: AppColors.darkDivider,
    shadow: AppColors.black,
    scrim: AppColors.black,
    inverseSurface: AppColors.white,
    onInverseSurface: AppColors.lightPrimaryText,
    inversePrimary: AppColors.primaryBlueDark,
  );
}

extension ThemeContextExtension on BuildContext {
  AppThemeData get missionTheme => MissionTheme.of(this);
  Color get primaryTextColor => MissionTheme.of(this).primaryTextColor;
  Color get secondaryTextColor => MissionTheme.of(this).secondaryTextColor;
  Color get inputFillColor => MissionTheme.of(this).inputFillColor;
  Color get backgroundColor => MissionTheme.of(this).backgroundColor;
  Color get cardColor => MissionTheme.of(this).cardColor;
  ThemeData get materialTheme => MissionTheme.of(this).materialTheme;
}
