import 'package:flutter/material.dart';


/// * CONVERT offset points to List (to json)
List offsetToJson(List<Offset?> objecto) {
  List listaFinal = [];

  objecto.forEach((ele) {
    final currentOffsetValue = [ele?.dx, ele?.dy];

    if(ele?.dx != null) listaFinal.add(currentOffsetValue);
  });

  return listaFinal;
}
