import 'package:flutter/material.dart';

class AppColors {
  static const Color red = Color(0xFFDC2626);

  // Primary brand colors - Enhanced from your logo
  static const Color primary = Color(
    0xFF2B4CB8,
  ); // Deeper, more sophisticated blue
  static const Color primaryLight = Color(0xFFE3EAFF); // Light blue tint
  static const Color primaryDark = Color(
    0xFF1A3491,
  ); // Darker blue for dark theme
  static const Color blue = Color(
    0xFF6DB1ED,
  ); // Darker blue for dark theme

  static const Color secondary = Color(0xFFFFB627); // Refined gold from logo
  static const Color secondaryLight = Color(0xFFFFF4D6); // Light gold tint
  static const Color secondaryDark = Color(
    0xFFE69A00,
  ); // Darker gold for dark theme

  static const Color accent = Color(0xFFFFD700); // Premium gold accent
  static const Color accentLight = Color(0xFFFFF9C4); // Light accent

  // Neutral colors - More sophisticated palette
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF6B7280);
  static const Color lightGrey = Color(0xFFF3F4F6);
  static const Color darkGrey = Color(0xFF374151);
  static const Color disabled = Color(0xFFD1D5DB);

  // Status colors - Professional palette
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color errorDark = Color(0xFFDC2626);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);

  // Text colors - Enhanced hierarchy
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textLight = Color(0xFF9CA3AF);
  static const Color textMuted = Color(0xFFD1D5DB);

  // Dark theme text colors
  static const Color darkTextPrimary = Color(0xFFF9FAFB);
  static const Color darkTextSecondary = Color(0xFFD1D5DB);
  static const Color darkTextLight = Color(0xFF9CA3AF);

  // Background colors - Refined palette
  static const Color background = Color(0xFFFDFDFD);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF8FAFC);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // Dark theme backgrounds
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkSurfaceVariant = Color(0xFF334155);

  // Interactive elements
  static const Color inputFill = Color(0xFFF8FAFC);
  static const Color chipBackground = Color(0xFFF1F5F9);
  static const Color progressTrack = Color(0xFFE2E8F0);
  static const Color trackInactive = Color(0xFFCBD5E1);

  // Borders and dividers
  static const Color outline = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFF1F5F9);
  static const Color darkOutline = Color(0xFF475569);

  // Shadows and elevation
  static const Color shadowColor = Color(0x1A000000);
  static const Color iconColor = Color(0xFF64748B);

  // Gradient colors - For premium effects
  static const List<Color> primaryGradient = [
    Color(0xFF2B4CB8),
    Color(0xFF3B5CCC),
  ];

  static const List<Color> secondaryGradient = [
    Color(0xFFFFB627),
    Color(0xFFFFD700),
  ];

  static const List<Color> shimmerGradient = [
    Color(0xFFFDFDFD),
    Color(0xFFFDFDFD),
    Color(0xFFFDFDFD),
  ];

  // Brand-specific combinations
  static const Color brandCombo1 = Color(0xFFF0F4FF); // Very light blue
  static const Color brandCombo2 = Color(0xFFFFFBF0); // Very light gold

  // Helper methods for creating color variations
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  static Color lighten(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  static Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  // Semantic color getters
  static Color get primaryContainer => primaryLight;
  static Color get onPrimaryContainer => primary;
  static Color get secondaryContainer => secondaryLight;
  static Color get onSecondaryContainer => secondary;
  static Color get errorContainer => errorLight;
  static Color get onErrorContainer => error;
  static Color get successContainer => successLight;
  static Color get onSuccessContainer => success;
  static Color get warningContainer => warningLight;
  static Color get onWarningContainer => warning;
  static Color get infoContainer => infoLight;
  static Color get onInfoContainer => info;
}