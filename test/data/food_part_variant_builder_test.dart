import 'package:avium/core/types/avium_types.dart';
import 'package:avium/data/models/confusable_item.dart';
import 'package:avium/data/models/emergency_profile.dart';
import 'package:avium/data/models/food_db.dart';
import 'package:avium/data/models/food_item.dart';
import 'package:avium/data/models/portion_guide.dart';
import 'package:avium/data/models/safety_condition.dart';
import 'package:avium/data/models/source_reference.dart';
import 'package:avium/data/transform/food_part_variant_builder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const builder = FoodPartVariantBuilder();

  test('keeps foods without condition rules as-is', () {
    final db = FoodDb(
      meta: const FoodDbMeta(
        dataVersion: '1.2.0',
        reviewedAt: '2026-02-15',
        distributionPolicyKo: <String>[],
      ),
      foods: <FoodItem>[_safeFood],
    );

    final expanded = builder.build(db);

    expect(expanded.foods, hasLength(1));
    expect(expanded.foods.first.id, _safeFood.id);
    expect(expanded.foods.first.nameKo, _safeFood.nameKo);
  });

  test('expands one food into part-based entries', () {
    final db = FoodDb(
      meta: const FoodDbMeta(
        dataVersion: '1.2.0',
        reviewedAt: '2026-02-15',
        distributionPolicyKo: <String>[],
      ),
      foods: <FoodItem>[_appleLikeFood],
    );

    final expanded = builder.build(db);
    final ids = expanded.foods.map((food) => food.id).toList(growable: false);
    final names =
        expanded.foods.map((food) => food.nameKo).toList(growable: false);

    expect(ids, containsAll(<String>['foodApple__flesh', 'foodApple__seeds']));
    expect(names, containsAll(<String>['사과 (과육)', '사과 (씨앗)']));

    final flesh =
        expanded.foods.firstWhere((food) => food.id.endsWith('flesh'));
    final seeds =
        expanded.foods.firstWhere((food) => food.id.endsWith('seeds'));

    expect(flesh.safetyLevel, SafetyLevel.safe);
    expect(seeds.safetyLevel, SafetyLevel.danger);
    expect(flesh.searchTokens, contains('사과 과육'));
    expect(seeds.searchTokens, contains('사과 씨앗'));
    expect(seeds.portionsKo.frequency, '급여 금지');
    expect(flesh.sources.single.title, 'flesh source');
    expect(seeds.sources.single.title, 'seed source');
  });
}

final FoodItem _safeFood = FoodItem(
  id: 'foodBanana',
  nameKo: '바나나',
  nameEn: 'Banana',
  aliases: const <String>['banana'],
  category: 'fruit',
  foodType: FoodType.whole,
  safetyLevel: SafetyLevel.safe,
  oneLinerKo: '테스트',
  reasonKo: const <String>['테스트'],
  riskNotesKo: const <String>[],
  safetyConditions: const <SafetyCondition>[],
  portionsKo: const PortionGuide(
    allowedParts: <String>['과육'],
    avoidParts: <String>['껍질'],
    frequency: '가끔 소량',
    notes: <String>[],
    examplesKo: <String>[],
  ),
  confusables: const <ConfusableItem>[],
  evidenceLevel: EvidenceLevel.low,
  reviewedAt: '2026-02-15',
  sources: const <SourceReference>[
    SourceReference(type: 'test', title: 'test', year: 2026),
  ],
  searchTokens: const <String>['바나나'],
  emergency: const EmergencyProfile(
    baseRisk: EmergencyRiskLevel.low,
    whatToDoKo: <String>[],
    watchForKo: <String>[],
    escalationTriggersKo: <String>[],
  ),
);

final FoodItem _appleLikeFood = FoodItem(
  id: 'foodApple',
  nameKo: '사과',
  nameEn: 'Apple',
  aliases: const <String>['apple', '사과'],
  category: 'fruit',
  foodType: FoodType.whole,
  safetyLevel: SafetyLevel.caution,
  oneLinerKo: '과육은 상대적으로 안전, 씨앗은 위험',
  reasonKo: const <String>['원본 이유'],
  riskNotesKo: const <String>['원본 주의'],
  safetyConditions: const <SafetyCondition>[
    SafetyCondition(
      labelKo: '과육(생)',
      part: PartType.flesh,
      prep: PrepType.raw,
      level: SafetyLevel.safe,
      noteKo: '과육은 소량 급여 가능',
      sourceIndexes: <int>[0],
    ),
    SafetyCondition(
      labelKo: '씨앗(모든 형태)',
      part: PartType.seeds,
      prep: PrepType.any,
      level: SafetyLevel.danger,
      noteKo: '씨앗은 급여 금지',
      sourceIndexes: <int>[1],
    ),
  ],
  portionsKo: const PortionGuide(
    allowedParts: <String>['과육'],
    avoidParts: <String>['씨앗', '심지'],
    frequency: '가끔 소량',
    notes: <String>[],
    examplesKo: <String>[],
  ),
  confusables: const <ConfusableItem>[],
  evidenceLevel: EvidenceLevel.medium,
  reviewedAt: '2026-02-15',
  sources: const <SourceReference>[
    SourceReference(type: 'test', title: 'flesh source', year: 2026),
    SourceReference(type: 'test', title: 'seed source', year: 2026),
  ],
  searchTokens: const <String>['사과', 'apple'],
  emergency: const EmergencyProfile(
    baseRisk: EmergencyRiskLevel.medium,
    whatToDoKo: <String>[],
    watchForKo: <String>[],
    escalationTriggersKo: <String>[],
  ),
);
