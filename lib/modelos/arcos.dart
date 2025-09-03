import 'package:flutter_advanced/modelos/modelo_nodo.dart';

class ModeloArco {
  ModeloNodo partida, llegada;
  double costo;
  ModeloArco(this.partida, this.llegada, this.costo);
}
