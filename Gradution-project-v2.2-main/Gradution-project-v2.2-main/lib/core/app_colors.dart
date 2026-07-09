import 'package:flutter/material.dart';

class AppColors {
  // Helper method to check dark mode
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  // Method to get colors based on current theme
  static Color getPrimaryText(BuildContext context) {
    return isDarkMode(context) ? darkPrimaryText : lightPrimaryText;
  }

  static Color getSecondaryText(BuildContext context) {
    return isDarkMode(context) ? darkSecondaryText : lightSecondaryText;
  }

  static Color getInputFill(BuildContext context) {
    return isDarkMode(context) ? darkInputFill : lightInputFill;
  }

  static Color getBackground(BuildContext context) {
    return isDarkMode(context) ? darkBackground : lightBackground;
  }

  static Color getCard(BuildContext context) {
    return isDarkMode(context) ? darkCard : lightCard;
  }

  static Color getScaffold(BuildContext context) {
    return isDarkMode(context) ? darkScaffold : lightScaffold;
  }

  static Color getDivider(BuildContext context) {
    return isDarkMode(context) ? darkDivider : lightDivider;
  }

  static Color getBorder(BuildContext context) {
    return isDarkMode(context) ? darkBorder : lightBorder;
  }

  static Color getSecondaryTextColor(BuildContext context) {
    return isDarkMode(context) ? darkSecondaryText : lightSecondaryText;
  }

  static Color getSurfaceMuted(BuildContext context) {
    return isDarkMode(context) ? darkSurfaceMuted : lightSurfaceMuted;
  }

  static Color getOverlay(BuildContext context) {
    return isDarkMode(context) ? darkOverlay : lightOverlay;
  }

  static Color getCardBorder(BuildContext context) {
    return isDarkMode(context) ? darkCardBorder : lightCardBorder;
  }

  static Color getSuccessContainer(BuildContext context) {
    return isDarkMode(context) ? darkSuccessContainer : lightSuccessContainer;
  }

  static Color getWarningContainer(BuildContext context) {
    return isDarkMode(context) ? darkWarningContainer : lightWarningContainer;
  }

  static Color getErrorContainer(BuildContext context) {
    return isDarkMode(context) ? darkErrorContainer : lightErrorContainer;
  }

  static Color getInfoContainer(BuildContext context) {
    return isDarkMode(context) ? darkInfoContainer : lightInfoContainer;
  }

  static LinearGradient getPrimaryGradient(BuildContext context) {
    return isDarkMode(context) ? darkPrimaryGradient : lightPrimaryGradient;
  }

  // Brand colors
  static const Color primaryBlue = Color(0xFF1565C0);
  static const Color primaryBlueDark = Color(0xFF0D47A1);
  static const Color primaryBlueLight = Color(0xFF42A5F5);
  static const Color primaryCyan = Color(0xFF00ACC1);
  static const Color accentTeal = Color(0xFF009688);

  // Status colors
  static const Color statusRed = Color(0xFFE53935);
  static const Color statusYellow = Color(0xFFFFB300);
  static const Color statusGreen = Color(0xFF2E7D32);
  static const Color statusGrey = Color(0xFF78909C);

  // Light theme core
  static const Color lightPrimaryText = Color(0xFF102033);
  static const Color lightSecondaryText = Color(0xFF5F7085);
  static const Color lightInputFill = Color(0xFFF7FAFC);
  static const Color lightBackground = Color(0xFFF4F7FB);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightScaffold = Color(0xFFF1F5F9);
  static const Color lightDivider = Color(0xFFE2E8F0);
  static const Color lightBorder = Color(0xFFD7E0EA);
  static const Color lightSurfaceMuted = Color(0xFFEAF1F8);
  static const Color lightOverlay = Color(0x99102033);
  static const Color lightCardBorder = Color(0xFFE6EDF5);

  // Dark theme core
  static const Color darkPrimaryText = Color(0xFFF4F7FB);
  static const Color darkSecondaryText = Color(0xFF9FB0C3);
  static const Color darkInputFill = Color(0xFF142235);
  static const Color darkBackground = Color(0xFF0B1420);
  static const Color darkCard = Color(0xFF111E2E);
  static const Color darkScaffold = Color(0xFF09111B);
  static const Color darkDivider = Color(0xFF223247);
  static const Color darkBorder = Color(0xFF24364D);
  static const Color darkSurfaceMuted = Color(0xFF162538);
  static const Color darkOverlay = Color(0xB309111B);
  static const Color darkCardBorder = Color(0xFF1D3044);

  // Semantic colors
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF38BDF8);

  static const Color lightSuccessContainer = Color(0xFFEAF9F0);
  static const Color lightWarningContainer = Color(0xFFFFF5DF);
  static const Color lightErrorContainer = Color(0xFFFFE8E8);
  static const Color lightInfoContainer = Color(0xFFE8F6FD);

  static const Color darkSuccessContainer = Color(0xFF123322);
  static const Color darkWarningContainer = Color(0xFF3B2A09);
  static const Color darkErrorContainer = Color(0xFF3A1518);
  static const Color darkInfoContainer = Color(0xFF0E2C3A);

  // Common colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Color(0x00000000);
  static const Color disabled = Color(0xFF94A3B8);

  // Button colors
  static const Color buttonPrimary = primaryBlue;
  static const Color buttonSecondary = statusGrey;
  static const Color buttonSuccess = success;
  static const Color buttonWarning = warning;
  static const Color buttonError = error;

  static const LinearGradient lightPrimaryGradient = LinearGradient(
    colors: [Color(0xFF0F6CBD), Color(0xFF19A0D8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkPrimaryGradient = LinearGradient(
    colors: [Color(0xFF1A75CF), Color(0xFF0E4C82)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

extension AppColorsExtension on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  Color get primaryTextColor => AppColors.getPrimaryText(this);
  Color get secondaryTextColor => AppColors.getSecondaryText(this);

  Color get backgroundColor => AppColors.getBackground(this);
  Color get scaffoldColor => AppColors.getScaffold(this);
  Color get cardColor => AppColors.getCard(this);

  Color get inputFillColor => AppColors.getInputFill(this);
  Color get dividerColor => AppColors.getDivider(this);
  Color get borderColor => AppColors.getBorder(this);
  Color get mutedSurfaceColor => AppColors.getSurfaceMuted(this);
  Color get overlayColor => AppColors.getOverlay(this);
  Color get cardBorderColor => AppColors.getCardBorder(this);

  Color get primaryBlue => AppColors.primaryBlue;
  Color get statusRed => AppColors.statusRed;
  Color get statusYellow => AppColors.statusYellow;
  Color get statusGreen => AppColors.statusGreen;
  Color get success => AppColors.success;
  Color get error => AppColors.error;
  Color get warning => AppColors.warning;
}