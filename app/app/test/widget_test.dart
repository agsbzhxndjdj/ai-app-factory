import 'package:flutter_test/flutter_test.dart';

import 'package:ai_app_factory/main.dart';

void main() {
  testWidgets('App renders', (tester) async {
    await tester.pumpWidget(const AiAppFactoryApp());
    await tester.pumpAndSettle();

    expect(find.text('AI App Factory'), findsOneWidget);
  });
}
