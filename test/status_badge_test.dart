import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campus_incident_reporter/widgets/status_badge.dart';

void main() {
  testWidgets('StatusBadge shows the status text', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: StatusBadge('In Progress')),
      ),
    );
    expect(find.text('In Progress'), findsOneWidget);
  });
}