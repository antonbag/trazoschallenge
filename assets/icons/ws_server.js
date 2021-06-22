const WebSocket = require('ws');
const fs = require("fs");

let _puerto = 4445;
let _server;

let currentUnityInfo;
var _sockets = [];

//no se por que no me va el map
var _playerControl = new Map();
//uso array: gorrino pero efectivo
var _playerControlArray = [];

var _socket_unity;

//test player
var _socket_player0;

var _socket_player1;
var _socket_player2;

//PRUEBAS

/*
const imageCoded = "PHN2ZyBhcmlhLWhpZGRlbj0idHJ1ZSIgZm9jdXNhYmxlPSJmYWxzZSIgZGF0YS1wcmVmaXg9ImZhcyIgZGF0YS1pY29uPSJjaGVjay1jaXJjbGUiIGNsYXNzPSJzdmctaW5saW5lLS1mYSBmYS1jaGVjay1jaXJjbGUgZmEtdy0xNiIgcm9sZT0iaW1nIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCA1MTIgNTEyIj48cGF0aCBmaWxsPSJjdXJyZW50Q29sb3IiIGQ9Ik01MDQgMjU2YzAgMTM2Ljk2Ny0xMTEuMDMzIDI0OC0yNDggMjQ4UzggMzkyLjk2NyA4IDI1NiAxMTkuMDMzIDggMjU2IDhzMjQ4IDExMS4wMzMgMjQ4IDI0OHpNMjI3LjMxNCAzODcuMzE0bDE4NC0xODRjNi4yNDgtNi4yNDggNi4yNDgtMTYuMzc5IDAtMjIuNjI3bC0yMi42MjctMjIuNjI3Yy02LjI0OC02LjI0OS0xNi4zNzktNi4yNDktMjIuNjI4IDBMMjE2IDMwOC4xMThsLTcwLjA1OS03MC4wNTljLTYuMjQ4LTYuMjQ4LTE2LjM3OS02LjI0OC0yMi42MjggMGwtMjIuNjI3IDIyLjYyN2MtNi4yNDggNi4yNDgtNi4yNDggMTYuMzc5IDAgMjIuNjI3bDEwNCAxMDRjNi4yNDkgNi4yNDkgMTYuMzc5IDYuMjQ5IDIyLjYyOC4wMDF6Ij48L3BhdGg+PC9zdmc+"
const buffer = Buffer.from(imageCoded, "base64");
fs.writeFileSync("cache/normalImage.jpg", buffer);
*/





function iniciaServer(){
    console.log("server: " + _puerto);
    
    _server = new WebSocket.Server({
        port: _puerto
    });
  
    

}

iniciaServer();

_server.on('error', function (e) {
  console.log("ERROR INICIANDO SERVER");
  console.log(e);
  _puerto+=1;
  iniciaServer();
});



_server.on('connection', function(socket, req) {
    
    _sockets.push(socket);

    // When you receive a message, send that message to every socket.
    socket.on('message', function(msg) {
    

        
        
    try{
       msg = JSON.parse(msg);
       console.log("mensaje recibido");
       console.log(msg['from']);
    } catch(error){
       console.log(msg);
       console.log("!!!!!Error. Es un json?");
    }
        
        



    

    //UNITY
    if(msg['from'] == 'unity'){
        currentUnityInfo=msg;
        //actualizo sockets
        _socket_unity = socket;
        
        fromUnity(msg);
    }

    //FLUTTER - CLIENTES
    if(msg['from'] == 'flutter'){

      //actualizo sockets
      if(msg['player'] == 0) _socket_player0 = socket;
        
      fromFlutter(msg, socket);
    }
    


    /*  
      let responderMensaje = function(s) {
          console.log("************:"+s);
          console.log("socket:"+s);
          console.log("mensaje:"+msg);
          console.log(req.socket.remoteAddress);
          s.send("rebota rebota: "+msg);
      }

      sockets.forEach(responderMensaje);
        
    */
            
    
  });




  //QUITO EL SOCKET DEL ARRAY si alguien se desconecta
  socket.on('close', function() {
    //console.log(_sockets);
      
    var msg = JSON.parse('{"from":"flutter","player":0,"component":"server","task":"reboot","data":"","extra":""}');

    sendToUnity(msg);
    //console.log(msg);
      
    _sockets = _sockets.filter(s => s !== socket);
    
    console.log("*************alguien ha salido*****************");
    
    //quito el array
    _playerControlArray = _playerControlArray.filter(s => function(){
        s !== socket;
    });
    

  });


});


