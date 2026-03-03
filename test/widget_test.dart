import 'package:flutter_test/flutter_test.dart';
import 'package:wisper_pro/app.dart';

void main() {
  testWidgets('App renders', (tester) async {
    await tester.pumpWidget(const WisperProApp());
    expect(find.text('Wisper Pro'), findsOneWidget);
  });
}
