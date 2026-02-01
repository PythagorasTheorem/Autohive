import 'package:flutter/material.dart';

/// Generates professional-looking line charts for trends.
class LineChartPainter extends CustomPainter {
  final List<double> dataPoints;
  final Color lineColor;
  final Color fillColor;
  final double? minValue;
  final double? maxValue;

  LineChartPainter({
    required this.dataPoints,
    this.lineColor = const Color(0xFF1976D2),
    this.fillColor = const Color(0xff1976d235),
    this.minValue,
    this.maxValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    final width = size.width;
    final height = size.height;
    final padding = 24.0;

    // Calculate min and max values
    final min =
        minValue ??
        (dataPoints.isNotEmpty
            ? dataPoints.reduce((a, b) => a < b ? a : b)
            : 0);
    final max =
        maxValue ??
        (dataPoints.isNotEmpty
            ? dataPoints.reduce((a, b) => a > b ? a : b)
            : 1);
    final range = max - min;

    // Draw grid lines (more subtle)
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.15)
      ..strokeWidth = 0.8;

    for (int i = 0; i <= 4; i++) {
      final y = padding + (height - 2 * padding) * (i / 4);
      canvas.drawLine(
        Offset(padding, y),
        Offset(width - padding, y),
        gridPaint,
      );
    }

    // Draw data line with fill
    final path = Path();
    final fillPath = Path();

    // Reverse dataPoints to display increasing trends correctly
    final pointsToPlot = dataPoints.toList().reversed.toList();

    for (int i = 0; i < pointsToPlot.length; i++) {
      final x =
          padding + (width - 2 * padding) * (i / (pointsToPlot.length - 1));
      final normalizedValue = range == 0 ? 0 : (pointsToPlot[i] - min) / range;
      final y = height - padding - (height - 2 * padding) * normalizedValue;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, height - padding);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    // Complete the fill path
    if (dataPoints.isNotEmpty) {
      final lastX = padding + (width - 2 * padding);
      fillPath.lineTo(lastX, height - padding);
      fillPath.close();

      // Draw fill
      final fillPaint = Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill;
      canvas.drawPath(fillPath, fillPaint);
    }

    // Draw line
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, linePaint);

    // Draw data points using reversed data
    final pointPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;

    for (int i = 0; i < pointsToPlot.length; i++) {
      final x =
          padding + (width - 2 * padding) * (i / (pointsToPlot.length - 1));
      final normalizedValue = range == 0 ? 0 : (pointsToPlot[i] - min) / range;
      final y = height - padding - (height - 2 * padding) * normalizedValue;
      canvas.drawCircle(Offset(x, y), 5.5, pointPaint);
    }
  }

  @override
  bool shouldRepaint(LineChartPainter oldDelegate) =>
      oldDelegate.dataPoints != dataPoints;
}

/// Generates professional-looking bar charts.
class BarChartPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;
  final double? minValue;
  final double? maxValue;

  BarChartPainter({
    required this.values,
    required this.colors,
    this.minValue,
    this.maxValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final width = size.width;
    final height = size.height;
    final padding = 16.0;

    final min = minValue ?? (values.reduce((a, b) => a < b ? a : b));
    final max = maxValue ?? (values.reduce((a, b) => a > b ? a : b));
    final range = max - min;

    // Draw grid lines
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 1;

    for (int i = 0; i <= 4; i++) {
      final y = padding + (height - 2 * padding) * (i / 4);
      canvas.drawLine(
        Offset(padding, y),
        Offset(width - padding, y),
        gridPaint,
      );
    }

    // Draw bars
    final barWidth = (width - 2 * padding) / values.length * 0.7;
    final barSpacing = (width - 2 * padding) / values.length;

    for (int i = 0; i < values.length; i++) {
      final normalizedValue = range == 0 ? 0 : (values[i] - min) / range;
      final barHeight = (height - 2 * padding) * normalizedValue;

      final x = padding + i * barSpacing + (barSpacing - barWidth) / 2;
      final y = height - padding - barHeight;

      final barPaint = Paint()
        ..color = i < colors.length ? colors[i] : Colors.grey
        ..style = PaintingStyle.fill;

      // Draw bar with rounded top
      final barRect = Rect.fromLTWH(x, y, barWidth, barHeight);
      final rRect = RRect.fromRectAndCorners(
        barRect,
        topLeft: const Radius.circular(4),
        topRight: const Radius.circular(4),
      );
      canvas.drawRRect(rRect, barPaint);
    }
  }

  @override
  bool shouldRepaint(BarChartPainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.colors != colors;
}

/// Widget for displaying a line chart
class LineChart extends StatelessWidget {
  final List<double> dataPoints;
  final String title;
  final Color lineColor;
  final Color fillColor;
  final double? minValue;
  final double? maxValue;

  const LineChart({
    super.key,
    required this.dataPoints,
    required this.title,
    this.lineColor = const Color(0xFF1976D2),
    this.fillColor = const Color(0xff1976d235),
    this.minValue,
    this.maxValue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8.0, bottom: 4.0),
            child: CustomPaint(
              painter: LineChartPainter(
                dataPoints: dataPoints,
                lineColor: lineColor,
                fillColor: fillColor,
                minValue: minValue,
                maxValue: maxValue,
              ),
              isComplex: true,
              willChange: false,
            ),
          ),
        ),
      ],
    );
  }
}

/// Widget for displaying a bar chart
class BarChart extends StatelessWidget {
  final List<double> values;
  final List<Color> colors;
  final String title;
  final double? minValue;
  final double? maxValue;

  const BarChart({
    super.key,
    required this.values,
    required this.colors,
    required this.title,
    this.minValue,
    this.maxValue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: CustomPaint(
            painter: BarChartPainter(
              values: values,
              colors: colors,
              minValue: minValue,
              maxValue: maxValue,
            ),
            isComplex: true,
            willChange: false,
          ),
        ),
      ],
    );
  }
}
