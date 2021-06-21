import 'package:flutter/material.dart';
import 'package:trazosv1/pages/HomePage.dart';
import 'package:trazosv1/pages/CanvasPage.dart';
import 'package:trazosv1/pages/QrPage.dart';


Map<String, WidgetBuilder> getApplicationsRoutes() {

  Map<String, WidgetBuilder> listadoRutas = {
    'home'  : (BuildContext context) => HomePage(),
    'canvas': (BuildContext context) => CanvasPage(),
    //al final he integrado el gyro en canvas... no se si para bien o para mal
    //'gyro'  : (BuildContext context) => GyroPage(),
    '/'  : (BuildContext context) => QrPage(),
  };
  
  return listadoRutas;
}
