import '../../../core/types/avium_types.dart';
import '../../../data/models/safety_condition.dart';

class SafetyConditionMatchResult {
  const SafetyConditionMatchResult({
    required this.resolvedLevel,
    required this.isComplete,
    required this.isAmbiguous,
    required this.note,
  });

  final SafetyLevel resolvedLevel;
  final bool isComplete;
  final bool isAmbiguous;
  final String note;
}

class SafetyConditionMatcher {
  const SafetyConditionMatcher();

  SafetyConditionMatchResult match({
    required SafetyLevel representativeLevel,
    required List<SafetyCondition> conditions,
    required PartType? selectedPart,
    required PrepType? selectedPrep,
  }) {
    final isComplete = selectedPart != null && selectedPrep != null;
    if (!isComplete) {
      final partLabel = selectedPart?.name ?? '미선택';
      final prepLabel = selectedPrep?.name ?? '미선택';
      return SafetyConditionMatchResult(
        resolvedLevel: representativeLevel,
        isComplete: false,
        isAmbiguous: false,
        note: '현재 선택: $partLabel / $prepLabel',
      );
    }

    final matches = _findByPriority(
      conditions: conditions,
      selectedPart: selectedPart,
      selectedPrep: selectedPrep,
    );

    if (matches.isEmpty) {
      return SafetyConditionMatchResult(
        resolvedLevel: representativeLevel,
        isComplete: true,
        isAmbiguous: false,
        note: '조건 미확정: 대표 배지를 유지합니다.',
      );
    }

    final resolved = _maxSeverity(matches.map((item) => item.level));
    final distinctLevelCount = matches.map((item) => item.level).toSet().length;

    return SafetyConditionMatchResult(
      resolvedLevel: resolved,
      isComplete: true,
      isAmbiguous: distinctLevelCount > 1,
      note: matches.first.noteKo,
    );
  }

  List<SafetyCondition> _findByPriority({
    required List<SafetyCondition> conditions,
    required PartType selectedPart,
    required PrepType selectedPrep,
  }) {
    final exact = conditions
        .where(
          (item) => item.part == selectedPart && item.prep == selectedPrep,
        )
        .toList();
    if (exact.isNotEmpty) {
      return exact;
    }

    final partAny = conditions
        .where(
          (item) => item.part == selectedPart && item.prep == PrepType.any,
        )
        .toList();
    if (partAny.isNotEmpty) {
      return partAny;
    }

    final unknownPrep = conditions
        .where(
          (item) => item.part == PartType.unknown && item.prep == selectedPrep,
        )
        .toList();
    if (unknownPrep.isNotEmpty) {
      return unknownPrep;
    }

    return conditions
        .where(
          (item) => item.part == PartType.unknown && item.prep == PrepType.any,
        )
        .toList();
  }

  SafetyLevel _maxSeverity(Iterable<SafetyLevel> levels) {
    var current = SafetyLevel.safe;
    for (final level in levels) {
      if (level.severity > current.severity) {
        current = level;
      }
    }
    return current;
  }
}
