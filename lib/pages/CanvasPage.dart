import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter_signature_pad/flutter_signature_pad.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:trazosv1/providers/globalData.dart';
import 'package:trazosv1/utils/dataTools.dart';

import 'package:web_socket_channel/web_socket_channel.dart';

final String wsAddress =
    'ws://' + GlobalData.serverURL + ':' + GlobalData.serverPORT;

AppBar canvasAppBar = AppBar(
  backgroundColor: GlobalData.getCurrentColor(),
  centerTitle: true,
  title: Text("TRAZOS challenger | canvas",
      style: TextStyle(color: Color(0xFFffffff))),
  elevation: 0,
  actions: [],
);

/// ******** STATEFUL
class CanvasPage extends StatefulWidget {
  //const CanvasPage({Key key}) : super(key: key);
  @override
  _CanvasPageState createState() => _CanvasPageState();
}

/// ****************************************************************************
/// ************************** CANVAS_STATE ************************************
/// ****************************************************************************

class _CanvasPageState extends State<CanvasPage> {
  bool _envioDesactivado = true;
  bool _puedoDibujar = true;
  bool _gyroTime = false;

  int _currentTime = 5;

  bool _initTimer = false;

  /// *******************
  /// ********* CANVAS
  /// *******************
  ByteData _img = ByteData(0);
  var color = GlobalData.getCurrentColor();
  var strokeWidth = 15.0;
  final _sign = GlobalKey<SignatureState>();

  /// *******************
  /// ********* SOCKET
  /// *******************
  /// Aquí ya tenemos el socket final, por lo que no hace falta el circo de comprobar ws
  final _channel = WebSocketChannel.connect(
    Uri.parse(wsAddress),
  );
  //funcion de envio demensajes
  void _sendMessage(Map<String, dynamic> msg) {
    _channel.sink.add(jsonEncode(msg));
  }

