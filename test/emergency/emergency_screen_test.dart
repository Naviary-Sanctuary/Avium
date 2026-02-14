import 'package:avium/core/state/app_state.dart';
import 'package:avium/core/state/app_state_scope.dart';
import 'package:avium/data/models/food_db.dart';
import 'package:avium/data/models/food_item.dart';
import 'package:avium/data/repositories/food_repository.dart';
import 'package:avium/features/emergency/presentation/emergency_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows fixed emergency recommendation and prohibited guidance', (
    WidgetTester tester,
  ) async {
    final appState = AppState(repository: _EmptyRepository());
    await appState.initialize();

    await tester.pumpWidget(
      AppStateScope(
        state: appState,
        child: const MaterialApp(home: EmergencyScreen()),
      ),
    );

    expect(find.text('조류 진료 가능 병원/수의사 연락을 권장합니다.'), findsOneWidget);
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
