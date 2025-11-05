import 'package:flutter/material.dart';
import 'package:echoxapp/src/models/answer.dart';

class SentimentJourneyChart extends StatelessWidget {
  final List<Answer> answers;
  final double height;
  final Color lineColor;
  final Color pointColor;

  const SentimentJourneyChart({
    super.key,
    required this.answers,
    this.height = 100,
    this.lineColor = Colors.teal,
    this.pointColor = Colors.deepPurple,
  });

  @override
  Widget build(BuildContext context) {
    if (answers.isEmpty) {
      return SizedBox(height: height);
    }

    // Sort answers by date
    final sortedAnswers = List.of(answers)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    return SizedBox(
      height: height,
      child: CustomPaint(
        size: Size.infinite,
        painter: _SentimentChartPainter(
          answers: sortedAnswers,
          lineColor: lineColor,
          pointColor: pointColor,
        ),
      ),
    );
  }
}

class _SentimentChartPainter extends CustomPainter {
  final List<Answer> answers;
  final Color lineColor;
  final Color pointColor;

  _SentimentChartPainter({
    required this.answers,
    required this.lineColor,
    required this.pointColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (answers.isEmpty || size.width == 0 || size.height == 0) return;

    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final pointPaint = Paint()
      ..color = pointColor
      ..strokeWidth = 2
      ..style = PaintingStyle.fill;

    final points = answers.asMap().entries.map((entry) {
      final i = entry.key;
      final answer = entry.value;
      final score = answer.sentiment?.score ?? 0;
      
      // x is based on position in list
      final x = (i / (answers.length - 1)) * size.width;
      
      // y is based on sentiment score (-1 to 1 mapped to height)
      final normalizedScore = (score + 1) / 2; // Convert -1...1 to 0...1
      final y = size.height - (normalizedScore * size.height);
      
      return Offset(x, y);
    }).toList();

    // Draw connecting lines
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      // Create smooth curve between points
      if (i < points.length - 1) {
        final current = points[i];
        final next = points[i + 1];
        final controlPoint1 = Offset(
          current.dx - (current.dx - points[i - 1].dx) / 2,
          current.dy
        );
        final controlPoint2 = Offset(
          current.dx + (next.dx - current.dx) / 2,
          current.dy
        );
        path.cubicTo(
          controlPoint1.dx, controlPoint1.dy,
          controlPoint2.dx, controlPoint2.dy,
          next.dx, next.dy
        );
      } else {
        path.lineTo(points[i].dx, points[i].dy);
      }
    }
    
    canvas.drawPath(path, paint);

    // Draw points
    for (final point in points) {
      canvas.drawCircle(point, 4, pointPaint);
    }
  }

  @override
  bool shouldRepaint(_SentimentChartPainter oldDelegate) =>
      answers != oldDelegate.answers ||
      lineColor != oldDelegate.lineColor ||
      pointColor != oldDelegate.pointColor;
}