  /// *******************
  /// ********* SENSORS
  /// *******************
  /*
  List<double>? _accelerometerValues;
  List<double>? _userAccelerometerValues;
  */
  List<double>? _gyroscopeValues;
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];
  double _gyroValueZ = 0;

  /// *******************
  /// *******************
  /// ********* BUILD
  /// *******************
  /// *******************
  @override
  Widget build(BuildContext context) {
    /*     
    /// ********* SENSORS
    /// * no me hacen falta por ahora
    final gyroscope = _gyroscopeValues?.map((double v) => v.toStringAsFixed(1)).toList();
    final accelerometer =
    _accelerometerValues?.map((double v) => v.toStringAsFixed(1)).toList();
    final userAccelerometer = _userAccelerometerValues ?.map((double v) => v.toStringAsFixed(1)).toList(); */

    return Scaffold(
      appBar: canvasAppBar,
      body: Column(
        children: <Widget>[
          !_gyroTime
              ? Container()
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text('Gyroscope Z: $_gyroValueZ'),
                    ],
                  ),
                ),

          //columna expandida
          !_puedoDibujar
              ? Container(
                  child: Container(
                      /*child:Column(
                  children: [
                    Image.network("https://i.kym-cdn.com/entries/icons/facebook/000/014/158/YouHavNoPowerHere-cropped.jpg"),
                    Text("No puedes dibujar"),
                  ],
                )*/
                      ))
              : Expanded(
                  child: Container(
                    color: Colors.grey[100],

                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Signature(
                        color: color,
                        key: _sign,
                        onSign: !_puedoDibujar
                            ? null
                            : () {
                                final sign = _sign.currentState;
                                //print( '${sign!.points}');
                                debugPrint('${sign!.points.length} puntos');

                                setState(() {
                                  _envioDesactivado = false;
                                  _initTimer = true;
                                });
                              },
                        backgroundPainter: _WatermarkPaint("1.0", "1.0"),
                        strokeWidth: strokeWidth,
                      ),
                    ),
                    //color: Colors.black12,
                  ),
                ),
          _img.buffer.lengthInBytes == 0
              ? Container()
              : Expanded(
                  //maxHeight: 200.0,
                  child: Transform(
                      transform: Matrix4.rotationZ(_gyroValueZ),
                      alignment: Alignment.center,
                      child: Container(
                          padding: EdgeInsets.all(10),
                          //color: Colors.white,
                          //la imagen de mirilla. Al principio era la propia imagen generada, pero tardaba mucho
                          child: Image.network(
                              "https://image.flaticon.com/icons/png/256/68/68837.png"))
                      //child: Image.memory(_img.buffer.asUint8List())),
                      )),
          Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  /// ********* Papelera
                  papelera(),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(left: 10.0, right: 10.0),

                      /// ********* Enviar button
                      child: MaterialButton(
                          color: Colors.green,
                          onPressed:
                              _envioDesactivado ? null : envioButtonPressed,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.send_rounded),
                              Text("enviar"),
                            ],
                          )),
                    ),
                  ),
                  MaterialButton(
                      onPressed: () => GlobalData.printCurrentServer(),
                      child: contadorDown())
                ],
              ),
              /*
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  MaterialButton(
                      onPressed: () {
                        setState(() {
                          color =
                              color == Colors.green ? Colors.red : Colors.green;
                        });
                        debugPrint("change color");
                      },
                      child: Text("Change color")),
                  MaterialButton(
                      onPressed: () {
                        setState(() {
                          int min = 1;
                          int max = 10;
                          int selection = min + (Random().nextInt(max - min));
                          strokeWidth = selection.roundToDouble();
                          debugPrint("change stroke width to $selection");
                        });
                      },
                      child: Text("Change stroke width")),
                ],
              ),*/
            ],
          )
        ],
      ),
    );
  }

  void envioButtonPressed() async {
    final sign = _sign.currentState;
    final image = await sign!.getData();
    if (sign.points.length == 0) return;
    //espero  a que se codifique
    var data = await image.toByteData(format: ui.ImageByteFormat.png);

    final encoded = base64.encode(data!.buffer.asUint8List());

    _currentTime = 3;

    //ya puedo actualizar el estado
    setState(() {
      _img = data;
      _envioDesactivado = true;
      _puedoDibujar = false;
      _gyroTime = true;
    });

    //final List<String> listado = sign.points;
    //Convierto los puntos a json para enviarlos
    //Al final no lo uso, pero podría ser interesante para algo
    final listadoPuntos = offsetToJson(sign.points);

    final Map<String, dynamic> paraEnviar = {
      'from': 'flutter',
      'player': GlobalData.playerNumber,
      'component': "canvas",
      'task': "trazo",
      'data': encoded,
      'extra': listadoPuntos
    };

    _sendMessage(paraEnviar);

    //comienzo el gyro
    startGyro();

    //borro el canvas
    sign.clear();
    //print all the base64 data
    //printWrapped(encoded);
  }

  //Contador de tiempo para dibujar... el usuario tiene 5 segundos para dibujar.
  Text contadorDown() {
    return Text(_currentTime.toString());
  }


  /// *******************
  /// ********* ███۞███████ ]▄▄▄▄▄▄▄▄▄▄▄▄▃
  /// *▂▄▅█████████▅▄▃▂
  /// *I███████████████████].
  /// *◥⊙▲⊙▲⊙▲⊙▲⊙▲⊙▲⊙◤...
  /// ****PAPELERA*******
  MaterialButton papelera() {
    return MaterialButton(
        color: Colors.white,
        onPressed: papeleraButtonPressed,
        child: Row(
          children: [Icon(Icons.delete_outline_outlined, color: Colors.blue)],
        ));
  }

  void papeleraButtonPressed() {
    final sign = _sign.currentState;

    stopGyro();

    // ignore: unnecessary_statements
    _gyroTime ? null : sign!.clear();

    setState(() {
      _img = ByteData(0);
      _envioDesactivado = true;
      _puedoDibujar = true;
      _gyroTime = false;
      _initTimer = false;
    });

    debugPrint("limpio!");
  }

