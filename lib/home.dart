import 'dart:math';
import 'dart:async';
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

class _HomeState extends State<Home> with TickerProviderStateMixin {
  List<ModeloNodo> vNodo = [];
  List<ModeloArco> vArco = [];
  int etiqueta = 1;
  String modo = 'diseño';
  int nodoPartida = -1;
  int numeroCapas = 3;
  TextEditingController capasController = TextEditingController();

  // Para animación
  AnimationController? _animationController;
  Animation<double>? _animation;
  Timer? _propagacionTimer;
  int capaActual = 0;

  @override
  void initState() {
    super.initState();
    capasController.text = numeroCapas.toString();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _propagacionTimer?.cancel();
    capasController.dispose();
    super.dispose();
  }

  void cambioModo(String msg) {
    setState(() {
      modo = msg;
      nodoPartida = -1;
    });
  }

  void organizarPorCapas() {
    if (vNodo.isEmpty) return;

    // Obtener el ancho disponible
    double anchoDisponible = MediaQuery.of(context).size.width;
    double altoDisponible = MediaQuery.of(context).size.height - 100;

    // Agrupar nodos por capa
    Map<int, List<ModeloNodo>> nodosPorCapa = {};
    for (var nodo in vNodo) {
      if (nodo.capa >= 0) {
        nodosPorCapa[nodo.capa] ??= [];
        nodosPorCapa[nodo.capa]!.add(nodo);
      }
    }

    // Reorganizar posiciones
    setState(() {
      nodosPorCapa.forEach((capa, nodos) {
        double xPos = 100 + (capa * (anchoDisponible - 200) / (numeroCapas - 1));
        double espacioVertical = altoDisponible / (nodos.length + 1);

        for (int i = 0; i < nodos.length; i++) {
          nodos[i].x = xPos;
          nodos[i].y = espacioVertical * (i + 1);
        }
      });
    });
  }

