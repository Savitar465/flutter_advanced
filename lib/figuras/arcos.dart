import 'package:flutter/material.dart';
import 'package:flutter_advanced/modelos/arcos.dart';
import 'dart:math' as math;

class Arco extends CustomPainter {
  List<ModeloArco> vArco;
  double animacionProgreso;

  Arco(this.vArco, {this.animacionProgreso = 0.0});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paintLinea = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.black87
      ..strokeWidth = 2;

    Paint paintSenal = Paint()
    ..style = PaintingStyle.fill
    ..color = Colors.yellow;

    // Configuración para el texto de pesos
    final textStyle = TextStyle(
    color: Colors.blue.shade700,
    fontSize: 12,
    fontWeight: FontWeight.bold,
    );

    for (var arco in vArco) {
    // Dibujar la línea del arco
    canvas.drawLine(
    Offset(arco.partida.x, arco.partida.y),
    Offset(arco.llegada.x, arco.llegada.y),
    paintLinea,
    );

    // Calcular el punto medio para mostrar el peso
    double medioX = (arco.partida.x + arco.llegada.x) / 2;
    double medioY = (arco.partida.y + arco.llegada.y) / 2;

    // Dibujar el peso sináptico
    final textSpan = TextSpan(
    text: arco.peso.toStringAsFixed(2),
    style: textStyle,
    );
    final textPainter = TextPainter(
    text: textSpan,
    textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    // Offset para posicionar el texto ligeramente arriba del arco
    textPainter.paint(
    canvas,
    Offset(medioX - textPainter.width / 2, medioY - 15),
    );

    // Dibujar la senal propagándose si está activa
    if (arco.propagando && animacionProgreso > 0) {
    double dx = arco.llegada.x - arco.partida.x;
    double dy = arco.llegada.y - arco.partida.y;

    // Posición actual de la senal basada en la animación
    double senalX = arco.partida.x + dx * animacionProgreso;
    double senalY = arco.partida.y + dy * animacionProgreso;

    // Dibujar un círculo pequeno representando la senal
    canvas.drawCircle(
    Offset(senalX, senalY),
    5,
    paintSenal,
    );
    }

    // Dibujar punta de flecha para indicar dirección
    double angulo = math.atan2(
    arco.llegada.y - arco.partida.y,
    arco.llegada.x - arco.partida.x,
    );

    // Ajustar el punto final para que no toque el círculo del nodo
    double distancia = math.sqrt(
    math.pow(arco.llegada.x - arco.partida.x, 2) +
    math.pow(arco.llegada.y - arco.partida.y, 2)
    );

    if (distancia > arco.llegada.radio) {
    double puntoFinalX = arco.llegada.x - math.cos(angulo) * arco.llegada.radio;
    double puntoFinalY = arco.llegada.y - math.sin(angulo) * arco.llegada.radio;

    // Dibujar la punta de flecha
    Path flecha = Path();
    flecha.moveTo(puntoFinalX, puntoFinalY);
    flecha.lineTo(
    puntoFinalX - 10 * math.cos(angulo - 0.5),
    puntoFinalY - 10 * math.sin(angulo - 0.5),
    );
    flecha.moveTo(puntoFinalX, puntoFinalY);
    flecha.lineTo(
    puntoFinalX - 10 * math.cos(angulo + 0.5),
    puntoFinalY - 10 * math.sin(angulo + 0.5),
    );

    canvas.drawPath(flecha, paintLinea);
    }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}