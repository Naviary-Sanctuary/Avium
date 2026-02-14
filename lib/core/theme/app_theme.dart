import 'package:flutter/material.dart';

import 'app_colors.dart';

final class AppTheme {
  const AppTheme._();

  static ThemeData get light => _theme(Brightness.light);

  static ThemeData get dark => _theme(Brightness.dark);

  static ThemeData _theme(Brightness brightness) {
    final colorScheme =
        brightness == Brightness.light ? _lightColorScheme : _darkColorScheme;

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
    );

    return base.copyWith(
      cardTheme: CardThemeData(
        elevation: 6,
        shadowColor: base.colorScheme.shadow.withValues(alpha: 0.2),
      ),
      chipTheme: base.chipTheme.copyWith(
        side: BorderSide(
          color: base.colorScheme.outlineVariant,
        ),
      ),
    );
  }

  static const ColorScheme _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.naviary500,
    onPrimary: Color(0xFFF9FAFB),
    primaryContainer: AppColors.naviary100,
    onPrimaryContainer: AppColors.naviary950,
    secondary: AppColors.olive500,
    onSecondary: Color(0xFFF9FAFB),
    secondaryContainer: AppColors.olive200,
    onSecondaryContainer: AppColors.olive900,
    tertiary: AppColors.amber500,
    onTertiary: AppColors.olive900,
    tertiaryContainer: AppColors.amber100,
    onTertiaryContainer: AppColors.amber900,
    error: AppColors.error500,
    onError: Color(0xFFF9FAFB),
    errorContainer: Color(0xFFFFE0E0),
    onErrorContainer: Color(0xFF800000),
    surface: AppColors.lightBackground,
    onSurface: AppColors.lightForeground,
    surfaceContainerHighest: AppColors.lightMuted,
    onSurfaceVariant: AppColors.lightMutedForeground,
    outline: AppColors.lightBorder,
    outlineVariant: AppColors.lightBorder,
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: Color(0xFF241F1A),
    onInverseSurface: Color(0xFFF9FAFB),
    inversePrimary: AppColors.naviary400,
  );

  static const ColorScheme _darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.naviary400,
    onPrimary: Color(0xFFF9FAFB),
    primaryContainer: AppColors.naviary800,
    onPrimaryContainer: AppColors.naviary100,
    secondary: AppColors.olive400,
    onSecondary: AppColors.olive950,
    secondaryContainer: AppColors.olive800,
    onSecondaryContainer: AppColors.olive100,
    tertiary: AppColors.amber400,
    onTertiary: AppColors.olive950,
    tertiaryContainer: AppColors.amber900,
    onTertiaryContainer: AppColors.amber100,
    error: AppColors.error500,
    onError: Color(0xFFF9FAFB),
    errorContainer: Color(0xFF800000),
    onErrorContainer: Color(0xFFFFE0E0),
    surface: AppColors.darkBackground,
    onSurface: AppColors.darkForeground,
    surfaceContainerHighest: AppColors.darkMuted,
    onSurfaceVariant: AppColors.darkMutedForeground,
    outline: AppColors.darkBorder,
    outlineVariant: AppColors.darkBorder,
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: Color(0xFFF9FAFB),
    onInverseSurface: Color(0xFF241F1A),
    inversePrimary: AppColors.naviary500,
  );
}
