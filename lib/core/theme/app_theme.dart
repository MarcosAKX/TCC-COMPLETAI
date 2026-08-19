import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color background = Color(0xFFF6F7F9);
  static const Color discoveryBackground = Color(0xFFE8EEFF);
  static const Color authBackground = discoveryBackground;
  static const Color card = Color(0xFFFFFFFF);
  static const Color elevatedSurface = Color(0xFFF3F4F6);
  static const Color input = Color(0xFFFFFFFF);
  static const Color primary = Color(0xFF315EFB);
  static const Color primaryInteractive = primary;
  static const Color primarySurface = Color(0xFFEDF1FF);
  static const Color price = Color(0xFF3559C7);
  static const Color priceSurface = Color(0xFFF8FAFF);
  static const Color savings = Color(0xFF079B68);
  static const Color savingsSurface = Color(0xFFE7F7F0);
  static const Color green = Color(0xFF237A47);
  static const Color rating = Color(0xFFD88710);
  static const Color ratingSurface = Color(0xFFFFF5E4);
  static const Color error = Color(0xFFC9362B);
  static const Color textLight = Color(0xFF1B1D22);
  static const Color textMuted = Color(0xFF747A85);
  static const Color outline = Color(0xFFE7E9ED);
  static const Color successSurface = Color(0xFFEAF5EE);
  static const Color onPrimaryMuted = Color(0xFFE8EDFF);

  static const ColorScheme lightColorScheme = ColorScheme.light(
    primary: primary,
    onPrimary: Colors.white,
    primaryContainer: primarySurface,
    onPrimaryContainer: primary,
    secondary: primary,
    onSecondary: Colors.white,
    secondaryContainer: primarySurface,
    onSecondaryContainer: primary,
    tertiary: savings,
    onTertiary: Colors.white,
    tertiaryContainer: savingsSurface,
    onTertiaryContainer: Color(0xFF075C3D),
    error: error,
    onError: Colors.white,
    surface: card,
    onSurface: textLight,
    onSurfaceVariant: textMuted,
    outline: outline,
  );

  static const ColorScheme darkColorScheme = lightColorScheme;

  static TextTheme _buildTextTheme(TextTheme base) {
    final manrope = GoogleFonts.manropeTextTheme(
      base,
    ).apply(bodyColor: textLight, displayColor: textLight);
    return manrope.copyWith(
      headlineMedium: manrope.headlineMedium?.copyWith(
        fontSize: 22,
        height: 1.2,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: manrope.titleLarge?.copyWith(
        fontSize: 18,
        height: 1.25,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: manrope.titleMedium?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: manrope.bodyLarge?.copyWith(fontSize: 16, height: 1.45),
      bodyMedium: manrope.bodyMedium?.copyWith(
        color: textMuted,
        fontSize: 15,
        height: 1.45,
      ),
      labelLarge: manrope.labelLarge?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      labelSmall: manrope.labelSmall?.copyWith(
        color: textMuted,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  static TextStyle priceStyle({
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
  }) {
    return GoogleFonts.manrope(
      fontSize: fontSize,
      height: 1.05,
      fontWeight: fontWeight,
      color: color,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  static ThemeData get lightTheme {
    final textTheme = _buildTextTheme(const TextTheme());
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: lightColorScheme,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        foregroundColor: textLight,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: outline),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: input,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: const TextStyle(color: textMuted),
        labelStyle: const TextStyle(color: textMuted),
        errorStyle: const TextStyle(color: error, fontWeight: FontWeight.w600),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryInteractive, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(48, 52),
          backgroundColor: primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: primary.withValues(alpha: 0.42),
          disabledForegroundColor: Colors.white70,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: textTheme.labelLarge?.copyWith(color: Colors.white),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: card,
        selectedColor: lightColorScheme.primaryContainer,
        side: const BorderSide(color: outline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        labelStyle: textTheme.labelLarge!.copyWith(
          color: textMuted,
          fontWeight: FontWeight.w600,
        ),
        secondaryLabelStyle: textTheme.labelLarge!.copyWith(
          color: primary,
          fontWeight: FontWeight.w700,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: primary,
        contentTextStyle: const TextStyle(color: Colors.white),
        actionTextColor: onPrimaryMuted,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? Colors.white : textMuted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? savings : outline,
        ),
      ),
    );
  }

  static ThemeData get darkTheme => lightTheme;
}