/*   void printWrapped(String text) {
    final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
    pattern.allMatches(text).forEach((match) => print(match.group(0)));
  } */

  ///* GYRO
  void startGyro() {
    //intento de optimizacin
    // ignore: unused_local_variable
    List<double> _gyroscopeOld = [0.0, 0.0, 0.0];
    double _gyroscopeOldZ = 0.0;
    double _gyroscopeZ = 0.0;

    //Añado a la suscripcion los eventos del gyro

    _streamSubscriptions.add(
      gyroscopeEvents.listen(
        (GyroscopeEvent event) {
          _gyroscopeValues = <double>[event.x, event.y, event.z];

          //solo actualizo cuando hay cambios
          //if (_gyroscopeOld.toString() != _gyroscopeValues.toString()) {

          //mejor solo en Z
          if (_gyroscopeOldZ != event.z) {
            print("old:" + _gyroscopeOldZ.toString());
            print(event.z.toString());
            _gyroscopeZ += event.z;

            print(_gyroValueZ.toString());
            print("en grados!");
            double _gyroInDegrees = (_gyroscopeZ * (180.0 / pi) / 10);
            print(_gyroInDegrees);

            //tendría que hacer un model...
            final Map<String, dynamic> paraEnviar = {
              'from': 'flutter',
              'player': GlobalData.playerNumber,
              'component': "gyro",
              'task': "gira",
              'data': _gyroInDegrees.toString()
            };

            _sendMessage(paraEnviar);

            setState(() {
              _gyroValueZ = _gyroInDegrees;
              //_gyroscopeValues = <double>[event.x, event.y, event.z];
            });
          }

          _gyroscopeOld = _gyroscopeValues!;
        },
      ),
    );
  }

  ///* STOP GYRO (y todo)
  void stopGyro() {
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }

  ///* accelerometerEvents
  /*
    _streamSubscriptions.add(
      accelerometerEvents.listen(
        (AccelerometerEvent event) {
          setState(() {
            _accelerometerValues = <double>[event.x, event.y, event.z];
          });
        },
      ),
    );
    */

  ///* userAccelerometerEvents
  /*
    _streamSubscriptions.add(
      userAccelerometerEvents.listen(
        (UserAccelerometerEvent event) {
          setState(() {
            _userAccelerometerValues = <double>[event.x, event.y, event.z];
          });
        },
      ),
    );
    */

  /// *******************
  /// ********* INITSTATE
  /// *******************
  /// requerido sobretodo por el timer
  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(seconds: 1), (Timer t) {
      int _currentTimeTemp = _currentTime;

      //timeUP!
      if (_currentTimeTemp == 0) {
        print("timeUP");
        _currentTimeTemp = 5;

        _gyroTime ? papeleraButtonPressed() : envioButtonPressed();
      }
      //Si el temporizador esta activado, resto, si no, 5 seg
      _initTimer ? _currentTimeTemp -= 1 : _currentTimeTemp = 5;
      if (mounted) {
        setState(() {
          _currentTime = _currentTimeTemp;
        });
      }
    });
  }

  /// *******************
  /// ********* DISPOSESTATE
  /// *******************
  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();

    /// *Cierro las _streamSubscriptions de los sensores
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }
}


  /// *******************
  /// ********* DIBUJINOS
  /// *******************
class _WatermarkPaint extends CustomPainter {
  final String price;
  final String watermark;

  _WatermarkPaint(this.price, this.watermark);

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    /*
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 10.8,
        Paint()..color = Colors.blue);*/
  }

  @override
  bool shouldRepaint(_WatermarkPaint oldDelegate) {
    print("ShouldRepaint!");
    return oldDelegate != this;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _WatermarkPaint &&
          runtimeType == other.runtimeType &&
          price == other.price &&
          watermark == other.watermark;

  @override
  int get hashCode => price.hashCode ^ watermark.hashCode;
}