  void iniciarPropagacion() {
    if (vNodo.isEmpty) return;

    // Resetear activaciones
    for (var nodo in vNodo) {
      nodo.activado = false;
      nodo.valorActivacion = 0.0;
    }

    // Activar nodos de entrada (capa 0)
    setState(() {
      for (var nodo in vNodo) {
        if (nodo.capa == 0) {
          nodo.valorActivacion = Random().nextDouble();
          nodo.activado = true;
        }
      }
    });

    // Iniciar propagación por capas
    capaActual = 0;
    _propagacionTimer?.cancel();
    _propagacionTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (capaActual >= numeroCapas - 1) {
        timer.cancel();
        return;
      }

      propagarCapa(capaActual);
      capaActual++;
    });
  }

  void propagarCapa(int capa) {
    setState(() {
      // Marcar arcos como propagando
      for (var arco in vArco) {
        if (arco.partida.capa == capa && arco.llegada.capa == capa + 1) {
          arco.propagando = true;
        }
      }
    });

    // Animar la propagación
    _animationController?.forward(from: 0.0).then((_) {
      setState(() {
        // Activar nodos de la siguiente capa
        for (var nodo in vNodo) {
          if (nodo.capa == capa + 1) {
            // Calcular entrada ponderada
            List<double> entradas = [];
            List<double> pesos = [];

            for (var arco in vArco) {
              if (arco.llegada == nodo && arco.partida.activado) {
                entradas.add(arco.partida.valorActivacion);
                pesos.add(arco.peso);
              }
            }

            if (entradas.isNotEmpty) {
              nodo.calcularActivacion(entradas, pesos);
            }
          }
        }

        // Desmarcar arcos
        for (var arco in vArco) {
          arco.propagando = false;
        }
      });
    });
  }

  void asignarPesosAleatorios() {
    setState(() {
      for (var arco in vArco) {
        arco.peso = (Random().nextDouble() * 2 - 1); // Pesos entre -1 y 1
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      appBar: AppBar(
        title: Text('R.N.A. - Perceptrón Multicapa'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            onPressed: () => cambioModo('diseño'),
            icon: Icon(
              Icons.design_services,
              color: (modo == 'diseño') ? Colors.green : Colors.white70,
              size: 30,
            ),
            tooltip: 'Modo Diseño',
          ),
          IconButton(
            onPressed: () => cambioModo('enlace'),
            icon: Icon(
              Icons.architecture,
              color: (modo == 'enlace') ? Colors.green : Colors.white70,
              size: 30,
            ),
            tooltip: 'Modo Enlace',
          ),
          IconButton(
            onPressed: () => cambioModo('tramo'),
            icon: Icon(
              Icons.layers,
              color: (modo == 'tramo') ? Colors.green : Colors.white70,
              size: 30,
            ),
            tooltip: 'Configurar Capas',
          ),
          IconButton(
            onPressed: () => cambioModo('run'),
            icon: Icon(
              Icons.play_arrow,
              color: (modo == 'run') ? Colors.green : Colors.white70,
              size: 30,
            ),
            tooltip: 'Ejecutar Simulación',
          ),
        ],
      ),
      body: Column(
        children: [
          // Panel de control según el modo
          if (modo == 'tramo')
            Container(
              padding: EdgeInsets.all(16),
              color: Colors.blue.shade100,
              child: Row(
                children: [
                  Text('Número de capas: ', style: TextStyle(fontSize: 16)),
                  SizedBox(width: 10),
                  Container(
                    width: 100,
                    child: TextField(
                      controller: capasController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      ),
                      onChanged: (value) {
                        setState(() {
                          numeroCapas = int.tryParse(value) ?? 3;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: organizarPorCapas,
                    child: Text('Organizar Nodos'),
                  ),
                  SizedBox(width: 10),
                  Text('Click en nodo para asignar capa', style: TextStyle(fontStyle: FontStyle.italic)),
                ],
              ),
            ),

          if (modo == 'run')
            Container(
              padding: EdgeInsets.all(16),
              color: Colors.green.shade100,
              child: Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: iniciarPropagacion,
                    icon: Icon(Icons.play_arrow),
                    label: Text('Iniciar Propagación'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton.icon(
                    onPressed: asignarPesosAleatorios,
                    icon: Icon(Icons.shuffle),
                    label: Text('Pesos Aleatorios'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

          // Área de dibujo
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double w = constraints.maxWidth;
                final double h = constraints.maxHeight;
                final double shortTest = math.min(w, h);
                final double radius = shortTest * 0.05;

                return AnimatedBuilder(
                  animation: _animation ?? AlwaysStoppedAnimation(0.0),
                  builder: (context, child) {
                    return Stack(
                      children: [
                        CustomPaint(
                          painter: Arco(vArco, animacionProgreso: _animation?.value ?? 0.0),
                          size: Size.infinite,
                        ),
                        CustomPaint(
                          painter: Nodo(vNodo),
                          size: Size.infinite,
                        ),
                        GestureDetector(
                          onPanDown: (desp) {
                            if (modo == 'diseño' || modo == 'enlace' || modo == 'tramo') {
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
                                      vNodo[posicion].color = Colors.yellow;
                                    } else {
                                      // Crear enlace con peso inicial aleatorio
                                      vArco.add(
                                        ModeloArco(
                                          vNodo[nodoPartida],
                                          vNodo[posicion],
                                          Random().nextDouble() * 2 - 1,
                                        ),
                                      );
                                      vNodo[nodoPartida].color = Colors.purple;
                                      nodoPartida = -1;
                                    }
                                  } else if (modo == 'tramo') {
                                    // Asignar capa al nodo
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text('Asignar Capa'),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: List.generate(numeroCapas, (index) =>
                                              ListTile(
                                                title: Text('Capa $index'),
                                                onTap: () {
                                                  setState(() {
                                                    vNodo[posicion].capa = index;
                                                  });
                                                  Navigator.pop(context);
                                                },
                                              ),
                                          ),
                                        ),
                                      ),
                                    );
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
                                setState(() {
                                  vArco.removeWhere(
                                        (a) =>
                                    (a.partida == vNodo[posicion]) ||
                                        (a.llegada == vNodo[posicion]),
                                  );
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
                    );
                  },
                );
              },
            ),
          ),
        ],
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