import 'package:flutter/material.dart';

/// One part of a [SegmentedBar].
@immutable
class BarSegment {
  /// Creates a segment.
  const BarSegment({required this.value, required this.color, this.label});

  /// Size of this part. Negative values count as 0.
  final double value;

  /// Fill color.
  final Color color;

  /// Label shown in the legend.
  final String? label;
}

/// The share of each value in [values] as a fraction from 0 to 1. Uses
/// [total] when given (so the bar can be partly empty), otherwise the sum.
List<double> segmentFractions(List<double> values, {double? total}) {
  final clean = [for (final v in values) v > 0 ? v : 0.0];
  final sum = clean.fold<double>(0, (a, b) => a + b);
  final whole = total ?? sum;
  if (whole <= 0) return List.filled(clean.length, 0.0);
  return [for (final v in clean) v / whole];
}

/// A horizontal bar split into colored segments, with an optional legend.
///
/// ```dart
/// SegmentedBar(segments: const [
///   BarSegment(value: 42, color: Colors.green, label: 'Moving'),
///   BarSegment(value: 18, color: Colors.orange, label: 'Idle'),
///   BarSegment(value: 9, color: Colors.red, label: 'Offline'),
/// ])
/// ```
class SegmentedBar extends StatelessWidget {
  /// Creates the bar.
  const SegmentedBar({
    super.key,
    required this.segments,
    this.total,
    this.height = 12,
    this.gap = 3,
    this.radius,
    this.trackColor,
    this.showLegend = true,
    this.showPercentages = true,
    this.valueFormatter,
    this.duration = const Duration(milliseconds: 600),
  });

  /// The parts, drawn start to end.
  final List<BarSegment> segments;

  /// The value of a full bar. When larger than the sum, the rest is empty
  /// track (useful for "used of capacity").
  final double? total;

  /// Bar height.
  final double height;

  /// Space between segments.
  final double gap;

  /// Corner radius. Defaults to fully rounded.
  final double? radius;

  /// Color of the empty track.
  final Color? trackColor;

  /// Whether to show a legend under the bar.
  final bool showLegend;

  /// Whether the legend shows percentages.
  final bool showPercentages;

  /// Formats raw values in the legend.
  final String Function(double value)? valueFormatter;

  /// Grow animation duration.
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fractions = segmentFractions(
      [for (final s in segments) s.value],
      total: total,
    );
    final r = Radius.circular(radius ?? height / 2);

    final bar = TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, t, _) => ClipRRect(
        borderRadius: BorderRadius.all(r),
        child: Container(
          height: height,
          color: trackColor ?? theme.colorScheme.surfaceContainerHighest,
          child: LayoutBuilder(
            builder: (context, c) {
              final visible = [
                for (var i = 0; i < segments.length; i++)
                  if (fractions[i] > 0) i,
              ];
              final gaps = gap * (visible.length - 1).clamp(0, 1 << 20);
              final width = (c.maxWidth - gaps).clamp(0.0, double.infinity);
              return Row(
                children: [
                  for (final (k, i) in visible.indexed) ...[
                    if (k > 0) SizedBox(width: gap * t),
                    Container(
                      width: width * fractions[i] * t,
                      color: segments[i].color,
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );

    final sum =
        segments.fold<double>(0, (a, s) => a + (s.value > 0 ? s.value : 0));
    final shares = segmentFractions([for (final s in segments) s.value]);
    return Semantics(
      label: [
        for (var i = 0; i < segments.length; i++)
          '${segments[i].label ?? 'Part ${i + 1}'} ${(shares[i] * 100).toStringAsFixed(0)}%',
      ].join(', '),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          bar,
          if (showLegend && sum > 0) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 16,
              runSpacing: 6,
              children: [
                for (var i = 0; i < segments.length; i++)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: segments[i].color,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        [
                          segments[i].label ?? 'Part ${i + 1}',
                          if (valueFormatter != null)
                            valueFormatter!(segments[i].value),
                          if (showPercentages)
                            '${(shares[i] * 100).toStringAsFixed(0)}%',
                        ].join(' · '),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
