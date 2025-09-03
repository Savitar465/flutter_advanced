import 'package:flutter/material.dart';
import 'package:flutter_advanced/modelos/modelo_nodo.dart';

class Nodo extends CustomPainter {
  List<ModeloNodo> vNodo;
  Nodo(this.vNodo);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..style = PaintingStyle.fill;

    vNodo.forEach((ele) {
      paint.color = ele.color;
      canvas.drawCircle(Offset(ele.x, ele.y), ele.radio, paint);
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
