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
import 'package:avium/features/search/presentation/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shows first-visit popup when preference is empty', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final appState = AppState(
      repository: _PopupTestRepository(),
      preferencesLoader: SharedPreferences.getInstance,
    );
    await appState.initialize();

    await tester.pumpWidget(
      AppStateScope(
        state: appState,
        child: const MaterialApp(home: SearchScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('처음 방문 안내'), findsOneWidget);
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getBool('has_seen_initial_disclaimer_v2'), isNull);

    await tester.tap(find.text('동의하고 시작하기'));
    await tester.pumpAndSettle();

    expect(appState.hasSeenInitialDisclaimer, isTrue);
    expect(
      preferences.getBool('has_seen_initial_disclaimer_v2'),
      isTrue,
    );
  });

  testWidgets('does not show popup when preference is already true', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'has_seen_initial_disclaimer_v2': true,
    });
    final appState = AppState(
      repository: _PopupTestRepository(),
      preferencesLoader: SharedPreferences.getInstance,
    );
    await appState.initialize();

    await tester.pumpWidget(
      AppStateScope(
        state: appState,
        child: const MaterialApp(home: SearchScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('처음 방문 안내'), findsNothing);
  });
}

class _PopupTestRepository implements FoodRepository {
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
      reviewedAt: '2026-02-15',
      distributionPolicyKo: <String>[],
    ),
    foods: <FoodItem>[
      _food(
        id: 'foodSafe',
        nameKo: '호밀',
        level: SafetyLevel.safe,
      ),
      _food(
        id: 'foodDanger',
        nameKo: '폭파',
        level: SafetyLevel.danger,
      ),
    ],
  );

  static FoodItem _food({
    required String id,
    required String nameKo,
    required SafetyLevel level,
  }) {
    return FoodItem(
      id: id,
      nameKo: nameKo,
      nameEn: nameKo,
      aliases: <String>[nameKo],
      category: 'test',
      foodType: FoodType.whole,
      safetyLevel: level,
      oneLinerKo: '$nameKo 요약',
      reasonKo: const <String>['테스트'],
      riskNotesKo: const <String>['테스트'],
      safetyConditions: const <SafetyCondition>[],
      portionsKo: const PortionGuide(
        allowedParts: <String>['과육'],
        avoidParts: <String>[],
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
      searchTokens: <String>[nameKo],
      emergency: const EmergencyProfile(
        baseRisk: EmergencyRiskLevel.low,
        whatToDoKo: <String>['관찰'],
        watchForKo: <String>[],
        escalationTriggersKo: <String>[],
      ),
    );
  }
}
