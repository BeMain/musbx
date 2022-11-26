import 'package:flutter/material.dart';
import 'package:just_waveform/just_waveform.dart';

class WaveformPainter extends CustomPainter {
  WaveformPainter({
    required this.steps,
    this.waveColor = Colors.blue,
    this.scale = 1.0,
    this.stepPadding = 2.0,
    this.flags = 0,
  });

  final double scale;
  final double stepPadding;
  final Color waveColor;
  final List<WaveformPixel> steps;
  final int flags;

  @override
  void paint(Canvas canvas, Size size) {
    double stepWidth = size.width / steps.length;

    // Draw steps
    double strokeWidth = stepWidth - stepPadding;
    final Paint wavePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = waveColor;

    for (int i = 0; i < steps.length; i++) {
      canvas.drawLine(
        Offset(i * stepWidth + strokeWidth / 2,
            normalise(steps[i].min, size.height)),
        Offset(i * stepWidth + strokeWidth / 2,
            normalise(steps[i].max, size.height)),
        wavePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant WaveformPainter oldDelegate) {
    return false;
  }

  double normalise(int s, double height) {
    if (flags == 0) {
      final y = 32768 + (scale * s).clamp(-32768.0, 32767.0).toDouble();
      return height - 1 - y * height / 65536;
    } else {
      final y = 128 + (scale * s).clamp(-128.0, 127.0).toDouble();
      return height - 1 - y * height / 256;
    }
  }
}

class WaveformPixel {
  /// Holds the [min] and [max] values for a pixel on a [Waveform]
  WaveformPixel(this.min, this.max);

  WaveformPixel.fromWaveform(Waveform waveform, int pixel)
      : min = waveform.getPixelMin(pixel),
        max = waveform.getPixelMax(pixel);

  /// The minimum value for this pixel
  final int min;

  /// The maximum value for this pixel
  final int max;

  WaveformPixel operator +(WaveformPixel other) {
    return WaveformPixel(min + other.min, max + other.max);
  }

  WaveformPixel operator ~/(int scalar) {
    return WaveformPixel(min ~/ scalar, max ~/ scalar);
  }
}
