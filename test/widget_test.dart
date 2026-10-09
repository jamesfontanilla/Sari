import 'package:flutter_test/flutter_test.dart';
import 'package:sari_app/main.dart';

void main() {
  testWidgets('Sari app basic smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SariApp());
    expect(find.text('🏪 Sari'), findsOneWidget);
  });
}
