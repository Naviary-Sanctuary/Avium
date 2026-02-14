import 'package:avium/core/state/app_state.dart';
import 'package:avium/core/state/app_state_scope.dart';
import 'package:avium/core/types/avium_types.dart';
import 'package:avium/data/models/confusable_item.dart';
import 'package:avium/data/models/emergency_profile.dart';
import 'package:avium/data/models/food_db.dart';
import 'package:avium/data/models/food_item.dart';
import 'package:avium/data/models/portion_guide.dart';
import 'package:avium/data/models/safety_condition.dart';
import 'package:avium/data/models/source_reference.dart';
import 'package:avium/data/repositories/food_repository.dart';
import 'package:avium/features/food_detail/presentation/food_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows mixed warning and incomplete-selection warning', (
    WidgetTester tester,
  ) async {
    final appState = AppState(repository: _FakeFoodRepository());
    await appState.initialize();

    await tester.pumpWidget(
      AppStateScope(
        state: appState,
        child: const MaterialApp(
          home: FoodDetailScreen(foodId: 'foodTestMixed'),
        ),
      ),
    );

    expect(find.text('혼합/가공식품 주의'), findsOneWidget);
    expect(find.text('조건 선택이 완전하지 않아 보수적으로 표시됩니다.'), findsOneWidget);
  });
}

class _FakeFoodRepository implements FoodRepository {
  @override
  FoodItem? getById(String id) {
    for (final food in _db.foods) {
      if (food.id == id) {
        return food;
      }
    }
    return null;
  }

  @override
  Future<FoodDb> loadDb() async => _db;

  @override
  List<FoodItem> search(String query) => _db.foods;

  @override
  List<String> suggest(String query, {int limit = 5}) => const <String>[];

  static final _db = FoodDb(
    meta: const FoodDbMeta(
      dataVersion: '1.2.0',
      reviewedAt: '2026-02-14',
      distributionPolicyKo: <String>[],
    ),
    foods: <FoodItem>[
      FoodItem(
        id: 'foodTestMixed',
        nameKo: '테스트 음식',
        nameEn: 'Test Food',
        aliases: const <String>['test'],
        category: 'other',
        foodType: FoodType.mixed,
        safetyLevel: SafetyLevel.caution,
        oneLinerKo: '테스트 요약',
        reasonKo: const <String>['테스트 이유'],
        riskNotesKo: const <String>['테스트 위험'],
        safetyConditions: const <SafetyCondition>[
          SafetyCondition(
            labelKo: '과육',
            part: PartType.flesh,
            prep: PrepType.raw,
            level: SafetyLevel.safe,
            noteKo: '과육 테스트',
          ),
        ],
        portionsKo: const PortionGuide(
          allowedParts: <String>['과육'],
          avoidParts: <String>['씨앗'],
          frequency: '가끔 소량',
          notes: <String>[],
          examplesKo: <String>[],
        ),
        confusables: const <ConfusableItem>[],
        evidenceLevel: EvidenceLevel.medium,
        reviewedAt: '2026-02-14',
        sources: const <SourceReference>[
          SourceReference(type: 'textbook', title: 't', year: 2020),
        ],
        searchTokens: const <String>['test'],
        emergency: const EmergencyProfile(
          baseRisk: EmergencyRiskLevel.medium,
          whatToDoKo: <String>['관찰'],
          watchForKo: <String>['무기력'],
          escalationTriggersKo: <String>['호흡 이상'],
        ),
      ),
    ],
  );
}
