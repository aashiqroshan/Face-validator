import 'package:flutter/material.dart';

class FaceOverlay extends StatelessWidget {
  const FaceOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        size: MediaQuery.of(context).size,
        painter: FaceOverlayPainter(),
      ),
    );
  }
}

class FaceOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {

    final background = Paint()
      ..color = Colors.black.withOpacity(.55);

    final rect = Rect.fromLTWH(
      0,
      0,
      size.width,
      size.height,
    );

    // CHANGED: Use Rect.fromCenter instead of fromCircle to define an oval
    final ovalRect = Rect.fromCenter(
      center: Offset(
        size.width / 2,
        size.height * .48,
      ),
      width: 300,  // Adjust this for horizontal width
      height: 540, // Adjust this for vertical height
    );

    final path = Path()
      ..addRect(rect)
      ..addOval(ovalRect) // This will now cut out an oval
      ..fillType = PathFillType.evenOdd;  

    canvas.drawPath(path, background);

    final border = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawOval(ovalRect, border);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}