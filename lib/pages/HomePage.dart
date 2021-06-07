import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:trazosv1/providers/home_menu_provider.dart';
import 'package:trazosv1/utils/str_to_icon.dart';

AppBar homeAppBar = AppBar(
  backgroundColor: Color(0xFFffffff),
  centerTitle: true,
  title: Text("TRAZOS v1 | AVM 21", style: TextStyle(color: Colors.blueAccent)),
  elevation: 0,
  actions: [],
);

/// ***************************** */
/// ***************************** */
/// LISTA DESDE JSON
/// ***************************** */
/// ***************************** */

//Listado de opciones en el homePage
//el cuerpo del scaffold llama a lista
Widget _lista() {
  //es un Futurebuilder porque llama a cosas asyncronas
  return FutureBuilder(
      future: menuProvider.cargarHomeData(),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        //print('builder!');
/*         return GridView.count(
          scrollDirection: Axis.vertical,
          crossAxisCount: 2,
          children: _listaItems(snapshot.data!, context),
        ); */
 
        return ListView(
          scrollDirection: Axis.vertical, 
          children: _listaItems(snapshot.data!, context),
        );
      });
}

List<Widget> _listaItems(List<dynamic> datos, BuildContext context) {
  final List<Widget> listado = [];

  datos.forEach((opt) {
    final widgetTemp = ListTile(
        title: Text(opt['texto'], style: Theme.of(context).textTheme.headline5),
        leading: getIcon(opt['icon'], opt['color']),
        trailing: Icon(Icons.arrow_forward_outlined, color: Colors.amber),
        onTap: () {
          //final route = MaterialPageRoute(builder: (context) => CounterPage());
          Navigator.pushNamed(context, opt['ruta']);
        });

    listado..add(widgetTemp)..add(Divider());
  });

  return listado;
}

/// ***************************** */
/// MAIN CLASS
/// ***************************** */

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: homeAppBar, body: _lista());

/*     return Container(
      child: AppBar(
        title: Text("hola"),
        body: Container(alignment: Alignment.center,child: Text("ldasdf"),)
      ),
    ); */
  }
}
