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
import 'package:avium/features/emergency/presentation/emergency_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('hides assessment when no food and no symptom selected', (
    WidgetTester tester,
  ) async {
    final appState = AppState(
      repository: _EmptyRepository(),
      preferencesLoader: () async => null,
    );
    await appState.initialize();

    await tester.pumpWidget(
      AppStateScope(
        state: appState,
        child: const MaterialApp(home: EmergencyScreen()),
      ),
    );

    expect(find.text('조류 진료 가능 병원/수의사 연락을 권장합니다.'), findsOneWidget);
    expect(find.textContaining('위험도:'), findsNothing);
    await tester.scrollUntilVisible(
      find.text('증상을 먼저 선택하면 긴급 권고가 표시됩니다.'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('증상을 먼저 선택하면 긴급 권고가 표시됩니다.'), findsOneWidget);
  });

  testWidgets('shows assessment when food context exists', (
    WidgetTester tester,
  ) async {
    final appState = AppState(
      repository: _KnownFoodRepository(),
      preferencesLoader: () async => null,
    );
    await appState.initialize();

    await tester.pumpWidget(
      AppStateScope(
        state: appState,
        child: const MaterialApp(home: EmergencyScreen(foodId: 'foodApple')),
      ),
    );

    await tester.scrollUntilVisible(
      find.textContaining('위험도:'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.textContaining('위험도:'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('가정 처치/투약/구토 유도/치료법 안내는 제공하지 않습니다.'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('가정 처치/투약/구토 유도/치료법 안내는 제공하지 않습니다.'), findsOneWidget);
  });
}

class _EmptyRepository implements FoodRepository {
  @override
  FoodItem? getById(String id) => null;

  @override
  Future<FoodDb> loadDb() async {
    return const FoodDb(
      meta: FoodDbMeta(
        dataVersion: '1.2.0',
        reviewedAt: '2026-02-14',
        distributionPolicyKo: <String>[],
      ),
      foods: <FoodItem>[],
    );
  }

  @override
  List<FoodItem> search(String query) => const <FoodItem>[];

  @override
  List<String> suggest(String query, {int limit = 5}) => const <String>[];
}

class _KnownFoodRepository implements FoodRepository {
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

  static final FoodDb _db = FoodDb(
    meta: const FoodDbMeta(
      dataVersion: '1.2.0',
      reviewedAt: '2026-02-14',
      distributionPolicyKo: <String>[],
    ),
    foods: <FoodItem>[
      FoodItem(
        id: 'foodApple',
        nameKo: '사과',
        nameEn: 'Apple',
        aliases: const <String>['apple'],
        category: 'fruit',
        foodType: FoodType.whole,
        safetyLevel: SafetyLevel.caution,
        oneLinerKo: '사과는 소량 급여가 가능합니다.',
        reasonKo: const <String>['씨앗은 피하세요.'],
        riskNotesKo: const <String>['과육만 소량 급여'],
        safetyConditions: const <SafetyCondition>[],
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
          SourceReference(type: 'textbook', title: 'test', year: 2020),
        ],
        searchTokens: const <String>['사과', 'apple'],
        emergency: const EmergencyProfile(
          baseRisk: EmergencyRiskLevel.medium,
          whatToDoKo: <String>['추가 섭취를 중단하세요.'],
          watchForKo: <String>['호흡 이상'],
          escalationTriggersKo: <String>['호흡 이상이 있으면 즉시 문의'],
        ),
      ),
    ],
  );
}
