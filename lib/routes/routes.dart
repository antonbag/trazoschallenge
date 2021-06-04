import 'package:flutter/material.dart';
import 'package:trazosv1/pages/HomePage.dart';
import 'package:trazosv1/pages/CanvasPage.dart';
import 'package:trazosv1/pages/gyroPage.dart';


Map<String, WidgetBuilder> getApplicationsRoutes() {

  
  return <String, WidgetBuilder>{
    '/': (BuildContext context) => HomePage(),
    'canvas': (BuildContext context) => CanvasPage(),
    'gyro': (BuildContext context) => GyroPage(),
  };
  
}