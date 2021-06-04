import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

final menuProvider = new _MenuProvider();

class _MenuProvider {
  List<dynamic> opciones = [];

  Future<List<dynamic>> cargarData() async {
    final resp = await rootBundle.loadString('assets/data/home_menu.json');

    print(resp);

    Map dataMap = json.decode(resp);

    opciones = dataMap['rutas'];

    final List<dynamic> cosa = [];

    return cosa;
  }
}
