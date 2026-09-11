import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mausam/app.dart';

void main() {
  testWidgets('Mausam app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MausamApp(),
      ),
    );
    expect(find.byType(MausamApp), findsOneWidget);
  });
}
