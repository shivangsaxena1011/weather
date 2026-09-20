import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mausam/widgets/common/alert_banner.dart';

void main() {
  group('AlertBanner Widget Tests', () {
    testWidgets('Renders title and message correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AlertBanner(
              title: 'Thunderstorm Warning',
              message: 'Severe storm approaching your area in 30 minutes.',
              severity: AlertSeverity.danger,
            ),
          ),
        ),
      );

      expect(find.text('Thunderstorm Warning'), findsOneWidget);
      expect(
        find.text('Severe storm approaching your area in 30 minutes.'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.report_problem_rounded), findsOneWidget);
    });

    testWidgets('Dismisses widget and triggers callback when close icon tapped', (tester) async {
      bool dismissed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlertBanner(
              title: 'High UV Advisory',
              message: 'Peak UV index reaching 8.5 today.',
              severity: AlertSeverity.warning,
              onDismiss: () => dismissed = true,
            ),
          ),
        ),
      );

      expect(find.text('High UV Advisory'), findsOneWidget);

      final closeButton = find.byIcon(Icons.close_rounded);
      expect(closeButton, findsOneWidget);
      await tester.tap(closeButton);
      await tester.pumpAndSettle();

      expect(dismissed, isTrue);
      expect(find.text('High UV Advisory'), findsNothing);
    });
  });
}
