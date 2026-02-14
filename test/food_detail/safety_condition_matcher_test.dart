import 'package:avium/core/types/avium_types.dart';
import 'package:avium/data/models/safety_condition.dart';
import 'package:avium/features/food_detail/domain/safety_condition_matcher.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const matcher = SafetyConditionMatcher();

  final conditions = <SafetyCondition>[
    const SafetyCondition(
      labelKo: '과육(생)',
      part: PartType.flesh,
      prep: PrepType.raw,
      level: SafetyLevel.safe,
      noteKo: '과육은 안전',
    ),
    const SafetyCondition(
      labelKo: '씨앗(any)',
      part: PartType.seeds,
      prep: PrepType.any,
      level: SafetyLevel.danger,
      noteKo: '씨앗 금지',
    ),
    const SafetyCondition(
      labelKo: '씨앗(any) 보조',
      part: PartType.seeds,
      prep: PrepType.any,
      level: SafetyLevel.caution,
      noteKo: '씨앗 주의',
    ),
  ];

  test('keeps representative level for incomplete selection', () {
    final result = matcher.match(
      representativeLevel: SafetyLevel.caution,
      conditions: conditions,
      selectedPart: PartType.seeds,
      selectedPrep: null,
    );

    expect(result.isComplete, isFalse);
    expect(result.resolvedLevel, SafetyLevel.caution);
  });

  test('resolves by priority when selection is complete', () {
    final result = matcher.match(
      representativeLevel: SafetyLevel.caution,
      conditions: conditions,
      selectedPart: PartType.flesh,
      selectedPrep: PrepType.raw,
    );

    expect(result.isComplete, isTrue);
    expect(result.resolvedLevel, SafetyLevel.safe);
  });

  test('chooses conservative level for ambiguous matches', () {
    final result = matcher.match(
      representativeLevel: SafetyLevel.caution,
      conditions: conditions,
      selectedPart: PartType.seeds,
      selectedPrep: PrepType.raw,
    );

    expect(result.isAmbiguous, isTrue);
    expect(result.resolvedLevel, SafetyLevel.danger);
  });

  test('falls back to representative level when no match found', () {
    final result = matcher.match(
      representativeLevel: SafetyLevel.caution,
      conditions: conditions,
      selectedPart: PartType.peel,
      selectedPrep: PrepType.juice,
    );

    expect(result.isComplete, isTrue);
    expect(result.resolvedLevel, SafetyLevel.caution);
  });
}
