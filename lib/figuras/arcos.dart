import 'package:flutter/material.dart';
import 'package:flutter_advanced/modelos/arcos.dart';
import 'dart:math' as math;

class Arco extends CustomPainter {
  List<ModeloArco> vArco;
  double animacionProgreso;
  double backpropProgreso;

  Arco(this.vArco, {this.animacionProgreso = 0.0, this.backpropProgreso = 0.0});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paintLinea = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.black87
      ..strokeWidth = 2;

    Paint paintSenal = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.yellow;

    Paint paintBackprop = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.red;

    // Configuración para el texto de pesos
    final textStyle = TextStyle(
      color: Colors.blue.shade700,
      fontSize: 12,
      fontWeight: FontWeight.bold,
    );

    for (var arco in vArco) {
      // Color del arco dependiendo del estado
      Color colorArco = Colors.black87;
      if (arco.retropropagando) {
        colorArco = Colors.red.shade600;
      } else if (arco.propagando) {
        colorArco = Colors.green.shade600;
      }

      Paint paintLineaActual = Paint()
        ..style = PaintingStyle.stroke
        ..color = colorArco
        ..strokeWidth = arco.propagando || arco.retropropagando ? 3 : 2;

      // Dibujar la línea del arco
      canvas.drawLine(
        Offset(arco.partida.x, arco.partida.y),
        Offset(arco.llegada.x, arco.llegada.y),
        paintLineaActual,
      );

      // Calcular el punto medio para mostrar el peso
      double medioX = (arco.partida.x + arco.llegada.x) / 2;
      double medioY = (arco.partida.y + arco.llegada.y) / 2;

      // Dibujar el peso sináptico con colores diferentes
      Color colorPeso = Colors.blue.shade700;
      if (arco.peso > 0) {
        colorPeso = Colors.green.shade700;
      } else if (arco.peso < 0) {
        colorPeso = Colors.red.shade700;
      }

      final textSpan = TextSpan(
        text: arco.peso.toStringAsFixed(2),
        style: textStyle.copyWith(color: colorPeso),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      // Fondo blanco para el texto del peso
      Paint fondoPeso = Paint()
        ..style = PaintingStyle.fill
        ..color = Colors.white;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(medioX, medioY - 15),
            width: textPainter.width + 4,
            height: textPainter.height + 2,
          ),
          Radius.circular(3),
        ),
        fondoPeso,
      );

      // Offset para posicionar el texto ligeramente arriba del arco
      textPainter.paint(
        canvas,
        Offset(medioX - textPainter.width / 2, medioY - 15),
      );

      // Dibujar la señal propagándose hacia adelante
      if (arco.propagando && animacionProgreso > 0) {
        double dx = arco.llegada.x - arco.partida.x;
        double dy = arco.llegada.y - arco.partida.y;

        // Posición actual de la señal basada en la animación
        double senalX = arco.partida.x + dx * animacionProgreso;
        double senalY = arco.partida.y + dy * animacionProgreso;

        // Dibujar un círculo pequeño representando la señal
        canvas.drawCircle(
          Offset(senalX, senalY),
          6,
          paintSenal,
        );

        // Agregar un efecto de brillo
        Paint brilloPaint = Paint()
          ..style = PaintingStyle.fill
          ..color = Colors.yellow.withOpacity(0.3);
        canvas.drawCircle(
          Offset(senalX, senalY),
          10,
          brilloPaint,
        );
      }

      // Dibujar la señal de retropropagación
      if (arco.retropropagando && backpropProgreso > 0) {
        double dx = arco.llegada.x - arco.partida.x;
        double dy = arco.llegada.y - arco.partida.y;

        // Posición actual de la señal (inversa para retropropagación)
        double senalX = arco.llegada.x - dx * backpropProgreso;
        double senalY = arco.llegada.y - dy * backpropProgreso;

        // Dibujar un círculo rojo representando el error retropropagándose
        canvas.drawCircle(
          Offset(senalX, senalY),
          6,
          paintBackprop,
        );

        // Agregar un efecto de brillo rojo
        Paint brilloBackprop = Paint()
          ..style = PaintingStyle.fill
          ..color = Colors.red.withOpacity(0.3);
        canvas.drawCircle(
          Offset(senalX, senalY),
          10,
          brilloBackprop,
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

        canvas.drawPath(flecha, paintLineaActual);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}