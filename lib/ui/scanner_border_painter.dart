import 'package:flutter/material.dart';

class ScannerBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red // تغيير اللون إلى الأحمر
      ..strokeWidth = 6.0 // جعل الحدود أكثر سمكا
      ..style = PaintingStyle.stroke;

    final double cornerLength = 30.0;
    final double crossLength = 20.0;

    // رسم الزاوية العلوية اليسرى
    canvas.drawLine(Offset(0, 0), Offset(cornerLength, 0), paint);
    canvas.drawLine(Offset(0, 0), Offset(0, cornerLength), paint);

    // رسم الزاوية العلوية اليمنى
    canvas.drawLine(
        Offset(size.width, 0), Offset(size.width - cornerLength, 0), paint);
    canvas.drawLine(
        Offset(size.width, 0), Offset(size.width, cornerLength), paint);

    // رسم الزاوية السفلية اليسرى
    canvas.drawLine(
        Offset(0, size.height), Offset(0, size.height - cornerLength), paint);
    canvas.drawLine(
        Offset(0, size.height), Offset(cornerLength, size.height), paint);

    // رسم الزاوية السفلية اليمنى
    canvas.drawLine(Offset(size.width, size.height),
        Offset(size.width - cornerLength, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height),
        Offset(size.width, size.height - cornerLength), paint);

    // رسم علامة + في منتصف المربع
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    canvas.drawLine(
      Offset(centerX, centerY - crossLength / 2),
      Offset(centerX, centerY + crossLength / 2),
      paint,
    );
    canvas.drawLine(
      Offset(centerX - crossLength / 2, centerY),
      Offset(centerX + crossLength / 2, centerY),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
