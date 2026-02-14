import 'package:avium/features/search/widgets/zero_result_notice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders required fixed copy and two buttons', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ZeroResultNotice(
            onOpenEmergencyUnknown: () {},
            onOpenRequestTemplate: () {},
            suggestions: const <String>['사과'],
            onSuggestionTap: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('검색 결과에 없는 음식이 안전하다는 뜻은 아닙니다.'), findsOneWidget);
    expect(find.text('섭취 후 긴급 대응 확인'), findsOneWidget);
    expect(find.text('정보 요청 템플릿(메일)'), findsOneWidget);
    expect(find.byType(FilledButton), findsOneWidget);
    expect(find.byType(OutlinedButton), findsOneWidget);
  });
}
