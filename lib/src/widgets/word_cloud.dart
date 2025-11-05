import 'dart:math';
import 'package:flutter/material.dart';

class WordCloudPainter extends CustomPainter {
  final List<String> words;
  final List<int> frequencies;
  final List<Color> colors;

  WordCloudPainter({
    required this.words,
    required this.frequencies,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (words.isEmpty) return;

    final maxFreq = frequencies.reduce(max);
    final minFreq = frequencies.reduce(min);
    final freqRange = maxFreq - minFreq;

    // Create painters for different sizes
    final textPainters = <TextPainter>[];
    final positions = <Offset>[];
    final random = Random(42); // Fixed seed for consistent layout

    for (var i = 0; i < words.length; i++) {
      // Calculate size based on frequency
      final normalizedFreq = freqRange > 0 
        ? (frequencies[i] - minFreq) / freqRange 
        : 0.5;
      final fontSize = 14.0 + (normalizedFreq * 24.0); // 14-38px range

      final textSpan = TextSpan(
        text: words[i],
        style: TextStyle(
          fontSize: fontSize,
          color: colors[i % colors.length],
          fontWeight: FontWeight.w500,
        ),
      );

      final painter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      // Try to find a position that doesn't overlap
      var placed = false;
      var attempts = 0;
      const maxAttempts = 100;

      while (!placed && attempts < maxAttempts) {
        final x = random.nextDouble() * (size.width - painter.width);
        final y = random.nextDouble() * (size.height - painter.height);
        final position = Offset(x, y);

        // Check for overlap with existing words
        var hasOverlap = false;
        for (var j = 0; j < textPainters.length; j++) {
          final rect1 = position & painter.size;
          final rect2 = positions[j] & textPainters[j].size;
          if (rect1.overlaps(rect2)) {
            hasOverlap = true;
            break;
          }
        }

        if (!hasOverlap) {
          textPainters.add(painter);
          positions.add(position);
          placed = true;
        }

        attempts++;
      }

      // If we couldn't place it after max attempts, place it anyway
      if (!placed) {
        final x = random.nextDouble() * (size.width - painter.width);
        final y = random.nextDouble() * (size.height - painter.height);
        textPainters.add(painter);
        positions.add(Offset(x, y));
      }
    }

    // Draw all words
    for (var i = 0; i < textPainters.length; i++) {
      textPainters[i].paint(canvas, positions[i]);
    }
  }

  @override
  bool shouldRepaint(WordCloudPainter oldDelegate) =>
      words != oldDelegate.words ||
      frequencies != oldDelegate.frequencies ||
      colors != oldDelegate.colors;
}

class WordCloud extends StatelessWidget {
  final Map<String, int> wordFrequencies;
  final double height;
  final List<Color> colors;

  const WordCloud({
    super.key,
    required this.wordFrequencies,
    this.height = 200,
    this.colors = const [
      Colors.teal,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
    ],
  });

  @override
  Widget build(BuildContext context) {
    if (wordFrequencies.isEmpty) {
      return SizedBox(height: height);
    }

    // Sort by frequency and take top 20 words
    final sortedEntries = wordFrequencies.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topWords = sortedEntries.take(20).toList();

    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: WordCloudPainter(
          words: topWords.map((e) => e.key).toList(),
          frequencies: topWords.map((e) => e.value).toList(),
          colors: colors,
        ),
        size: Size.infinite,
      ),
    );
  }
}