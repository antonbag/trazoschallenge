import 'package:flutter/material.dart';
import 'package:trazosv1/providers/globalData.dart';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_signature_pad/flutter_signature_pad.dart';
import 'package:trazosv1/utils/dataTools.dart';

import 'package:web_socket_channel/web_socket_channel.dart';

final String wsAddress =
    'ws://' + globalData.serverURL + ':' + globalData.serverPORT;

AppBar canvasAppBar = AppBar(
  backgroundColor: Color(0xFFffffff),
  centerTitle: true,
  title: Text("TRAZOS challenger | canvas",
      style: TextStyle(color: Colors.blueAccent)),
  elevation: 0,
  actions: [],
);

/// ******** STATEFUL

class CanvasPage extends StatefulWidget {
  //const CanvasPage({Key key}) : super(key: key);
  @override
  _CanvasPageState createState() => _CanvasPageState();
}

class _CanvasPageState extends State<CanvasPage> {
  ByteData _img = ByteData(0);
  var color = Colors.blue;
  var strokeWidth = 15.0;
  final _sign = GlobalKey<SignatureState>();

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
      appBar: canvasAppBar,
      body: Column(
        children: <Widget>[
          //columna expandida
          Expanded(
            child: Container(
              color: Colors.grey[100],

              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Signature(
                  color: color,
                  key: _sign,
                  onSign: () {
                    final sign = _sign.currentState;
                    //print( '${sign!.points}');
                    debugPrint(
                        '${sign!.points.length} points in the signature');
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
              : SizedBox(
                  //maxHeight: 200.0,
                  child: Container(
                      padding: EdgeInsets.all(0),
                      color: Colors.amber,
                      child: Image.memory(_img.buffer.asUint8List()))),
          Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  MaterialButton(
                      color: Colors.white,
                      onPressed: () {
                        final sign = _sign.currentState;

                        sign!.clear();
                        setState(() {
                          _img = ByteData(0);
                        });
                        debugPrint("cleared");
                      },
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline_outlined,
                              color: Colors.blue)
                        ],
                      )),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(left: 10.0, right: 10.0),
                      child: MaterialButton(
                          color: Colors.green,
                          onPressed: () async {
                            final sign = _sign.currentState;

                            //retrieve image data, do whatever you want with it (send to server, save locally...)
                            final image = await sign!.getData();
                            var data = await image.toByteData(
                                format: ui.ImageByteFormat.png);

                            final encoded =
                                base64.encode(data!.buffer.asUint8List());

                            setState(() {
                              _img = data;
                            });

                            //final List<String> listado = sign.points;
                            final listadoPuntos = offsetToJson(sign.points);
                            

                            final Map<String, dynamic> paraEnviar = {
                              'client': globalData.clientNumber,
                              'component': "canvas",
                              'tipo': "base64",
                              'data': encoded,
                              'extra': listadoPuntos
                            };

                            _sendMessage(paraEnviar);

                            debugPrint("onPressed " + encoded);

                            sign.clear();
                            //print all the base64 data
                            //printWrapped(encoded);
                          },
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
                      onPressed: () => globalData.printCurrentServer(),
                      child: Text("5"))
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

  void printWrapped(String text) {
    final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
    pattern.allMatches(text).forEach((match) => print(match.group(0)));
  }

  /// ********* Cierro el canal cuando me voy
  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }
}

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
