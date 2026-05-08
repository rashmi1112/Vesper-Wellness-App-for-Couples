import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);

  static const EdgeInsets horizontalXs = EdgeInsets.symmetric(horizontal: xs);
  static const EdgeInsets horizontalSm = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets horizontalMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets horizontalLg = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets horizontalXl = EdgeInsets.symmetric(horizontal: xl);

  static const EdgeInsets verticalXs = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets verticalSm = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets verticalMd = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets verticalLg = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets verticalXl = EdgeInsets.symmetric(vertical: xl);
}

class AppRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
}

extension TextStyleContext on BuildContext {
  TextTheme get textStyles => Theme.of(this).textTheme;
}

extension TextStyleExtensions on TextStyle {
  TextStyle get bold => copyWith(fontWeight: FontWeight.bold);
  TextStyle get semiBold => copyWith(fontWeight: FontWeight.w600);
  TextStyle get medium => copyWith(fontWeight: FontWeight.w500);
  TextStyle get normal => copyWith(fontWeight: FontWeight.w400);
  TextStyle get light => copyWith(fontWeight: FontWeight.w300);
  TextStyle withColor(Color color) => copyWith(color: color);
  TextStyle withSize(double size) => copyWith(fontSize: size);
}

class VesperColors {
  // Primary - Deep Berry
  static const Color primary = Color(0xFF6D2E46);
  static const Color primaryLight = Color(0xFF8B4A64);
  static const Color primaryDark = Color(0xFF4F1F32);

  // Accent - Soft Pink/Mauve
  static const Color accent = Color(0xFFE8C4C4);
  static const Color accentLight = Color(0xFFF5E0E0);
  static const Color accentDark = Color(0xFFD4A3A3);

  // Feature accents
  static const Color fightBetterTeal = Color(0xFF028090);
  static const Color growTogetherSage = Color(0xFF84B59F);
  static const Color loveOutLoudGold = Color(0xFFC9974A);
  
  // Background
  static const Color background = Color(0xFFFDF6F0);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFFAEDE5);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF2D1F24);
  static const Color textSecondary = Color(0xFF6B5A60);
  static const Color textLight = Color(0xFF9C8A91);
  
  // Status Colors
  static const Color success = Color(0xFF5B8A72);
  static const Color warning = Color(0xFFD4A574);
  static const Color error = Color(0xFFC75D5D);
  
  // Dark Mode Colors
  static const Color darkBackground = Color(0xFF1A1517);
  static const Color darkSurface = Color(0xFF2D2528);
  static const Color darkSurfaceVariant = Color(0xFF3D3235);
  static const Color darkTextPrimary = Color(0xFFF5EDE9);
  static const Color darkTextSecondary = Color(0xFFB8A8AD);
  static const Color darkAccent = Color(0xFFE8C4C4);
  static const Color darkPrimary = Color(0xFFD4A3A3);
}

class FontSizes {
  static const double displayLarge = 48.0;
  static const double displayMedium = 36.0;
  static const double displaySmall = 28.0;
  static const double headlineLarge = 32.0;
  static const double headlineMedium = 26.0;
  static const double headlineSmall = 22.0;
  static const double titleLarge = 20.0;
  static const double titleMedium = 16.0;
  static const double titleSmall = 14.0;
  static const double labelLarge = 14.0;
  static const double labelMedium = 12.0;
  static const double labelSmall = 11.0;
  static const double bodyLarge = 16.0;
  static const double bodyMedium = 14.0;
  static const double bodySmall = 12.0;
}

