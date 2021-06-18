import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:trazosv1/providers/globalData.dart';
import 'CanvasPage.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

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

  final botonFightStyle = ElevatedButton.styleFrom(
      primary: Colors.orange, textStyle: const TextStyle(fontSize: 50));
  final botonScanStyleActivado = ElevatedButton.styleFrom(
      primary: Colors.green, textStyle: const TextStyle(fontSize: 50));
  final botonScanStyleDesactivado = ElevatedButton.styleFrom(
      primary: Colors.grey, textStyle: const TextStyle(fontSize: 20));

  /// *******************
  /// ********* SOCKET
  /// *******************
  final _channel = WebSocketChannel.connect(
    Uri.parse(wsAddress),
  );

  void _sendMessage(Map<String, dynamic> msg) {
    _channel.sink.add(jsonEncode(msg));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: qrAppBar,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          //instrucciones o info del jugador si no hay datos
          _hayDatos == false ? Instrucciones() : InfoPlayer(),

          StreamBuilder(
            stream: _channel.stream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final saludoData = json.decode(snapshot.data.toString());
                saludoData!["status"] == "ok"
                    ? _datosCorrectos = true
                    : _datosCorrectos = false;
                
                //devuelvo el stream
                return 
                  _datosCorrectos == false
                  ? Container(child: Text(saludoData!["mensaje"]),)
                  : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 4, bottom: 32),
                        child: Container(child: Text(saludoData!["mensaje"]),),
                      ),
                      ElevatedButton(
                          style: botonFightStyle,
                          onPressed: () {
                            final route =
                                MaterialPageRoute(builder: (context) => CanvasPage());
                            Navigator.push(context, route);
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.gamepad),
                              Text("FIGHT"),
                            ],
                          )),
                    ],
                  );

                //return Text(snapshot.hasData ? saludoData!["mensaje"] : '');
              }
              return Container();
            },
          ),
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

  /// ********* Cierro el canal cuando me voy
  @override
  void dispose() {
    _channel.sink.close();
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

/*     print(result.type); // Tipo de resultado: barcode, cancelled, failed
    print(result.rawContent); // Contenido del barcode
    print(result.format); // Formato del barcode
    print(result
        .formatNote); */ // Formato If a unknown format was scanned this field contain

    //*CHÓCALA
    //*llamo al server para cerciorarme de que todo esta bien
    final Map<String, dynamic> chocalaMsg = {
      'from': 'flutter',
      'player': GlobalData.playerNumber,
      'component': "qr",
      'task': "hola",
      'data': ""
    };
    _sendMessage(chocalaMsg);

    setState(() {
      //*cambio el estado
      _hayDatos = true;
    });

    print('QR terminado');
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
            child: Text("Escanea el código para comenzar a jugar...etc"),
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
