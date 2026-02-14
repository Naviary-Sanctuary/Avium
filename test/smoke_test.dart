import 'package:avium/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders app shell', (WidgetTester tester) async {
    await tester.pumpWidget(const AviumApp());

    expect(find.text('Avium'), findsOneWidget);
  });
}
