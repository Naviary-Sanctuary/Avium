import 'package:avium/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('home search shows result badge quickly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const AviumApp());
    await tester.pumpAndSettle();
    await _dismissInitialNotice(tester);
    await _goToSearchTab(tester);

    await tester.enterText(find.byType(TextField), '사과');
    await tester.pumpAndSettle();

    final appleTile = find.ancestor(
      of: find.text('사과'),
      matching: find.byType(ListTile),
    );
    expect(appleTile, findsWidgets);
    expect(find.text('Caution'), findsWidgets);
  });

  testWidgets('home search to detail condition selection flow', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const AviumApp());
    await tester.pumpAndSettle();
    await _dismissInitialNotice(tester);
    await _goToSearchTab(tester);

    await tester.enterText(find.byType(TextField), '사과');
    await tester.pumpAndSettle();

    final appleTile = find.widgetWithText(ListTile, '사과');
    expect(appleTile, findsWidgets);
    await tester.tap(appleTile.first);
    await tester.pumpAndSettle();

    expect(find.text('조건 선택'), findsOneWidget);
    await tester.tap(find.text('과육').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('생').first);
    await tester.pumpAndSettle();

    expect(find.text('조건 선택이 완전하지 않아 보수적으로 표시됩니다.'), findsNothing);
    expect(find.textContaining('깨끗한 과육을 소량 제공하세요.'), findsOneWidget);
  });

  testWidgets('search zero result opens emergency unknown flow', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const AviumApp());
    await tester.pumpAndSettle();
    await _dismissInitialNotice(tester);
    await _goToSearchTab(tester);

    await tester.enterText(find.byType(TextField), '없는음식이름');
    await tester.pumpAndSettle();

    expect(find.text('검색 결과에 없는 음식이 안전하다는 뜻은 아닙니다.'), findsOneWidget);

    final emergencyButton = find.text('섭취 후 긴급 대응 확인');
    await tester.ensureVisible(emergencyButton);
    await tester.pumpAndSettle();
    await tester.tap(emergencyButton, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('조류 진료 가능 병원/수의사 연락을 권장합니다.'), findsOneWidget);
  });
}

Future<void> _dismissInitialNotice(WidgetTester tester) async {
  final notice = find.text('본 앱 정보는 참고용이며 진단/치료를 대체하지 않습니다.');
  if (notice.evaluate().isEmpty) {
    return;
  }
  final startButton = find.text('시작하기');
  if (startButton.evaluate().isNotEmpty) {
    await tester.tap(startButton);
  } else {
    await tester.tap(find.text('확인'));
  }
  await tester.pumpAndSettle();
}

Future<void> _goToSearchTab(WidgetTester tester) async {
  await tester.tap(find.text('검색'));
  await tester.pumpAndSettle();
}
