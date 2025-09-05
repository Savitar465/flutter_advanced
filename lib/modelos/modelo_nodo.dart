import 'package:flutter/material.dart';
import 'dart:math' as math;

class ModeloNodo {
  double x, y, radio;
  Color color;
  String etiqueta;
  int capa; // Capa/tramo al que pertenece el nodo
  double valorActivacion; // Valor de activación del nodo
  double bias; // Bias del nodo
  bool activado; // Si el nodo está activado en la propagación actual

  ModeloNodo(
      this.x,
      this.y,
      this.radio,
      this.color,
      this.etiqueta, {
        this.capa = -1,
        this.valorActivacion = 0.0,
        this.bias = 0.0,
        this.activado = false,
      });

  // Función de activación sigmoide
  double funcionActivacion(double x) {
    return 1 / (1 + math.exp(-x));
  }

  // Calcular la activación del nodo basado en las entradas
  void calcularActivacion(List<double> entradas, List<double> pesos) {
    double suma = bias;
    for (int i = 0; i < entradas.length && i < pesos.length; i++) {
      suma += entradas[i] * pesos[i];
    }
    valorActivacion = funcionActivacion(suma);
    activado = true;
  }
}