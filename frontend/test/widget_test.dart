import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app.dart';

void main() {
  testWidgets(
    'AstraPay app loads',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const AstraPayApp(),
      );

      expect(find.text('ASTRApay'), findsWidgets);
    },
  );
}