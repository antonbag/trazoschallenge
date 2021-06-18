import 'package:flutter/material.dart';
import 'package:trazosv1/pages/HomePage.dart';
import 'package:trazosv1/pages/CanvasPage.dart';
import 'package:trazosv1/pages/QrPage.dart';
import 'package:trazosv1/pages/gyroPage.dart';

Map<String, WidgetBuilder> getApplicationsRoutes() {

  Map<String, WidgetBuilder> listadoRutas = {
    'home'  : (BuildContext context) => HomePage(),
    '/': (BuildContext context) => CanvasPage(),
    'gyro'  : (BuildContext context) => GyroPage(),
    'qr'  : (BuildContext context) => QrPage(),
  };
  
  return listadoRutas;
}
