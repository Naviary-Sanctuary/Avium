import 'package:avium/core/widgets/medical_disclaimer_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('opens bottom sheet when tapping reference info button', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MedicalDisclaimerBanner(reviewedAt: '2026-02-14'),
        ),
      ),
    );

    expect(find.text('검토: 2026-02-14'), findsOneWidget);
    expect(find.text('참고정보 보기'), findsOneWidget);

    await tester.tap(find.text('참고정보 보기'));
    await tester.pumpAndSettle();

    expect(find.text('참고 안내'), findsOneWidget);
    expect(find.textContaining('이 정보는 참고용입니다.'), findsOneWidget);
    expect(find.textContaining('진단/치료/처방'), findsOneWidget);
  });
}
