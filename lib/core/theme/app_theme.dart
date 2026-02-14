import 'package:flutter/material.dart';

final class AppTheme {
  const AppTheme._();

  static ThemeData get light => _theme(Brightness.light);

  static ThemeData get dark => _theme(Brightness.dark);

  static ThemeData _theme(Brightness brightness) {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF0D47A1),
        brightness: brightness,
      ),
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
}
