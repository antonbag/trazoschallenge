import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:trazosv1/providers/globalData.dart';
import 'CanvasPage.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

final String wsAddress =
    'ws://' + GlobalData.serverURL + ':' + GlobalData.serverPORT;

AppBar qrAppBar = AppBar(
  backgroundColor: Color(0xFFffffff),
  centerTitle: true,
  title:
      Text("TRAZOS challenge | QR", style: TextStyle(color: Colors.blueAccent)),
  elevation: 0,
  actions: [],
);

class QrPage extends StatelessWidget {
  //const QrPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: QrBuilder(title: 'QR reader'));
  }
}

//*STATEFUL WIDGET
class QrBuilder extends StatefulWidget {
  QrBuilder({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _QrBuilderState createState() => _QrBuilderState();
}

//*QR STATE
class _QrBuilderState extends State<QrBuilder> {
  //resultado del escaneo
  //ScanResult? _scanResult;

  bool _hayDatos = false;
  bool _datosCorrectos = false;
  bool _wsOpened = false;

  final botonFightStyle = ElevatedButton.styleFrom(
      primary: Colors.orange, textStyle: const TextStyle(fontSize: 50));
  final botonScanStyleActivado = ElevatedButton.styleFrom(
      primary: Colors.green, textStyle: const TextStyle(fontSize: 50));
  final botonScanStyleDesactivado = ElevatedButton.styleFrom(
      primary: Colors.grey, textStyle: const TextStyle(fontSize: 20));

  /// *******************
  /// ********* SOCKET
  /// *******************
  WebSocketChannel? _channel;

  //en realidad no creo que haga falta un future para esto, pero así me acostumbro a la sintaxis
  _sendMessage(Map<String, dynamic> msg) {
    //si el canal no esta abierto mantengo la variable _wsOpened en false
    _channel == null ? _wsOpened = false : _channel!.sink.add(jsonEncode(msg));
    print("send_mensaje ok");
    return true;
  }

  @override
  Widget build(BuildContext context) {
    /*
    final Map<String, dynamic> chocalaMsg = {
      'from': 'flutter',
      'player': GlobalData.playerNumber,
      'component': "qr",
      'task': "hola",
      'data': ""
    };

    cambiaSocket()
      .then((value) => () {
            _sendMessage(chocalaMsg);
          })
      .then((value) => () {
            setState(() {
              print("hay datos!!");
              _hayDatos = true;
            });
            print("hay datos:"+_hayDatos.toString());
    });
    */

    return Scaffold(
      appBar: qrAppBar,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          //instrucciones o info del jugador si no hay datos
          _hayDatos == false ? Instrucciones() : InfoPlayer(),

          _wsOpened == false
              ? Container(
                  //child: Text("_wsOpened:" + _wsOpened.toString()),
                  )
              : StreamBuilder(
                  stream: _channel!.stream,
                  builder: (context, snapshot) {
                    print(snapshot.hasData.toString());
                    if (snapshot.hasData) {
                      final saludoData = json.decode(snapshot.data.toString());
                      saludoData!["status"] == "ok"
                          ? _datosCorrectos = true
                          : _datosCorrectos = false;

                      //devuelvo el stream
                      return _datosCorrectos == false
                          ? Container(
                              child: Text(saludoData!["mensaje"]),
                            )
                          : Column(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 4, bottom: 32),
                                  child: Container(
                                    child: Text(saludoData!["mensaje"]),
                                  ),
                                ),
                                ElevatedButton(
                                    style: botonFightStyle,
                                    onPressed: () {
                                      final Map<String, dynamic> fightMsg = {
                                        'from': 'flutter',
                                        'player': GlobalData.playerNumber,
                                        'component': "qr",
                                        'task': "fight",
                                        'data': ""
                                      };

                                      final route = MaterialPageRoute(
                                          builder: (context) => CanvasPage());

                                      //registro player
                                      _sendMessage(fightMsg);
                                      print("Vamos al canvas...");
                                      Navigator.push(context, route);
                                    },
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.gamepad),
                                          Text("FIGHT"),
                                        ],
                                    )),
                              ],
                            );

                      //return Text(snapshot.hasData ? saludoData!["mensaje"] : '');
                    }
                    return Container(
                        child: Text(
                          "No puedo conectar a " + GlobalData.serverURL));
                  },
                ),
          develModeButton(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
                alignment: Alignment.center,
                child: ElevatedButton(
                    style: _hayDatos == false
                        ? botonScanStyleActivado
                        : botonScanStyleDesactivado,
                    onPressed: () {
                      //print("escanea!");
                      _scanCode();
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.qr_code),
                        _hayDatos == false
                            ? Text("ESCANEA", style: TextStyle(fontSize: 18))
                            : Text("Otra vez", style: TextStyle(fontSize: 12)),
                      ],
                    ))),
          ),
