import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';



class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFffffff),
        centerTitle: true,
        title: Text("TRAZOS v1 | AVM 21",
            style: TextStyle(color: Colors.blueAccent)),
        elevation: 0,
        actions: [],
      ),
      body: Container(
        child: Column(
          children: [
            Container(
                padding: EdgeInsets.only(left: 15, top: 10),
                child: IconButton(
                    icon: Icon(Icons.search),
                    color: Colors.blueAccent,
                    onPressed: () {})
            ),

          ],
        ),
      ),
    );

/*     return Container(
      child: AppBar(
        title: Text("hola"),
        body: Container(alignment: Alignment.center,child: Text("ldasdf"),)
      ),
    ); */
  }
}
