import 'package:avium/core/theme/app_colors.dart';
import 'package:avium/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppTheme', () {
    test('light theme matches naviary palette', () {
      final colorScheme = AppTheme.light.colorScheme;

      expect(colorScheme.brightness, Brightness.light);
      expect(colorScheme.primary, AppColors.naviary500);
      expect(colorScheme.secondary, AppColors.olive500);
      expect(colorScheme.tertiary, AppColors.amber500);
      expect(colorScheme.error, AppColors.error500);
      expect(colorScheme.surface, AppColors.lightBackground);
      expect(colorScheme.onSurface, AppColors.lightForeground);
    });

    test('dark theme matches naviary palette', () {
      final colorScheme = AppTheme.dark.colorScheme;

      expect(colorScheme.brightness, Brightness.dark);
      expect(colorScheme.primary, AppColors.naviary400);
      expect(colorScheme.secondary, AppColors.olive400);
      expect(colorScheme.tertiary, AppColors.amber400);
      expect(colorScheme.error, AppColors.error500);
      expect(colorScheme.surface, AppColors.darkBackground);
      expect(colorScheme.onSurface, AppColors.darkForeground);
    });
  });
}
