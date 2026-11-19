import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:segmented_bar_lite/segmented_bar_lite.dart';

void main() {
  test('segmentFractions', () {
    expect(segmentFractions([1, 3]), [0.25, 0.75]);
    expect(segmentFractions([1, 1], total: 4), [0.25, 0.25]);
    expect(segmentFractions([-2, 2]), [0, 1]);
    expect(segmentFractions([0, 0]), [0, 0]);
  });

  testWidgets('shows a legend with percentages', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: EdgeInsets.all(16),
          child: SegmentedBar(segments: [
            BarSegment(value: 3, color: Colors.green, label: 'Moving'),
            BarSegment(value: 1, color: Colors.red, label: 'Offline'),
          ]),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Moving · 75%'), findsOneWidget);
    expect(find.text('Offline · 25%'), findsOneWidget);
  });
}
