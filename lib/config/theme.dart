import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();

  // iOS system colors
  static const Color iosBlue = Color(0xFF007AFF);
  static const Color iosDarkBlue = Color(0xFF0A84FF);
  static const Color iosGreen = Color(0xFF34C759);
  static const Color iosIndigo = Color(0xFF5856D6);
  static const Color iosOrange = Color(0xFFFF9500);
  static const Color iosPink = Color(0xFFFF2D55);
  static const Color iosPurple = Color(0xFFAF52DE);
  static const Color iosRed = Color(0xFFFF3B30);
  static const Color iosTeal = Color(0xFF5AC8FA);
  static const Color iosYellow = Color(0xFFFFCC00);
  static const Color iosGray = Color(0xFF8E8E93);
  static const Color iosGray2 = Color(0xFFAEAEB2);
  static const Color iosGray3 = Color(0xFFC7C7CC);
  static const Color iosGray4 = Color(0xFFD1D1D6);
  static const Color iosGray5 = Color(0xFFE5E5EA);
  static const Color iosGray6 = Color(0xFFF2F2F7);

  // Dark mode grays
  static const Color iosGrayDark = Color(0xFF8E8E93);
  static const Color iosGrayDark2 = Color(0xFF636366);
  static const Color iosGrayDark3 = Color(0xFF48484A);
  static const Color iosGrayDark4 = Color(0xFF3A3A3C);
  static const Color iosGrayDark5 = Color(0xFF2C2C2E);
  static const Color iosGrayDark6 = Color(0xFF1C1C1E);

  static const Color iosBackgroundLight = Color(0xFFF2F2F7);
  static const Color iosBackgroundDark = Color(0xFF000000);
  static const Color iosGroupedBgLight = Color(0xFFF2F2F7);
  static const Color iosGroupedBgDark = Color(0xFF1C1C1E);

  static const Color iosCardLight = Color(0xFFFFFFFF);
  static const Color iosCardDark = Color(0xFF2C2C2E);

  static const Color iosSeparatorLight = Color(0xFF3C3C43);
  static const Color iosSeparatorDark = Color(0xFF545458);
}

class AppTheme {
  static ThemeData light({double fontScale = 1.0}) {
    return _build(fontScale, Brightness.light);
  }

  static ThemeData dark({double fontScale = 1.0}) {
    return _build(fontScale, Brightness.dark);
  }

  static ThemeData _build(double scale, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final colorScheme = isDark
        ? ColorScheme.dark(
            primary: AppColors.iosDarkBlue,
            secondary: AppColors.iosPurple,
            tertiary: AppColors.iosGreen,
            surface: AppColors.iosBackgroundDark,
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onSurface: Colors.white,
          )
        : ColorScheme.light(
            primary: AppColors.iosBlue,
            secondary: AppColors.iosIndigo,
            tertiary: AppColors.iosOrange,
            surface: AppColors.iosBackgroundLight,
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onSurface: Colors.black,
          );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: _textTheme(scale),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        backgroundColor: isDark ? AppColors.iosBackgroundDark : AppColors.iosCardLight,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 28 * scale,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
          letterSpacing: -0.5,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? AppColors.iosGrayDark5 : AppColors.iosCardLight,
        indicatorColor: colorScheme.primary.withValues(alpha: 0.15),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.inter(fontSize: 10 * scale, fontWeight: FontWeight.w600, color: colorScheme.primary);
          }
          return GoogleFonts.inter(fontSize: 10 * scale, fontWeight: FontWeight.w500, color: AppColors.iosGray);
        }),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDark ? AppColors.iosGrayDark5 : AppColors.iosCardLight,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: AppColors.iosGray,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: GoogleFonts.inter(fontSize: 10 * scale, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 10 * scale, fontWeight: FontWeight.w500),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.iosGrayDark5 : AppColors.iosGray6,
        hintStyle: GoogleFonts.inter(
          color: AppColors.iosGray,
          fontSize: 17 * scale,
          fontWeight: FontWeight.w400,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary.withValues(alpha: 0.3), width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 17 * scale,
            fontWeight: FontWeight.w600,
          ),
          elevation: 0,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: isDark ? AppColors.iosCardDark : AppColors.iosCardLight,
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: GoogleFonts.inter(fontSize: 14 * scale, fontWeight: FontWeight.w500),
      ),
      dividerTheme: DividerThemeData(
        color: isDark ? AppColors.iosSeparatorDark.withValues(alpha: 0.3) : AppColors.iosSeparatorLight.withValues(alpha: 0.12),
        thickness: 0.5,
        space: 0,
      ),
      scaffoldBackgroundColor: isDark ? AppColors.iosGroupedBgDark : AppColors.iosGroupedBgLight,
    );
  }

  static TextTheme _textTheme(double scale) {
    return TextTheme(
      displayLarge: GoogleFonts.inter(fontSize: 34 * scale, fontWeight: FontWeight.w700, letterSpacing: -0.5),
      displayMedium: GoogleFonts.inter(fontSize: 28 * scale, fontWeight: FontWeight.w700, letterSpacing: -0.5),
      displaySmall: GoogleFonts.inter(fontSize: 24 * scale, fontWeight: FontWeight.w700),
      headlineLarge: GoogleFonts.inter(fontSize: 22 * scale, fontWeight: FontWeight.w700),
      headlineMedium: GoogleFonts.inter(fontSize: 20 * scale, fontWeight: FontWeight.w600),
      headlineSmall: GoogleFonts.inter(fontSize: 18 * scale, fontWeight: FontWeight.w600),
      titleLarge: GoogleFonts.inter(fontSize: 17 * scale, fontWeight: FontWeight.w600),
      titleMedium: GoogleFonts.inter(fontSize: 15 * scale, fontWeight: FontWeight.w600),
      titleSmall: GoogleFonts.inter(fontSize: 13 * scale, fontWeight: FontWeight.w600),
      bodyLarge: GoogleFonts.inter(fontSize: 17 * scale, fontWeight: FontWeight.w400, height: 1.4),
      bodyMedium: GoogleFonts.inter(fontSize: 15 * scale, fontWeight: FontWeight.w400, height: 1.35),
      bodySmall: GoogleFonts.inter(fontSize: 13 * scale, fontWeight: FontWeight.w400, height: 1.3),
      labelLarge: GoogleFonts.inter(fontSize: 15 * scale, fontWeight: FontWeight.w600),
      labelMedium: GoogleFonts.inter(fontSize: 13 * scale, fontWeight: FontWeight.w600),
      labelSmall: GoogleFonts.inter(fontSize: 11 * scale, fontWeight: FontWeight.w500),
    );
  }
}
