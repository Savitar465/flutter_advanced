import 'package:flutter_advanced/modelos/modelo_nodo.dart';

class ModeloArco {
  ModeloNodo partida, llegada;
  double peso;
  double senalActual; // Para animación de propagación
  bool propagando; // Propagación hacia adelante
  bool retropropagando; // Retropropagación

  ModeloArco(this.partida, this.llegada, this.peso)
      : senalActual = 0.0,
        propagando = false,
        retropropagando = false;
}