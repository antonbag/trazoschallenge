import 'package:flutter/material.dart';

final _icons = <String, IconData> {
  "plus_one": Icons.plus_one,
  "tune": Icons.tune, 
  "folder_open": Icons.folder_open,
  "movies": Icons.movie_sharp
};



Icon getIcon(String nombreIcono, String colorIcono) {
  return Icon(_icons[nombreIcono], color: Color(int.parse(colorIcono)));
}
