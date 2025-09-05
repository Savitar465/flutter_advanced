// lib/home.dart
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

  // Variables para retropropagación
  bool retropropagandoActual = false;
  AnimationController? _backpropController;
  Animation<double>? _backpropAnimation;
  List<double> errores = [];
  double tasaAprendizaje = 0.5; // Aumentamos la tasa de aprendizaje para cambios más visibles
  List<double> objetivos = []; // Salida deseada

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

    // Controller para retropropagación
    _backpropController = AnimationController(
      duration: const Duration(milliseconds: 1500), // Más tiempo para ver mejor la animación
      vsync: this,
    );

    _backpropAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backpropController!,
      curve: Curves.easeInOut,
    ));

    // Agregar listener para debug
    _backpropController!.addListener(() {
      // print('Backprop progress: ${_backpropController!.value}');
    });
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _backpropController?.dispose();
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

  void iniciarPropagacion() async {
    if (vNodo.isEmpty) return;

    // Generar objetivos más diversos para nodos de salida
    objetivos.clear();
    List<ModeloNodo> nodosSalida = vNodo.where((n) => n.capa == numeroCapas - 1).toList();

    print('🎯 Objetivos generados:');
    for (int i = 0; i < nodosSalida.length; i++) {
      // Objetivos más extremos para generar errores más grandes
      double objetivo = Random().nextBool() ? 0.1 : 0.9;
      objetivos.add(objetivo);
      print('   Nodo ${nodosSalida[i].etiqueta}: objetivo = ${objetivo}');
    }

    // Resetear activaciones
    for (var nodo in vNodo) {
      nodo.activado = false;
      nodo.valorActivacion = 0.0;
      nodo.error = 0.0;
    }

    // Resetear arcos
    for (var arco in vArco) {
      arco.propagando = false;
      arco.retropropagando = false;
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

    // Iniciar propagación hacia adelante
    await propagacionHaciaAdelante();

    // Después de la propagación hacia adelante, iniciar retropropagación
    await Future.delayed(Duration(milliseconds: 500));
    await iniciarRetropropagacion();
  }

  Future<void> propagacionHaciaAdelante() async {
    capaActual = 0;

    for (int capa = 0; capa < numeroCapas - 1; capa++) {
      await propagarCapa(capa);
      await Future.delayed(Duration(milliseconds: 800));
    }
  }

  Future<void> propagarCapa(int capa) async {
    setState(() {
      // Marcar arcos como propagando
      for (var arco in vArco) {
        if (arco.partida.capa == capa && arco.llegada.capa == capa + 1) {
          arco.propagando = true;
          arco.retropropagando = false;
        }
      }
    });

    // Resetear la animación
    _animationController?.reset();

    // Animar la propagación
    await _animationController?.forward();

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

      // Desmarcar arcos de propagación hacia adelante
      for (var arco in vArco) {
        arco.propagando = false;
      }
    });
  }

  Future<void> iniciarRetropropagacion() async {
    setState(() {
      retropropagandoActual = true;
    });

    // Calcular errores en la capa de salida
    calcularErroresSalida();

    // Retropropagar desde la última capa hasta la primera
    for (int capa = numeroCapas - 2; capa >= 0; capa--) {
      await retropropagarCapa(capa);

      // Actualizar pesos DURANTE cada capa de retropropagación
      actualizarPesosCapa(capa);

      await Future.delayed(Duration(milliseconds: 500)); // Tiempo para ver los cambios
    }

    setState(() {
      retropropagandoActual = false;
    });
  }

  void calcularErroresSalida() {
    List<ModeloNodo> nodosSalida = vNodo.where((n) => n.capa == numeroCapas - 1).toList();

    for (int i = 0; i < nodosSalida.length && i < objetivos.length; i++) {
      double salida = nodosSalida[i].valorActivacion;
      double objetivo = objetivos[i];
      double error = objetivo - salida;

      // Error delta para función sigmoide: error * salida * (1 - salida)
      nodosSalida[i].error = error * salida * (1 - salida);

      print('📊 Nodo de salida ${nodosSalida[i].etiqueta}:');
      print('   Objetivo: ${objetivo.toStringAsFixed(4)}');
      print('   Salida real: ${salida.toStringAsFixed(4)}');
      print('   Error calculado: ${nodosSalida[i].error.toStringAsFixed(4)}');
    }
  }

  Future<void> retropropagarCapa(int capa) async {
    // Calcular errores para nodos de la capa actual
    calcularErroresCapa(capa);

    setState(() {
      // Marcar arcos como retropropagando (dirección inversa)
      for (var arco in vArco) {
        if (arco.partida.capa == capa && arco.llegada.capa == capa + 1) {
          arco.retropropagando = true;
          arco.propagando = false;
        }
      }
    });

    // Resetear la animación de retropropagación
    _backpropController?.reset();

    // Animar la retropropagación
    await _backpropController?.forward();

    // Esperar un poco para que se vea la animación
    await Future.delayed(Duration(milliseconds: 200));

    setState(() {
      // Desmarcar arcos de retropropagación
      for (var arco in vArco) {
        arco.retropropagando = false;
      }
    });
  }

  void calcularErroresCapa(int capa) {
    for (var nodo in vNodo) {
      if (nodo.capa == capa) {
        double sumaError = 0.0;
        int conexiones = 0;

        // Sumar errores ponderados de la capa siguiente
        for (var arco in vArco) {
          if (arco.partida == nodo && arco.llegada.capa == capa + 1) {
            sumaError += arco.llegada.error * arco.peso;
            conexiones++;
          }
        }

        // Calcular el error delta
        double salida = nodo.valorActivacion;
        nodo.error = sumaError * salida * (1 - salida);

        print('🔄 Error capa $capa - Nodo ${nodo.etiqueta}: ${nodo.error.toStringAsFixed(4)} (${conexiones} conexiones)');
      }
    }
  }

  void actualizarPesosCapa(int capa) {
    setState(() {
      // Actualizar solo los pesos de los arcos de la capa actual
      for (var arco in vArco) {
        if (arco.partida.capa == capa && arco.llegada.capa == capa + 1) {
          // Guardar el peso anterior
          double pesoAnterior = arco.peso;

          // Calcular el cambio de peso usando la regla delta
          double deltaW = tasaAprendizaje * arco.llegada.error * arco.partida.valorActivacion;

          // Aplicar el cambio
          arco.peso += deltaW;

          // Limitar pesos entre -3 y 3 para mayor rango
          arco.peso = arco.peso.clamp(-3.0, 3.0);

          // Debug: mostrar cambios significativos
          if (deltaW.abs() > 0.001) {
            print('🔄 Peso actualizado - Arco ${arco.partida.etiqueta}→${arco.llegada.etiqueta}:');
            print('   Anterior: ${pesoAnterior.toStringAsFixed(4)}');
            print('   Nuevo: ${arco.peso.toStringAsFixed(4)}');
            print('   ΔW: ${deltaW.toStringAsFixed(4)}');
            print('   Error nodo destino: ${arco.llegada.error.toStringAsFixed(4)}');
            print('   Activación nodo origen: ${arco.partida.valorActivacion.toStringAsFixed(4)}');
            print('---');
          }
        }
      }
    });
  }

  void actualizarPesos() {
    setState(() {
      for (var arco in vArco) {
        // Guardar el peso anterior para mostrar el cambio
        double pesoAnterior = arco.peso;

        // Actualizar peso usando la regla delta
        double deltaW = tasaAprendizaje * arco.llegada.error * arco.partida.valorActivacion;
        arco.peso += deltaW;

        // Limitar pesos entre -2 y 2
        arco.peso = arco.peso.clamp(-2.0, 2.0);

        // Mostrar información del cambio (opcional para debug)
        print('Arco ${arco.partida.etiqueta}->${arco.llegada.etiqueta}: ${pesoAnterior.toStringAsFixed(3)} -> ${arco.peso.toStringAsFixed(3)} (Δ: ${deltaW.toStringAsFixed(3)})');
      }
    });
  }

  void asignarPesosAleatorios() {
    setState(() {
      for (var arco in vArco) {
        // Pesos iniciales más grandes para cambios más visibles
        arco.peso = (Random().nextDouble() * 4 - 2); // Pesos entre -2 y 2
      }
    });

    print('🎲 Pesos aleatorios asignados:');
    for (var arco in vArco) {
      print('   ${arco.partida.etiqueta} → ${arco.llegada.etiqueta}: ${arco.peso.toStringAsFixed(3)}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      appBar: AppBar(
        title: Text('R.N.A. - Perceptrón con Retropropagación'),
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
              child: Column(
                children: [
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: iniciarPropagacion,
                        icon: Icon(Icons.play_arrow),
                        label: Text('Entrenar 1 Época'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: () async {
                          for (int i = 0; i < 3; i++) {
                            print('\n🔄 ===== ÉPOCA ${i + 1} =====');
                            iniciarPropagacion();
                            await Future.delayed(Duration(milliseconds: 1000));
                          }
                        },
                        icon: Icon(Icons.repeat),
                        label: Text('Entrenar 3 Épocas'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
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
                      Spacer(),
                      Text('Tasa de Aprendizaje: ', style: TextStyle(fontSize: 14)),
                      Container(
                        width: 80,
                        child: TextField(
                          controller: TextEditingController(text: tasaAprendizaje.toString()),
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          ),
                          onChanged: (value) {
                            setState(() {
                              tasaAprendizaje = double.tryParse(value) ?? 0.1;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  if (retropropagandoActual)
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                            ),
                          ),
                          SizedBox(width: 10),
                          Text('Ejecutando retropropagación (círculos rojos)...',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade700)),
                        ],
                      ),
                    ),
                  // Información adicional sobre el proceso
                  Container(
                    margin: EdgeInsets.only(top: 5),
                    child: Text(
                      'Forward Pass: Círculos amarillos → | Backward Pass: Círculos rojos ←',
                      style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey.shade700),
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
                  animation: Listenable.merge([
                    _animation ?? AlwaysStoppedAnimation(0.0),
                    _backpropAnimation ?? AlwaysStoppedAnimation(0.0),
                  ]),
                  builder: (context, child) {
                    return Stack(
                      children: [
                        CustomPaint(
                          painter: Arco(vArco,
                            animacionProgreso: _animation?.value ?? 0.0,
                            backpropProgreso: _backpropAnimation?.value ?? 0.0,
                          ),
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