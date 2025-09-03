import 'package:flutter/material.dart';
import 'package:flutter_advanced/modelos/arcos.dart';

class Arco extends CustomPainter {
  List<ModeloArco> vArco;
  Arco(this.vArco);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.black
      ..strokeWidth = 2;

    vArco.forEach((ele) {
      canvas.drawLine(
        Offset(ele.partida.x, ele.partida.y),
        Offset(ele.llegada.x, ele.llegada.y),
        paint,
      );
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
