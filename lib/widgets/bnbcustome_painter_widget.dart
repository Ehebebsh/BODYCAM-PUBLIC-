import 'package:flutter/material.dart';

class BNBCustomePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.white38
      ..style = PaintingStyle.fill;
    Path path = Path()..moveTo(0, 20);
    path.quadraticBezierTo(size.width * .20, 0, size.width * .35, 0);
    path.quadraticBezierTo(size.width * .40, 0, size.width * .40, 20);
    path.arcToPoint(Offset(size.width * .60, 20),
        radius: const Radius.circular(10.0), clockwise: false);

    path.quadraticBezierTo(size.width * .60, 0, size.width * .65, 0);
    path.quadraticBezierTo(size.width * .80, 0, size.width , 20);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawShadow(path, Colors.black, 5, true);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}