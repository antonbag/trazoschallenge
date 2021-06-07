import 'package:flutter/material.dart';

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
  double xPos = 0.0;
  double yPos = 0.0;
  final _width = 100.0;
  final _height = 100.0;

  bool _dragging = false;

  List<List<double>> coords = [];



  /// Inside rect?
  ///

  /*bool _indiesRect(double x, double y) =>
    x >= xPos && x <= xPos + _width && y >= yPos && y <= yPos + _height;
*/
  bool _indiesRect(double x, double y) {
    if (x >= xPos && x <= xPos + _width && y >= yPos && y <= yPos + _height) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: canvasAppBar,
        /*body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: CustomPaint(painter: PintadorPral()),
      ),*/
        body: GestureDetector(
          /// **PAN START
          onPanStart: (details) {
            /*  print(_indiesRect(
                details.globalPosition.dx, details.globalPosition.dy)); */

            _dragging = _indiesRect(
                details.globalPosition.dx, details.globalPosition.dy);
            _dragging = true;
          },

          /// **PAN END
          onPanEnd: (details) {
            _dragging = false;
            print(coords);
          },
          onTap: () {
            print(_dragging);
          },
          onPanUpdate: (details) {

            List<double> coor = [details.localPosition.dx, details.localPosition.dy];


            if (_dragging) {

              //no se todavia muy bien el setState
              //setState(() {
              xPos += details.delta.dx;
              yPos += details.delta.dy;

              coords.add(coor);
              print(details.localPosition.dx);
              //});
            }
          },
          child: Container(
              color: Color(0xffdddddd),
              alignment: Alignment.center,
              child: CustomPaint()
          ),
        ));
  }
}

class PintadorPral extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint1 = Paint()
      ..color = Color(0xff123456)
      ..style = PaintingStyle.fill
      ..strokeWidth = 10;

    //canvas.drawCircle(Offset(100, 100), 10, paint1);
    canvas.drawArc(
        Rect.fromCenter(center: Offset(100, 10), width: 100, height: 100),
        100,
        10,
        false,
        paint1);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    throw UnimplementedError();
  }
}
