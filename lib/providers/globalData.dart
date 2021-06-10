import 'dart:io';

/// * datos globales para llamar desde diferentes pages

class globalData {

  static int clientNumber = 0;

  static var serverURL = "10.0.2.2";
  static var serverPORT = "4444";

  static printCurrentServer() {
    print(serverURL+":"+serverPORT);
  }

  static changeServer(String newServerURL) {
    serverURL = newServerURL;
  }

  static changePort(String newServerPORT) {
    serverPORT = newServerPORT;
  }


//Para ser llamado
  /*
  FlatButton(
    onPressed: () {
      globalData.changeServer(9);
    }
  */

}
