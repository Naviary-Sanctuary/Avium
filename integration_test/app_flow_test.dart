import 'package:avium/app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('search zero result opens emergency unknown flow', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const AviumApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(EditableText), '없는음식이름');
    await tester.pumpAndSettle();

    expect(find.text('DB에 없는 음식은 안전하다는 뜻이 아닙니다.'), findsOneWidget);

    await tester.tap(find.text('응급 모드 열기(음식 미상)'));
    await tester.pumpAndSettle();

    expect(find.text('조류 진료 가능 병원/수의사 연락을 권장합니다.'), findsOneWidget);
  });
}