/*
function deleteIfYes(map, pred) {
   
  for (let [k, v] of map) {
      console.log(k);
    if (!pred(k,v)) {
        console.log(k);
      //map.delete(k);
    }
  }
  return map;
}
*/





////////////////////////////////////////////////
////////////////////////////////////////////////
// FLUTTER CLIENTES //////////////////////////////
////////////////////////////////////////////////
////////////////////////////////////////////////

function fromFlutter(msg, socket){
  var mensaje = msg['mensaje'];  
  var data = msg['data'];  

  
  //QR saludos
  if(msg['component'] == 'qr'){

      if(msg['task'] == 'hola'){

  
            //por defecto
            var saludoDevuelto = {status: "nook", mensaje: 'Uh Oh. Parece que ya hay un player'};
            
            if(playerExists(msg['player'])){
                saludoDevuelto = {status: "nook", mensaje: 'Uh Oh. Parece que ya hay un player'};
            }else{
                saludoDevuelto = {status: "ok", mensaje: 'Hola Player. El servidor te saluda.'};
            }
            socket.send(JSON.stringify(saludoDevuelto));
      }
      
      if(msg['task'] == 'fight'){
          
            const saludoDevuelto = {status: "ok", mensaje: 'challenge!!!'};
           
            socket.send(JSON.stringify(saludoDevuelto));

            console.log("fight "+msg['player']);
            
            ///* no me itera el map :/
            //_playerControl[msg['player']] = socket;
            
            sendToUnity(msg);
            
            //
            _playerControlArray["player"+msg['player']] = [socket];
      } 
  }
  
  //GYRO 
  if(msg['component'] == 'gyro'){

      if(msg['task'] == 'gira'){
            const mensajeDevuelto = {status: "ok", mensaje: ''};    
            socket.send(JSON.stringify(mensajeDevuelto));
            console.log(msg['data']);
            sendToUnity(msg);

      }     
  }
  
  
  //CANVAS to Unity
  if(msg['component'] == 'canvas'){
    //convierto imagen y luego...
    convertToImage(msg).then((val) =>{
      msg['data'] = val;
      msg['extra']='';

      sendToUnity(msg);
    });
  }



  //RESPUESta
  //socket.send("RECIBIDO");


}


function playerExists(player){
    
       
        if(_playerControlArray["player"+player] == undefined){
            console.log(_playerControlArray["player"+player]);
            return false;
        }else{
            console.log("vampiroesiste");
            return true;
        }
  
        
}












////////////////////////////////////////////////
////////////////////////////////////////////////
// UNITY //////////////////////////////
////////////////////////////////////////////////
////////////////////////////////////////////////

function sendToUnity(usmg){
    
    if(usmg["from"] == undefined) usmg["from"] = "";
    if(usmg["player"] == undefined) usmg["player"] = 0;
    if(usmg["component"] == undefined) usmg["component"] = "";
    if(usmg["task"] == undefined) usmg["task"] = "";
    if(usmg["data"] == undefined) usmg["data"] = "";
    if(usmg["extra"] == undefined) usmg["extra"] = "";
    
    try{
        console.log(JSON.stringify(usmg));
        _socket_unity.send(JSON.stringify(usmg));
    }catch{
        console.log("error in Unity Socket");
    }
    
}

function fromUnity(umsg){

    const component = umsg["component"];  
    const task = umsg["task"];  
    const player = umsg["player"];  


    //envio mensaje al cliente
    //console.log(_socket_player0);
    //_socket_player0.send("RECIBIDO");


    setTimeout(function(){
      //socket.send(data+" lo serás tú");

    },1000);
    
}




// CONVERTIR IMAGEN BASE64 A JPG
//
function convertToImage(msg){



  return promise = new Promise(function(resolve, reject) {

    let base64Image = msg['data'];
    const buffer = Buffer.from(base64Image, "base64");
  
    let nombreImage =  'player'+msg['player']+'_'+Date.now();
  
    fs.writeFileSync("cache/"+nombreImage+".jpg", buffer);

    resolve(nombreImage);

  });
  

}






function hola(){

  setTimeout(function(){
    //socket.send(data+" lo serás tú");

    return true;

  },1000);
 
}


function sendImageToUnity(imageHash,msg){

  
  msg['imageHash'] = imageHash;
  _socket_unity.send(JSON.stringify(msg));


}







////////////////////////////////////////////////
// CONTADOR OPERATIVO  //////////////////////////////
////////////////////////////////////////////////
setInterval(function() {

    console.log("todo OK:" + _puerto);
    

    
   
    /*
    _playerControlArray.forEach(function(k,v){
        console.log(k);
    });
*/
  

 

    
 

}, 5000);