ThemeData get lightTheme => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.light(
    primary: VesperColors.primary,
    onPrimary: Colors.white,
    primaryContainer: VesperColors.accentLight,
    onPrimaryContainer: VesperColors.primaryDark,
    secondary: VesperColors.accent,
    onSecondary: VesperColors.textPrimary,
    tertiary: VesperColors.primaryLight,
    onTertiary: Colors.white,
    error: VesperColors.error,
    onError: Colors.white,
    surface: VesperColors.surface,
    onSurface: VesperColors.textPrimary,
    surfaceContainerHighest: VesperColors.surfaceVariant,
    onSurfaceVariant: VesperColors.textSecondary,
    outline: VesperColors.accentDark,
  ),
  brightness: Brightness.light,
  scaffoldBackgroundColor: VesperColors.background,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    foregroundColor: VesperColors.textPrimary,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: true,
  ),
  cardTheme: CardThemeData(
    elevation: 0,
    color: VesperColors.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: VesperColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: VesperColors.primary,
      side: const BorderSide(color: VesperColors.primary, width: 1.5),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: VesperColors.primary,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: VesperColors.surface,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(color: VesperColors.accent.withValues(alpha: 0.5)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(color: VesperColors.accent.withValues(alpha: 0.5)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: const BorderSide(color: VesperColors.primary, width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
  ),
  textTheme: _buildTextTheme(Brightness.light),
  splashFactory: NoSplash.splashFactory,
  highlightColor: Colors.transparent,
);

ThemeData get darkTheme => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.dark(
    primary: VesperColors.darkPrimary,
    onPrimary: VesperColors.darkBackground,
    primaryContainer: VesperColors.darkSurfaceVariant,
    onPrimaryContainer: VesperColors.darkAccent,
    secondary: VesperColors.darkAccent,
    onSecondary: VesperColors.darkBackground,
    tertiary: VesperColors.primaryLight,
    onTertiary: Colors.white,
    error: VesperColors.error,
    onError: Colors.white,
    surface: VesperColors.darkSurface,
    onSurface: VesperColors.darkTextPrimary,
    surfaceContainerHighest: VesperColors.darkSurfaceVariant,
    onSurfaceVariant: VesperColors.darkTextSecondary,
    outline: VesperColors.darkSurfaceVariant,
  ),
  brightness: Brightness.dark,
  scaffoldBackgroundColor: VesperColors.darkBackground,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    foregroundColor: VesperColors.darkTextPrimary,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: true,
  ),
  cardTheme: CardThemeData(
    elevation: 0,
    color: VesperColors.darkSurface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: VesperColors.darkPrimary,
      foregroundColor: VesperColors.darkBackground,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: VesperColors.darkPrimary,
      side: const BorderSide(color: VesperColors.darkPrimary, width: 1.5),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: VesperColors.darkSurfaceVariant,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(color: VesperColors.darkAccent.withValues(alpha: 0.3)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(color: VesperColors.darkAccent.withValues(alpha: 0.3)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: const BorderSide(color: VesperColors.darkPrimary, width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
  ),
  textTheme: _buildTextTheme(Brightness.dark),
  splashFactory: NoSplash.splashFactory,
  highlightColor: Colors.transparent,
);

TextTheme _buildTextTheme(Brightness brightness) {
  final Color textColor = brightness == Brightness.light 
      ? VesperColors.textPrimary 
      : VesperColors.darkTextPrimary;
  final Color secondaryTextColor = brightness == Brightness.light 
      ? VesperColors.textSecondary 
      : VesperColors.darkTextSecondary;
  
  return TextTheme(
    displayLarge: GoogleFonts.playfairDisplay(
      fontSize: FontSizes.displayLarge,
      fontWeight: FontWeight.w600,
      color: textColor,
      letterSpacing: -0.5,
    ),
    displayMedium: GoogleFonts.playfairDisplay(
      fontSize: FontSizes.displayMedium,
      fontWeight: FontWeight.w600,
      color: textColor,
    ),
    displaySmall: GoogleFonts.playfairDisplay(
      fontSize: FontSizes.displaySmall,
      fontWeight: FontWeight.w500,
      color: textColor,
    ),
    headlineLarge: GoogleFonts.playfairDisplay(
      fontSize: FontSizes.headlineLarge,
      fontWeight: FontWeight.w600,
      color: textColor,
      letterSpacing: -0.3,
    ),
    headlineMedium: GoogleFonts.playfairDisplay(
      fontSize: FontSizes.headlineMedium,
      fontWeight: FontWeight.w600,
      color: textColor,
    ),
    headlineSmall: GoogleFonts.playfairDisplay(
      fontSize: FontSizes.headlineSmall,
      fontWeight: FontWeight.w500,
      color: textColor,
    ),
    titleLarge: GoogleFonts.playfairDisplay(
      fontSize: FontSizes.titleLarge,
      fontWeight: FontWeight.w600,
      color: textColor,
    ),
    titleMedium: GoogleFonts.inter(
      fontSize: FontSizes.titleMedium,
      fontWeight: FontWeight.w600,
      color: textColor,
    ),
    titleSmall: GoogleFonts.inter(
      fontSize: FontSizes.titleSmall,
      fontWeight: FontWeight.w500,
      color: secondaryTextColor,
    ),
    labelLarge: GoogleFonts.inter(
      fontSize: FontSizes.labelLarge,
      fontWeight: FontWeight.w600,
      color: textColor,
      letterSpacing: 0.5,
    ),
    labelMedium: GoogleFonts.inter(
      fontSize: FontSizes.labelMedium,
      fontWeight: FontWeight.w500,
      color: secondaryTextColor,
      letterSpacing: 0.4,
    ),
    labelSmall: GoogleFonts.inter(
      fontSize: FontSizes.labelSmall,
      fontWeight: FontWeight.w500,
      color: secondaryTextColor,
      letterSpacing: 0.3,
    ),
    bodyLarge: GoogleFonts.inter(
      fontSize: FontSizes.bodyLarge,
      fontWeight: FontWeight.w400,
      color: textColor,
      height: 1.5,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: FontSizes.bodyMedium,
      fontWeight: FontWeight.w400,
      color: secondaryTextColor,
      height: 1.5,
    ),
    bodySmall: GoogleFonts.inter(
      fontSize: FontSizes.bodySmall,
      fontWeight: FontWeight.w400,
      color: secondaryTextColor,
      height: 1.4,
    ),
  );
}
