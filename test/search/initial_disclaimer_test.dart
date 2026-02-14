import 'package:avium/core/state/app_state.dart';
import 'package:avium/core/state/app_state_scope.dart';
import 'package:avium/data/models/food_db.dart';
import 'package:avium/data/models/food_item.dart';
import 'package:avium/data/repositories/food_repository.dart';
import 'package:avium/features/search/presentation/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows initial medical disclaimer once on first home render', (
    WidgetTester tester,
  ) async {
    final appState = AppState(repository: _EmptyRepository());
    await appState.initialize();

    await tester.pumpWidget(
      AppStateScope(
        state: appState,
        child: const MaterialApp(home: SearchScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('본 앱 정보는 참고용이며 진단/치료를 대체하지 않습니다.'), findsOneWidget);

    await tester.tap(find.text('확인'));
    await tester.pumpAndSettle();
    expect(find.text('본 앱 정보는 참고용이며 진단/치료를 대체하지 않습니다.'), findsNothing);

    appState.setQuery('사과');
    await tester.pump();
    expect(find.text('본 앱 정보는 참고용이며 진단/치료를 대체하지 않습니다.'), findsNothing);
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
