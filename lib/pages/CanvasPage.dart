import 'package:flutter/material.dart';

class CanvasPage extends StatelessWidget {
  
  //const CanvasPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFffffff),
        centerTitle: true,
        title: Text("TRAZOS challenger | canvas",
            style: TextStyle(color: Colors.blueAccent)),
        elevation: 0,
        actions: [],
      ),
      body: Container(
        child: Column(
          children: [
            
            Container(
                padding: EdgeInsets.only(left: 15, top: 10),
                child: Text("Canvas")
            ),

          ],
        ),
      ),
    );
  }
}