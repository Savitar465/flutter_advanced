import 'package:flutter/material.dart';
import 'package:flutter_advanced/modelos/modelo_nodo.dart';

class Nodo extends CustomPainter {
  List<ModeloNodo> vNodo;

  Nodo(this.vNodo);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..style = PaintingStyle.fill;

    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: 14,
      fontWeight: FontWeight.bold,
    );

    for (var nodo in vNodo) {
      // Color basado en la capa
      Color colorNodo = nodo.color;
      if (nodo.capa >= 0) {
        // Colores diferentes para cada capa
        switch (nodo.capa) {
          case 0:
            colorNodo = Colors.green.shade600; // Capa de entrada
            break;
          case 1:
            colorNodo = Colors.blue.shade600; // Primera capa oculta
            break;
          case 2:
            colorNodo = Colors.purple.shade600; // Segunda capa oculta
            break;
          case 3:
            colorNodo = Colors.orange.shade600; // Capa de salida
            break;
          default:
            colorNodo = Colors.grey.shade600;
        }
      }

      // Si el nodo está activado, hacerlo más brillante
      if (nodo.activado) {
        colorNodo = colorNodo.withOpacity(0.9);
        // Dibujar un halo alrededor del nodo activado
        Paint haloPaint = Paint()
          ..style = PaintingStyle.fill
          ..color = colorNodo.withOpacity(0.3);
        canvas.drawCircle(
          Offset(nodo.x, nodo.y),
          nodo.radio * 1.3,
          haloPaint,
        );
      }

      paint.color = colorNodo;
      canvas.drawCircle(Offset(nodo.x, nodo.y), nodo.radio, paint);

      // Dibujar el borde del nodo
      Paint bordePaint = Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.black
        ..strokeWidth = 2;
      canvas.drawCircle(Offset(nodo.x, nodo.y), nodo.radio, bordePaint);

      // Dibujar la etiqueta del nodo
      final textSpan = TextSpan(
        text: nodo.etiqueta,
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          nodo.x - textPainter.width / 2,
          nodo.y - textPainter.height / 2,
        ),
      );

      // Si tiene valor de activación, mostrarlo debajo del nodo
      if (nodo.activado && nodo.valorActivacion > 0) {
        final valorText = TextSpan(
          text: nodo.valorActivacion.toStringAsFixed(2),
          style: TextStyle(
            color: Colors.black,
            fontSize: 10,
            fontWeight: FontWeight.normal,
          ),
        );
        final valorPainter = TextPainter(
          text: valorText,
          textDirection: TextDirection.ltr,
        );
        valorPainter.layout();
        valorPainter.paint(
          canvas,
          Offset(
            nodo.x - valorPainter.width / 2,
            nodo.y + nodo.radio + 5,
          ),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}