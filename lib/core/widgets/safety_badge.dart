import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../types/avium_types.dart';

class SafetyBadge extends StatelessWidget {
  const SafetyBadge({required this.level, super.key, this.showLabel = true});

  final SafetyLevel level;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (level) {
      SafetyLevel.safe => (Icons.shield_outlined, AppColors.success500),
      SafetyLevel.caution => (
          Icons.warning_amber_rounded,
          AppColors.warning500,
        ),
      SafetyLevel.danger => (Icons.dangerous_outlined, AppColors.error500),
    };

    final label = level.label;
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Semantics(
      label: '안전도 $label',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 16, color: color),
            if (showLabel) ...<Widget>[
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
