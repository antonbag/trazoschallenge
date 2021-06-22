import 'dart:ui';

import 'package:flutter/material.dart';

/// * datos globales para llamar desde diferentes pages

class GlobalData {
  static const Color player0Color = Color(0xff307139);
  static const Color player1Color = Color(0xff0272c3);
  static const Color player2Color = Color(0xffb30303);

  static int playerNumber = 0;

  static bool devel = false;

  //https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=192.168.1.50:4445-goal1

  static var serverURL = "10.0.2.2";
  static var serverPORT = "4445";

  //static var wsAddress = serverURL;

  static printCurrentServer() {
    print("**************CURRENT SERVER *********** ");
    print(serverURL +
        ":" +
        serverPORT +
        " --- Player:" +
        playerNumber.toString());
  }

  static changeServer(String newServerURL) {
    serverURL = newServerURL;
  }

  static changePort(String newServerPORT) {
    serverPORT = newServerPORT;
  }

  static changeServerAndPort(String completeAddress) {
    //serverPORT = newServerPORT;

    print("changeServerAndPort");
    print(completeAddress);


    if (completeAddress == "") {
      return;
    }
    List explosion = completeAddress.split(":");

    serverURL = explosion[0];
    serverPORT = explosion[1];

    //development fix
    if (serverURL == "localhost") serverURL = "10.0.2.2";
    if (serverURL == "127.0.0.1") serverURL = "10.0.2.2";
  }

  static changePlayer(String player) {
    if (player == "goal1") {
      playerNumber = 1;
    }
    if (player == "goal2") {
      playerNumber = 2;
    }
  }

  static getCurrentColor() {
    Color currentColor = playerNumber == 1 ? player1Color : player2Color;

    if (playerNumber == 0) currentColor = player0Color;

    return currentColor;
  }

//Para ser llamado
  /*
  FlatButton(
    onPressed: () {
      globalData.changeServer(9);
    }
  */

}
