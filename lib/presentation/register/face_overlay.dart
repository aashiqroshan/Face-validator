import 'package:flutter/material.dart';

class FaceOverlay extends StatelessWidget {
  final bool isValid;

  const FaceOverlay({super.key, this.isValid = false});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        size: MediaQuery.of(context).size,
        painter: FaceOverlayPainter(isValid: isValid),
      ),
    );
  }
}

class FaceOverlayPainter extends CustomPainter {
  final bool isValid;

  FaceOverlayPainter({required this.isValid});

  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()..color = Colors.black.withOpacity(.55);

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    final ovalRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * .48),
      width: 300,
      height: 540,
    );

    final path = Path()
      ..addRect(rect)
      ..addOval(ovalRect)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, background);

    final border = Paint()
      ..color = isValid ? Colors.greenAccent : Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawOval(ovalRect, border);
  }

  @override
  bool shouldRepaint(covariant FaceOverlayPainter oldDelegate) {
    return oldDelegate.isValid != isValid;
  }
}