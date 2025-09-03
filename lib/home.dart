import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_advanced/figuras/arcos.dart';
import 'package:flutter_advanced/figuras/nodo.dart';
import 'package:flutter_advanced/modelos/arcos.dart';
import 'dart:math' as math;

import 'package:flutter_advanced/modelos/modelo_nodo.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<ModeloNodo> vNodo = [];
  List<ModeloArco> vArco = [];
  int etiqueta = 1;
  String modo = 'diseño';
  int nodoPartida = -1;
  @override
  void cambioModo(msg) {
    setState(() {
      modo = msg;
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      appBar: AppBar(
        title: Text('R.N.A.'),
        actions: [
          IconButton(
            onPressed: () {
              cambioModo('diseño');
            },
            icon: Icon(
              Icons.design_services,
              color: (modo == 'diseño') ? Colors.green : Colors.red,
              size: 40,
            ),
          ),
          IconButton(
            onPressed: () {
              cambioModo('enlace');
            },
            icon: Icon(
              Icons.architecture,
              color: (modo == 'enlace') ? Colors.green : Colors.red,
              size: 40,
            ),
          ),
          IconButton(
            onPressed: () {
              cambioModo('run');
            },
            icon: Icon(
              Icons.run_circle,
              color: (modo == 'run') ? Colors.green : Colors.red,
              size: 40,
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // espacio disponinle
          final double w = constraints.maxWidth;
          final double h = constraints.maxHeight;
          final double shortTest = math.min(w, h);

          // parametros responsivos
          final double radius = shortTest * 0.07;
          final bool isCompact = w < 400.0;

          return SizedBox.expand(
            child: Stack(
              children: [
                Stack(
                  children: [
                    CustomPaint(painter: Arco(vArco)),
                    CustomPaint(painter: Nodo(vNodo)),

                    GestureDetector(
                      onPanDown: (desp) {
                        if (modo == 'diseño' || modo == 'enlace') {
                          setState(() {
                            int posicion = estaSobreNodo(
                              desp.localPosition.dx,
                              desp.localPosition.dy,
                            );
                            if (posicion == -1) {
                              if (modo == 'diseño') {
                                vNodo.add(
                                  ModeloNodo(
                                    desp.localPosition.dx,
                                    desp.localPosition.dy,
                                    radius,
                                    Colors.purple,
                                    etiqueta.toString(),
                                  ),
                                );
                                etiqueta++;
                              }
                            } else {
                              if (modo == 'enlace') {
                                if (nodoPartida == -1) {
                                  nodoPartida = posicion;
                                } else {
                                  // creamos el nlace
                                  vArco.add(
                                    ModeloArco(
                                      vNodo[nodoPartida],
                                      vNodo[posicion],
                                      0.5,
                                    ),
                                  );
                                  nodoPartida = -1;
                                }
                              }
                            }
                          });
                        }
                      },
                      onLongPressEnd: (desp) {
                        if (modo == 'diseño') {
                          int posicion = estaSobreNodo(
                            desp.localPosition.dx,
                            desp.localPosition.dy,
                          );
                          if (posicion >= 0) {
                            print('eliminar $posicion');
                            setState(() {
                              // eliminamos todos los arccos
                              vArco.removeWhere(
                                (a) =>
                                    (a.partida == vNodo[posicion]) ||
                                    (a.llegada == vNodo[posicion]),
                              );

                              // finalmente borramos el nodo
                              vNodo.removeAt(posicion);
                            });
                          }
                        }
                      },
                      onPanUpdate: (desp) {
                        if (modo == 'diseño') {
                          int posicion = estaSobreNodo(
                            desp.localPosition.dx,
                            desp.localPosition.dy,
                          );
                          if (posicion >= 0) {
                            setState(() {
                              vNodo[posicion].x = desp.localPosition.dx;
                              vNodo[posicion].y = desp.localPosition.dy;
                            });
                          }
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  int estaSobreNodo(double x, double y) {
    for (int i = 0; i < vNodo.length; i++) {
      double distancia = sqrt(pow(vNodo[i].x - x, 2) + pow(vNodo[i].y - y, 2));
      if (distancia <= vNodo[i].radio) {
        return i;
      }
    }
    return -1;
  }
}
