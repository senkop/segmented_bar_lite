import 'package:flutter/material.dart';
import 'package:segmented_bar_lite/segmented_bar_lite.dart';

void main() => runApp(const MaterialApp(home: DemoPage()));

class DemoPage extends StatelessWidget {
  const DemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('segmented_bar_lite')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text('Fleet status'),
          const SizedBox(height: 8),
          const SegmentedBar(segments: [
            BarSegment(value: 42, color: Color(0xFF16A34A), label: 'Moving'),
            BarSegment(value: 18, color: Color(0xFFF59E0B), label: 'Idle'),
            BarSegment(value: 9, color: Color(0xFFDC2626), label: 'Offline'),
          ]),
          const SizedBox(height: 32),
          const Text('Storage (of 128 GB)'),
          const SizedBox(height: 8),
          SegmentedBar(
            total: 128,
            height: 16,
            valueFormatter: (v) => '${v.toStringAsFixed(0)} GB',
            segments: const [
              BarSegment(value: 40, color: Colors.indigo, label: 'Videos'),
              BarSegment(value: 22, color: Colors.teal, label: 'Photos'),
              BarSegment(value: 12, color: Colors.orange, label: 'Apps'),
            ],
          ),
        ],
      ),
    );
  }
}
