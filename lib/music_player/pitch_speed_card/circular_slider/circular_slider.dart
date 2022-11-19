import 'dart:math';

import 'package:flutter/material.dart';
import 'package:musbx/music_player/pitch_speed_card/circular_slider/painter.dart';
import 'package:musbx/music_player/pitch_speed_card/circular_slider/utils.dart';
import 'package:musbx/music_player/pitch_speed_card/custom_pan_gesture_recognizer.dart';

enum DraggingMode {
  none,
  along,
  inside;
}

class CircularSlider extends StatefulWidget {
  const CircularSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.min = 0.0,
    this.max = 1.0,
    this.radius = 50,
    this.startAngle = -2.0,
    this.endAngle = 2.0,
  });

  final double value;
  final double min;
  final double max;
  final void Function(double value)? onChanged;

  /// Widget displayed in the center of the slider.
  final Widget? label;

  final double radius;
  final double startAngle;
  final double endAngle;

  @override
  State<StatefulWidget> createState() => CircularSliderState();
}

class CircularSliderState extends State<CircularSlider> {
  DraggingMode dragging = DraggingMode.none;

  ThemeData? theme;

  double get activeFraction =>
      (widget.value - widget.min) / (widget.max - widget.min);

  double get trackRadius => theme?.sliderTheme.trackHeight ?? 16.0;
  Size get size => Size.square(widget.radius * 2 + trackRadius * 2);
  Offset get center => size.center(Offset.zero);

  @override
  Widget build(BuildContext context) {
    theme ??= Theme.of(context);
    return buildCustomPanGestureDetector(
      recognizer: CustomPanGestureRecognizer(
        onPanDown: onPanDown,
        onPanUpdate: (PointerMoveEvent event) {
          if (dragging == DraggingMode.along) {
            onPan(event.position);
          }
        },
        onPanEnd: (PointerUpEvent event) {
          dragging = DraggingMode.none;
        },
        onPanCancel: (PointerCancelEvent event) {
          dragging = DraggingMode.none;
        },
      ),
      child: CustomPaint(
        painter: CircularSliderPainter(
          theme: theme ?? Theme.of(context),
          radius: widget.radius,
          activeFraction: activeFraction,
          startAngle: widget.startAngle,
          endAngle: widget.endAngle,
        ),
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: Center(child: widget.label),
        ),
      ),
    );
  }

  bool onPanDown(PointerEvent event) {
    final double thumbAngle = widget.startAngle -
        pi / 2 +
        (widget.endAngle - widget.startAngle) * activeFraction;
    final Offset thumbOffset = angleToPoint(thumbAngle, center, widget.radius);

    if (isPointAlongCircle(
          globalToLocal(event.position),
          center,
          widget.radius,
          trackRadius,
        ) ||
        isPointInsideCircle(globalToLocal(event.position), thumbOffset, 10)) {
      dragging = DraggingMode.along;
      onPan(event.position);
      return true;
    }
    return false;
  }

  /// Calculate the new value and invoke [onChanged] callback.
  void onPan(Offset globalPosition) {
    double angle = pointToAngle(globalToLocal(globalPosition), center);
    angle = angle.clamp(widget.startAngle, widget.endAngle);
    double fraction =
        (angle - widget.startAngle) / (widget.endAngle - widget.startAngle);
    double newValue = fraction * (widget.max - widget.min) + widget.min;
    widget.onChanged?.call(newValue);
  }

  /// Convert global [position] to local coordinate space.
  Offset globalToLocal(Offset position) {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    return renderBox.globalToLocal(position);
  }
}
