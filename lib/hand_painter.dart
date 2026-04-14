import 'package:flutter/material.dart';

class HandPainter extends CustomPainter {
  final List<double> landmarks;
  final Map<String, bool>? fingerStates;

  HandPainter({required this.landmarks, this.fingerStates});

  @override
  void paint(Canvas canvas, Size size) {
    if (landmarks.length != 63) return;

    final paint = Paint()..style = PaintingStyle.fill;

    // Map landmarks to screen coordinates
    List<Offset> points = [];
    for (int i = 0; i < 21; i++) {
      double rawX = landmarks[i * 3];
      double rawY = landmarks[i * 3 + 1];

      // Rotate 90° clockwise + fix vertical inversion + front camera
      final x = (1 - rawY) * size.width;
      final y = (1 - rawX) * size.height;

      points.add(Offset(x, y));
    }

    // Finger tip mapping
    final fingerMap = {
      4: "thumb",
      8: "index",
      12: "middle",
      16: "ring",
      20: "pinky",
    };

    for (int i = 0; i < points.length; i++) {
      if (fingerMap.containsKey(i) && fingerStates != null) {
        paint.color = fingerStates![fingerMap[i]]! ? Colors.green : Colors.red;
      } else {
        paint.color = Colors.green;
      }

      canvas.drawCircle(points[i], 5, paint);
    }
  }
  @override
  bool shouldRepaint(covariant HandPainter oldDelegate) {
    return true;
  }
}

