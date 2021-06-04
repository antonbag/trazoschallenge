import 'package:flutter/material.dart';
import 'package:trazosv1/pages/HomePage.dart';

Map<String, WidgetBuilder> getApplicationsRoutes() {

  


  return <String, WidgetBuilder>{
    '/': (BuildContext context) => HomePage(),
  };
  
}