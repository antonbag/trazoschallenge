import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trazosv1/routes/routes.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return MaterialApp(
      title: 'TRAZOS v1',
      debugShowCheckedModeBanner: false,
      //home: PeliculaDetalle(),
      initialRoute: '/',
      routes: getApplicationsRoutes(),
      
    );
    
  }
  
}