/*           Container(
            child: ElevatedButton(
                onPressed: () {
                  final Map<String, dynamic> chocalaMsg = {
                    'from': 'flutter',
                    'player': GlobalData.playerNumber,
                    'component': "qr",
                    'task': "hola",
                    'data': ""
                  };

                  _sendMessage(chocalaMsg);
                },
                child: Text("prueba server")),
          ), */
        ],
      ),
    );
  }

  Widget develModeButton() {
    if (GlobalData.devel) {
      GlobalData.serverURL = "84.126.227.189";
      GlobalData.playerNumber = 1;
    }

    return GlobalData.devel == false
        ? Container()
        : Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
                alignment: Alignment.center,
                child: ElevatedButton(
                    onPressed: () {
                      //mi ip publica
                      /*
                      final route =
                          MaterialPageRoute(builder: (context) => CanvasPage());
                      Navigator.push(context, route);
                      */

                      //*CHÓCALA
                      //*llamo al server para cerciorarme de que todo esta bien
                      final Map<String, dynamic> chocalaMsg = {
                        'from': 'flutter',
                        'player': GlobalData.playerNumber,
                        'component': "qr",
                        'task': "hola",
                        'data': ""
                      };

                      cambiaSocket().then((value) => () {
                            _sendMessage(chocalaMsg);
                            GlobalData.printCurrentServer();
                          });
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.developer_mode),
                            Text(
                                "Devel:" +
                                    GlobalData.serverURL +
                                    ":" +
                                    GlobalData.serverPORT,
                                style: TextStyle(fontSize: 10)),
                          ],
                        ),
                        Row(
                          children: [
                            Text("Player:" + GlobalData.playerNumber.toString(),
                                style: TextStyle(fontSize: 10)),
                          ],
                        ),
                        Row(
                          children: [
                            Text("_haydatos:" + _hayDatos.toString(),
                                style: TextStyle(fontSize: 10)),
                          ],
                        )
                      ],
                    ))),
          );
  }

  /// ********* Cierro el canal cuando me voy
  @override
  void dispose() {
    _channel!.sink.close();
    super.dispose();
  }










  Future<void> _scanCode() async {
    print(' Programa lanzado');
    // Lanzamos la función BarcodeScanner.scan y esperamos
    var result = await BarcodeScanner.scan();
    print('Mostrando resultados');

    GlobalData.printCurrentServer();

    //Separo la url del jugador
    List explosion = result.rawContent.split(";");

    //cambio los datos del servidor explosion[0] = ip:puerto
    GlobalData.changeServerAndPort(explosion[0]);

    //cambio los datos del player explosion[1] = goal1
    GlobalData.changePlayer(explosion[1]);

    GlobalData.printCurrentServer();

/*  print(result.type); // Tipo de resultado: barcode, cancelled, failed
    print(result.rawContent); // Contenido del barcode
    print(result.format); // Formato del barcode
    print(result
        .formatNote); */ // Formato If a unknown format was scanned this field contain

    //en realidad no creo que haga falta future... pero así me acostumbro a su sintaxis
    cambiaSocket().then((value) => () {
      print('QR terminado');
    });
  }

  //CAMBIA SOCKET

  Future cambiaSocket() async {
    _channel = WebSocketChannel.connect(Uri.parse(wsAddress));
    print("cambia socket!...");

    final Map<String, dynamic> chocalaMsg = {
      'from': 'flutter',
      'player': GlobalData.playerNumber,
      'component': "qr",
      'task': "hola",
      'data': ""
    };
    await _sendMessage(chocalaMsg);
    print("mensaje de bienvenida enviado");
    setState(() {
      //*cambio el estado
      _hayDatos = true;
      _wsOpened = true;
    });
    return true;
  }
}

//*******************
// * INSTRUCCIONES
// ******************
class Instrucciones extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          child: Text(
            "INSTRUCCIONES",
            style: TextStyle(fontSize: 18),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            alignment: Alignment.center,
            child: Text("Escanea el código para comenzar a jugar... etc"),
          ),
        ),
        const Divider(),
      ],
    );
  }
}

//*******************
// * INFO
// ******************
class InfoPlayer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          child: coloreaTexto(GlobalData.playerNumber),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(),
        ),
        //const Divider(),
      ],
    );
  }

  Widget coloreaTexto(int playerNumber) {
    if (GlobalData.playerNumber == 1) {
      return Text("PLAYER " + GlobalData.playerNumber.toString(),
          style: TextStyle(fontSize: 50, color: GlobalData.player1Color));
    }
    if (GlobalData.playerNumber == 2) {
      return Text("PLAYER " + GlobalData.playerNumber.toString(),
          style: TextStyle(fontSize: 50, color: GlobalData.player2Color));
    }
    return Container();
  }
}
