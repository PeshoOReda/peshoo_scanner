// scanner.dart
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:peshoo_scanner/ui/scanner_border_painter.dart';

class ScannerComponent extends StatelessWidget {
  final Function(BarcodeCapture) onDetect;
  final bool showBorder;

  const ScannerComponent(
      {super.key, required this.onDetect, required this.showBorder});

  @override
  Widget build(BuildContext context) {
    final scanWindow = Rect.fromLTWH(80, 70, 300, 150);
    return Expanded(
        flex: 2,
        child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black26,
                      blurRadius: 40,
                      offset: Offset(0, 15))
                ]),
            margin: EdgeInsets.all(10),
            child: Stack(children: [
              MobileScanner(onDetect: onDetect, scanWindow: scanWindow),
              if (showBorder)
                Positioned(
                    top: scanWindow.top,
                    left: scanWindow.left,
                    child: CustomPaint(
                        size: Size(scanWindow.width, scanWindow.height),
                        painter: ScannerBorderPainter()))
            ])));
  }
}
