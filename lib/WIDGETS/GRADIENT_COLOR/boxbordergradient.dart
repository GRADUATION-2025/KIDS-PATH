import 'package:flutter/material.dart';

class GradientBoxBorder extends BoxBorder {
  final Gradient gradient;
  final double width;

  const GradientBoxBorder({
    required this.gradient,
    this.width = 1.0,
  });

  @override
  BorderSide get top => BorderSide(width: width, color: Colors.transparent);

  @override
  BorderSide get bottom => BorderSide(width: width, color: Colors.transparent);

  @override
  void paint(Canvas canvas, Rect rect, {
    TextDirection? textDirection,
    BoxShape shape = BoxShape.rectangle,
    BorderRadius? borderRadius,
  }) {
    if (width <= 0.0) return;

    final Paint paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;

    switch (shape) {
      case BoxShape.circle:
        canvas.drawCircle(rect.center, rect.shortestSide / 2, paint);
        break;
      case BoxShape.rectangle:
        if (borderRadius != null) {
          canvas.drawRRect(borderRadius.toRRect(rect), paint);
        } else {
          canvas.drawRect(rect, paint);
        }
        break;
    }
  }

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(width);

  @override
  bool get isUniform => true;

  @override
  GradientBoxBorder scale(double t) => GradientBoxBorder(
    gradient: gradient,
    width: width * t,
  );
}